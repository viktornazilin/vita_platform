// supabase/functions/ai-insights/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ─────────────────────────────────────────────────────────────
// Env / Clients
// ─────────────────────────────────────────────────────────────
const SUPABASE_URL =
  Deno.env.get("SUPABASE_URL") ?? Deno.env.get("PROJECT_URL");

const SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  Deno.env.get("SERVICE_ROLE_KEY");

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
const OPENAI_MODEL = Deno.env.get("OPENAI_MODEL") ?? "gpt-4.1-mini";

if (!SUPABASE_URL) console.error("Missing SUPABASE_URL or PROJECT_URL");
if (!SERVICE_ROLE_KEY) console.error("Missing SUPABASE_SERVICE_ROLE_KEY or SERVICE_ROLE_KEY");
if (!OPENAI_API_KEY) console.warn("Missing OPENAI_API_KEY — rule-based insights only");

const admin = createClient(SUPABASE_URL!, SERVICE_ROLE_KEY!, {
  auth: { persistSession: false, autoRefreshToken: false },
});

// ─────────────────────────────────────────────────────────────
// Response helpers
// ─────────────────────────────────────────────────────────────
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json; charset=utf-8",
    },
  });
}

function errorResponse(message: string, status = 400, details?: unknown) {
  return jsonResponse({ ok: false, error: message, details }, status);
}

// ─────────────────────────────────────────────────────────────
// Date helpers
// ─────────────────────────────────────────────────────────────
const DAY_MS = 24 * 60 * 60 * 1000;

function toDayKey(d: Date) {
  return d.toISOString().slice(0, 10);
}

function addDays(d: Date, days: number) {
  const x = new Date(d);
  x.setUTCDate(x.getUTCDate() + days);
  return x;
}

function startOfUtcDay(d: Date) {
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate()));
}

function endOfUtcDay(d: Date) {
  const x = startOfUtcDay(d);
  x.setUTCHours(23, 59, 59, 999);
  return x;
}

function normalizePeriod(input: unknown) {
  const p = String(input ?? "week").toLowerCase().trim();
  if (["day", "today", "last_1_day"].includes(p)) return "day";
  if (["week", "last_7_days", "7d"].includes(p)) return "week";
  if (["month", "last_30_days", "30d"].includes(p)) return "month";
  if (["quarter", "last_90_days", "90d"].includes(p)) return "quarter";
  return "week";
}

function periodToRange(periodInput: unknown, dateFromInput?: unknown, dateToInput?: unknown) {
  const period = normalizePeriod(periodInput);
  const now = new Date();

  if (dateFromInput && dateToInput) {
    const from = startOfUtcDay(new Date(String(dateFromInput)));
    const to = endOfUtcDay(new Date(String(dateToInput)));
    if (Number.isNaN(from.getTime()) || Number.isNaN(to.getTime()) || from > to) {
      throw new Error("Invalid date_from/date_to range");
    }
    return {
      period,
      from,
      to,
      fromDay: toDayKey(from),
      toDay: toDayKey(to),
      days: Math.max(1, Math.round((startOfUtcDay(to).getTime() - startOfUtcDay(from).getTime()) / DAY_MS) + 1),
    };
  }

  const to = endOfUtcDay(now);
  const days = period === "day" ? 1 : period === "week" ? 7 : period === "quarter" ? 90 : 30;
  const from = startOfUtcDay(addDays(to, -(days - 1)));

  return {
    period,
    from,
    to,
    fromDay: toDayKey(from),
    toDay: toDayKey(to),
    days,
  };
}

function safeNum(n: unknown, fallback = 0) {
  const x = Number(n);
  return Number.isFinite(x) ? x : fallback;
}

function round(n: number, digits = 2) {
  const k = 10 ** digits;
  return Math.round(n * k) / k;
}

function mean(arr: number[]) {
  if (!arr.length) return null;
  return arr.reduce((a, b) => a + b, 0) / arr.length;
}

function std(arr: number[]) {
  const m = mean(arr);
  if (m === null) return null;
  const v = arr.reduce((s, x) => s + (x - m) ** 2, 0) / arr.length;
  return Math.sqrt(v);
}

function pearson(x: number[], y: number[]) {
  if (x.length !== y.length || x.length < 3) return null;
  const mx = mean(x);
  const my = mean(y);
  const sx = std(x);
  const sy = std(y);
  if (mx === null || my === null || !sx || !sy) return null;
  let cov = 0;
  for (let i = 0; i < x.length; i++) cov += (x[i] - mx) * (y[i] - my);
  return cov / x.length / (sx * sy);
}

function completionRatio(done: number, total: number) {
  return total > 0 ? done / total : 0;
}

function emojiToMoodScore(emoji: string | null | undefined) {
  const e = String(emoji ?? "").trim();
  const map: Record<string, number> = {
    "😄": 5, "😁": 5, "🤩": 5, "😊": 4, "🙂": 4,
    "😐": 3, "😶": 3, "🙃": 3,
    "😕": 2, "😔": 2, "😞": 2, "😢": 1, "😭": 1, "😡": 1, "🤯": 1,
  };
  return map[e] ?? null;
}

function topEntries<T>(items: T[], score: (x: T) => number, limit: number) {
  return [...items].sort((a, b) => score(b) - score(a)).slice(0, limit);
}

// ─────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────
type UserGoalRow = {
  id: string;
  life_block: string | null;
  horizon: string;
  title: string;
  description: string | null;
  target_date: string | null;
  is_completed: boolean;
  completed_at: string | null;
};

type TaskRow = {
  id: string;
  title: string;
  description: string | null;
  life_block: string | null;
  is_completed: boolean;
  deadline: string;
  start_time: string;
  created_at: string;
  spent_hours: string | number | null;
  importance: number | null;
  emotion: string | null;
  user_goal_id: string | null;
};

type HabitRow = {
  id: string;
  title: string;
  is_negative: boolean;
};

type HabitEntryRow = {
  habit_id: string;
  day: string;
  done: boolean;
  value: number;
  note: string;
};

type MoodRow = {
  date: string;
  emoji: string;
  note: string | null;
};

type MealRow = {
  entry_date: string;
  meal_type: "breakfast" | "lunch" | "dinner" | "snack" | string;
  calories: number;
  description: string;
};

type MentalAnswerRow = {
  day: string;
  question_id: string;
  value_bool: boolean | null;
  value_int: number | null;
  value_text: string | null;
};

type MentalQuestionRow = {
  id: string;
  code: string | null;
};

type Daily = {
  day: string;
  tasks_total: number;
  tasks_done: number;
  tasks_open: number;
  tasks_overdue_open: number;
  tasks_spent_hours: number;
  avg_importance: number | null;
  linked_tasks: number;
  unlinked_tasks: number;
  life_blocks: Record<string, { total: number; done: number; hours: number }>;
  emotions: Record<string, number>;
  mood_score: number | null;
  mood_emoji: string | null;
  mood_note_present: boolean;
  habits_positive_done: number;
  habits_negative_triggered: number;
  habits_done_titles: string[];
  negative_habit_titles: string[];
  meals_count: number;
  meal_types: string[];
  calories: number;
  mental_int_avg: Record<string, number>;
};

type Insight = {
  type: "goal" | "day_quality" | "balance" | "habit" | "mood" | "meal" | "risk" | "data_quality" | "recommendation";
  priority: "high" | "medium" | "low";
  title: string;
  insight: string;
  evidence: string[];
  suggestion: string;
};

type ClientContext = {
  userGoalsById: Map<string, Partial<UserGoalRow>>;
  tasksById: Map<string, Partial<TaskRow>>;
  habitsById: Map<string, Partial<HabitRow>>;
  mentalAnswers: MentalAnswerRow[];
};

function isEncryptedPlaceholder(value: unknown) {
  const s = String(value ?? "").trim().toLowerCase();
  return (
    s === "" ||
    s === "[encrypted]" ||
    s === "__encrypted__" ||
    s === "encrypted" ||
    s.startsWith("[encrypted:")
  );
}

function cleanText(value: unknown) {
  const s = String(value ?? "").trim();
  if (!s || isEncryptedPlaceholder(s)) return null;
  return s;
}

function shortId(id: unknown) {
  return String(id ?? "").slice(0, 6);
}

function normalizeClientContext(input: any): ClientContext {
  const ctx: ClientContext = {
    userGoalsById: new Map(),
    tasksById: new Map(),
    habitsById: new Map(),
    mentalAnswers: [],
  };

  const userGoals = Array.isArray(input?.user_goals) ? input.user_goals : [];
  for (const raw of userGoals) {
    const id = String(raw?.id ?? "");
    if (!id) continue;
    ctx.userGoalsById.set(id, {
      title: cleanText(raw?.title) ?? undefined,
      description: cleanText(raw?.description) ?? undefined,
      life_block: cleanText(raw?.life_block) ?? raw?.life_block ?? undefined,
      horizon: cleanText(raw?.horizon) ?? raw?.horizon ?? undefined,
      target_date: raw?.target_date ?? undefined,
      is_completed: typeof raw?.is_completed === "boolean" ? raw.is_completed : undefined,
      completed_at: raw?.completed_at ?? undefined,
    });
  }

  const tasks = Array.isArray(input?.goals) ? input.goals : Array.isArray(input?.tasks) ? input.tasks : [];
  for (const raw of tasks) {
    const id = String(raw?.id ?? "");
    if (!id) continue;
    ctx.tasksById.set(id, {
      title: cleanText(raw?.title) ?? undefined,
      description: cleanText(raw?.description) ?? undefined,
      life_block: cleanText(raw?.life_block) ?? raw?.life_block ?? undefined,
      emotion: cleanText(raw?.emotion) ?? raw?.emotion ?? undefined,
      user_goal_id: raw?.user_goal_id ?? undefined,
    });
  }

  const habits = Array.isArray(input?.habits) ? input.habits : [];
  for (const raw of habits) {
    const id = String(raw?.id ?? "");
    if (!id) continue;
    ctx.habitsById.set(id, {
      title: cleanText(raw?.title) ?? undefined,
      is_negative: typeof raw?.is_negative === "boolean" ? raw.is_negative : undefined,
    });
  }

  const mentalAnswers = Array.isArray(input?.mental_answers) ? input.mental_answers : [];
  for (const raw of mentalAnswers) {
    const day = String(raw?.day ?? "").slice(0, 10);
    const questionId = String(raw?.question_id ?? "");
    if (!day || !questionId) continue;

    const rawInt = raw?.value_int;
    const rawBool = raw?.value_bool;
    const rawText = raw?.value_text;

    ctx.mentalAnswers.push({
      day,
      question_id: questionId,
      value_bool: typeof rawBool === "boolean" ? rawBool : null,
      value_int: rawInt === null || rawInt === undefined ? null : safeNum(rawInt),
      value_text: cleanText(rawText),
    });
  }

  return ctx;
}

function mergeClientContextIntoRows(
  userGoals: UserGoalRow[],
  tasks: TaskRow[],
  habits: HabitRow[],
  mentalAnswers: MentalAnswerRow[],
  clientContextInput: any,
  fromDay: string,
  toDay: string,
) {
  const ctx = normalizeClientContext(clientContextInput);

  const mergedUserGoals = userGoals.map((g) => {
    const c = ctx.userGoalsById.get(g.id);
    const title = cleanText(c?.title) ?? cleanText(g.title) ?? `Цель ${shortId(g.id)}`;
    const description = cleanText(c?.description) ?? cleanText(g.description);
    return {
      ...g,
      ...c,
      title,
      description,
      life_block: c?.life_block ?? g.life_block,
      horizon: c?.horizon ?? g.horizon,
      target_date: c?.target_date ?? g.target_date,
      is_completed: c?.is_completed ?? g.is_completed,
      completed_at: c?.completed_at ?? g.completed_at,
    } as UserGoalRow;
  });

  const mergedTasks = tasks.map((t) => {
    const c = ctx.tasksById.get(t.id);
    return {
      ...t,
      ...c,
      title: cleanText(c?.title) ?? cleanText(t.title) ?? `Задача ${shortId(t.id)}`,
      description: cleanText(c?.description) ?? cleanText(t.description),
      life_block: c?.life_block ?? t.life_block,
      emotion: c?.emotion ?? t.emotion,
      user_goal_id: c?.user_goal_id ?? t.user_goal_id,
    } as TaskRow;
  });

  const mergedHabits = habits.map((h) => {
    const c = ctx.habitsById.get(h.id);
    return {
      ...h,
      ...c,
      title: cleanText(c?.title) ?? cleanText(h.title) ?? `Привычка ${shortId(h.id)}`,
      is_negative: c?.is_negative ?? h.is_negative,
    } as HabitRow;
  });

  const clientMentalAnswers = ctx.mentalAnswers.filter((a) => a.day >= fromDay && a.day <= toDay);
  const mergedMentalAnswers = clientMentalAnswers.length > 0 ? clientMentalAnswers : mentalAnswers;

  return {
    userGoals: mergedUserGoals,
    tasks: mergedTasks,
    habits: mergedHabits,
    mentalAnswers: mergedMentalAnswers,
    hasClientContext: Boolean(clientContextInput && Object.keys(clientContextInput).length > 0),
  };
}

// ─────────────────────────────────────────────────────────────
// Data loading
// ─────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────
// Data loading
// ─────────────────────────────────────────────────────────────
async function selectOrThrow<T>(query: PromiseLike<{ data: T | null; error: any }>, label: string): Promise<T> {
  const { data, error } = await query;
  if (error) throw new Error(`${label} failed: ${error.message}`);
  return data as T;
}

async function buildAnalytics(userId: string, periodInput: unknown, dateFrom?: unknown, dateTo?: unknown, clientContext?: any) {
  const range = periodToRange(periodInput, dateFrom, dateTo);
  const { period, from, to, fromDay, toDay, days } = range;

  let [userGoals, tasks, moods, habits, habitEntries, meals] = await Promise.all([
    selectOrThrow<UserGoalRow[]>(
      admin
        .from("user_goals")
        .select("id,life_block,horizon,title,description,target_date,is_completed,completed_at")
        .eq("user_id", userId),
      "user_goals select",
    ),
    selectOrThrow<TaskRow[]>(
      admin
        .from("goals")
        .select("id,title,description,life_block,is_completed,deadline,start_time,created_at,spent_hours,importance,emotion,user_goal_id")
        .eq("user_id", userId)
        .gte("start_time", from.toISOString())
        .lte("start_time", to.toISOString()),
      "goals select",
    ),
    selectOrThrow<MoodRow[]>(
      admin
        .from("moods")
        .select("date,emoji,note")
        .eq("user_id", userId)
        .gte("date", fromDay)
        .lte("date", toDay),
      "moods select",
    ),
    selectOrThrow<HabitRow[]>(
      admin
        .from("habits")
        .select("id,title,is_negative")
        .eq("user_id", userId),
      "habits select",
    ),
    selectOrThrow<HabitEntryRow[]>(
      admin
        .from("habit_entries")
        .select("habit_id,day,done,value,note")
        .eq("user_id", userId)
        .gte("day", fromDay)
        .lte("day", toDay),
      "habit_entries select",
    ),
    selectOrThrow<MealRow[]>(
      admin
        .from("meal_entries")
        .select("entry_date,meal_type,calories,description")
        .eq("user_id", userId)
        .gte("entry_date", from.toISOString())
        .lte("entry_date", to.toISOString()),
      "meal_entries select",
    ),
  ]);

  let mentalQuestions: MentalQuestionRow[] = [];
  let mentalAnswers: MentalAnswerRow[] = [];

  // mental_questions schema was not provided. This assumes column `code` exists, as in your current function.
  // If your table uses another field name, replace `code` below.
  try {
    mentalQuestions = await selectOrThrow<MentalQuestionRow[]>(
      admin.from("mental_questions").select("id,code"),
      "mental_questions select",
    );
    mentalAnswers = await selectOrThrow<MentalAnswerRow[]>(
      admin
        .from("mental_answers")
        .select("day,question_id,value_bool,value_int,value_text")
        .eq("user_id", userId)
        .gte("day", fromDay)
        .lte("day", toDay),
      "mental_answers select",
    );
  } catch (e) {
    console.warn("Mental data skipped:", String(e));
  }

  const merged = mergeClientContextIntoRows(
    userGoals,
    tasks,
    habits,
    mentalAnswers,
    clientContext,
    fromDay,
    toDay,
  );

  userGoals = merged.userGoals;
  tasks = merged.tasks;
  habits = merged.habits;
  mentalAnswers = merged.mentalAnswers;

  const habitById = new Map(habits.map((h) => [h.id, h]));
  const userGoalById = new Map(userGoals.map((g) => [g.id, g]));
  const qCodeById = new Map(mentalQuestions.map((q) => [q.id, q.code ?? q.id]));

  const dailyMap = new Map<string, Daily>();

  function ensureDay(day: string): Daily {
    const existing = dailyMap.get(day);
    if (existing) return existing;
    const init: Daily = {
      day,
      tasks_total: 0,
      tasks_done: 0,
      tasks_open: 0,
      tasks_overdue_open: 0,
      tasks_spent_hours: 0,
      avg_importance: null,
      linked_tasks: 0,
      unlinked_tasks: 0,
      life_blocks: {},
      emotions: {},
      mood_score: null,
      mood_emoji: null,
      mood_note_present: false,
      habits_positive_done: 0,
      habits_negative_triggered: 0,
      habits_done_titles: [],
      negative_habit_titles: [],
      meals_count: 0,
      meal_types: [],
      calories: 0,
      mental_int_avg: {},
    };
    dailyMap.set(day, init);
    return init;
  }

  // Create a continuous daily axis so days without data are visible.
  for (let i = 0; i < days; i++) ensureDay(toDayKey(addDays(from, i)));

  const now = new Date();
  const importanceByDay = new Map<string, number[]>();

  for (const t of tasks) {
    const day = toDayKey(new Date(t.start_time));
    const d = ensureDay(day);
    const block = t.life_block ?? userGoalById.get(t.user_goal_id ?? "")?.life_block ?? "general";
    const hours = safeNum(t.spent_hours);

    d.tasks_total += 1;
    d.tasks_spent_hours += hours;
    if (t.is_completed) d.tasks_done += 1;
    else d.tasks_open += 1;
    if (!t.is_completed && new Date(t.deadline) < now) d.tasks_overdue_open += 1;
    if (t.user_goal_id) d.linked_tasks += 1;
    else d.unlinked_tasks += 1;

    d.life_blocks[block] ??= { total: 0, done: 0, hours: 0 };
    d.life_blocks[block].total += 1;
    d.life_blocks[block].hours += hours;
    if (t.is_completed) d.life_blocks[block].done += 1;

    if (t.emotion) d.emotions[t.emotion] = (d.emotions[t.emotion] ?? 0) + 1;
    if (t.importance !== null && t.importance !== undefined) {
      const arr = importanceByDay.get(day) ?? [];
      arr.push(safeNum(t.importance));
      importanceByDay.set(day, arr);
    }
  }

  for (const [day, values] of importanceByDay.entries()) {
    ensureDay(day).avg_importance = mean(values);
  }

  for (const m of moods) {
    const d = ensureDay(m.date);
    d.mood_emoji = m.emoji;
    d.mood_score = emojiToMoodScore(m.emoji);
    d.mood_note_present = !!m.note?.trim();
  }

  for (const e of habitEntries) {
    const habit = habitById.get(e.habit_id);
    if (!habit || !e.done) continue;
    const d = ensureDay(e.day);
    d.habits_done_titles.push(habit.title);
    if (habit.is_negative) {
      d.habits_negative_triggered += 1;
      d.negative_habit_titles.push(habit.title);
    } else {
      d.habits_positive_done += 1;
    }
  }

  for (const meal of meals) {
    const day = toDayKey(new Date(meal.entry_date));
    const d = ensureDay(day);
    d.meals_count += 1;
    d.calories += safeNum(meal.calories);
    if (!d.meal_types.includes(meal.meal_type)) d.meal_types.push(meal.meal_type);
  }

  const mentalCollector = new Map<string, Map<string, number[]>>();
  for (const a of mentalAnswers) {
    if (a.value_int === null || a.value_int === undefined) continue;
    const code = qCodeById.get(a.question_id) ?? a.question_id;
    const byCode = mentalCollector.get(a.day) ?? new Map<string, number[]>();
    const arr = byCode.get(code) ?? [];
    arr.push(safeNum(a.value_int));
    byCode.set(code, arr);
    mentalCollector.set(a.day, byCode);
  }

  for (const [day, byCode] of mentalCollector.entries()) {
    const d = ensureDay(day);
    for (const [code, values] of byCode.entries()) {
      const m = mean(values);
      if (m !== null) d.mental_int_avg[code] = round(m, 2);
    }
  }

  const daily = [...dailyMap.values()].sort((a, b) => a.day.localeCompare(b.day));

  // ─────────────────────────────────────────────
  // Main metrics
  // ─────────────────────────────────────────────
  const totalTasks = tasks.length;
  const completedTasks = tasks.filter((t) => t.is_completed).length;
  const openTasks = totalTasks - completedTasks;
  const overdueOpen = tasks.filter((t) => !t.is_completed && new Date(t.deadline) < now).length;
  const totalSpentHours = tasks.reduce((s, t) => s + safeNum(t.spent_hours), 0);
  const linkedTasks = tasks.filter((t) => !!t.user_goal_id).length;
  const unlinkedTasks = totalTasks - linkedTasks;

  const importanceValues = tasks
    .map((t) => t.importance)
    .filter((x) => x !== null && x !== undefined)
    .map((x) => safeNum(x));

  const tasksByLifeBlock: Record<string, { total: number; completed: number; hours: number; avg_importance: number | null }> = {};
  const importanceByBlock: Record<string, number[]> = {};

  for (const t of tasks) {
    const block = t.life_block ?? userGoalById.get(t.user_goal_id ?? "")?.life_block ?? "general";
    tasksByLifeBlock[block] ??= { total: 0, completed: 0, hours: 0, avg_importance: null };
    tasksByLifeBlock[block].total += 1;
    tasksByLifeBlock[block].hours += safeNum(t.spent_hours);
    if (t.is_completed) tasksByLifeBlock[block].completed += 1;
    if (t.importance !== null && t.importance !== undefined) {
      importanceByBlock[block] ??= [];
      importanceByBlock[block].push(safeNum(t.importance));
    }
  }

  for (const block of Object.keys(tasksByLifeBlock)) {
    const avg = mean(importanceByBlock[block] ?? []);
    tasksByLifeBlock[block].hours = round(tasksByLifeBlock[block].hours, 2);
    tasksByLifeBlock[block].avg_importance = avg === null ? null : round(avg, 2);
  }

  const userGoalProgress = userGoals.map((g) => {
    const related = tasks.filter((t) => t.user_goal_id === g.id);
    const completed = related.filter((t) => t.is_completed);
    const hours = related.reduce((s, t) => s + safeNum(t.spent_hours), 0);
    const overdue = related.filter((t) => !t.is_completed && new Date(t.deadline) < now).length;
    return {
      id: g.id,
      title: g.title,
      life_block: g.life_block,
      horizon: g.horizon,
      target_date: g.target_date,
      is_completed: g.is_completed,
      linked_tasks_total: related.length,
      linked_tasks_completed: completed.length,
      completion_ratio: completionRatio(completed.length, related.length),
      spent_hours: round(hours, 2),
      overdue_open: overdue,
      status:
        g.is_completed ? "completed" :
        related.length === 0 ? "inactive" :
        overdue > 0 ? "has_overdue" :
        "active",
    };
  });

  const inactiveUserGoals = userGoalProgress.filter((g) => !g.is_completed && g.linked_tasks_total === 0);
  const activeUserGoals = userGoalProgress.filter((g) => !g.is_completed && g.linked_tasks_total > 0);
  const goalsWithOverdue = userGoalProgress.filter((g) => !g.is_completed && g.overdue_open > 0);

  const moodScores = daily.map((d) => d.mood_score).filter((x): x is number => x !== null);
  const avgMood = mean(moodScores);

  const daysWithBreakfast = daily.filter((d) => d.meal_types.includes("breakfast")).length;
  const daysWithMeals = daily.filter((d) => d.meals_count > 0).length;
  const avgCalories = mean(daily.filter((d) => d.meals_count > 0).map((d) => d.calories));

  const daysWithTasks = daily.filter((d) => d.tasks_total > 0).length;
  const daysWithMood = daily.filter((d) => d.mood_score !== null).length;
  const daysWithHabits = daily.filter((d) => d.habits_done_titles.length > 0).length;

  const sufficiency = {
    period,
    period_days: days,
    date_from: fromDay,
    date_to: toDay,
    days_with_tasks: daysWithTasks,
    days_with_mood: daysWithMood,
    days_with_habits: daysWithHabits,
    days_with_meals: daysWithMeals,
    ok_for_basic: daysWithTasks >= 3,
    ok_for_patterns: daysWithTasks >= 7,
    ok_for_correlation: daysWithTasks >= 14,
    notes: [] as string[],
  };

  if (daysWithTasks < 3) sufficiency.notes.push("Мало дней с задачами: базовые выводы будут ограничены.");
  if (daysWithTasks < 7) sufficiency.notes.push("Для недельных паттернов желательно минимум 7 дней с задачами.");
  if (daysWithTasks < 14) sufficiency.notes.push("Для корреляций желательно минимум 14 дней с задачами.");

  // ─────────────────────────────────────────────
  // Pattern stats
  // ─────────────────────────────────────────────
  const dailyTasksDone = daily.map((d) => d.tasks_done);
  const dailyCompletion = daily.map((d) => completionRatio(d.tasks_done, d.tasks_total));

  const moodXs: number[] = [];
  const moodYs: number[] = [];
  for (const d of daily) {
    if (d.mood_score !== null) {
      moodXs.push(d.mood_score);
      moodYs.push(d.tasks_done);
    }
  }

  const habitEffects = habits.map((habit) => {
    const flag = daily.map((d) => d.habits_done_titles.includes(habit.title));
    const withDays = flag.filter(Boolean).length;
    const withoutDays = flag.filter((x) => !x).length;
    const y = dailyTasksDone;
    const withVals = y.filter((_, i) => flag[i]);
    const withoutVals = y.filter((_, i) => !flag[i]);
    const withMean = mean(withVals);
    const withoutMean = mean(withoutVals);
    const delta = withMean !== null && withoutMean !== null ? withMean - withoutMean : null;
    return {
      habit: habit.title,
      is_negative: habit.is_negative,
      days_done: withDays,
      days_not_done: withoutDays,
      avg_tasks_done_when_done: withMean === null ? null : round(withMean, 2),
      avg_tasks_done_when_not_done: withoutMean === null ? null : round(withoutMean, 2),
      delta_tasks_done: delta === null ? null : round(delta, 2),
      status: withDays >= 2 && withoutDays >= 2 && sufficiency.ok_for_patterns ? "ok" : "insufficient_data",
    };
  });

  const mentalCodes = new Set<string>();
  for (const d of daily) Object.keys(d.mental_int_avg).forEach((c) => mentalCodes.add(c));

  const mentalEffects = [...mentalCodes].map((code) => {
    const xs: number[] = [];
    const ys: number[] = [];
    for (const d of daily) {
      const x = d.mental_int_avg[code];
      if (x === undefined) continue;
      xs.push(x);
      ys.push(d.tasks_done);
    }
    const r = pearson(xs, ys);
    return {
      question: code,
      metric: "tasks_done",
      observations: xs.length,
      correlation_r: r === null ? null : round(r, 2),
      status: xs.length >= 5 && r !== null && sufficiency.ok_for_patterns ? "ok" : "insufficient_data",
    };
  }).sort((a, b) => Math.abs(b.correlation_r ?? 0) - Math.abs(a.correlation_r ?? 0));

  const moodEffect = {
    metric: "tasks_done",
    observations: moodXs.length,
    correlation_r: pearson(moodXs, moodYs),
    status: moodXs.length >= 5 && sufficiency.ok_for_patterns ? "ok" : "insufficient_data",
  };
  moodEffect.correlation_r = moodEffect.correlation_r === null ? null : round(moodEffect.correlation_r, 2);

  const snapshot = {
    period,
    date_from: fromDay,
    date_to: toDay,
    generated_at: new Date().toISOString(),
    tasks_overview: {
      total: totalTasks,
      completed: completedTasks,
      open: openTasks,
      completed_ratio: round(completionRatio(completedTasks, totalTasks), 3),
      overdue_open: overdueOpen,
      total_spent_hours: round(totalSpentHours, 2),
      average_importance: mean(importanceValues) === null ? null : round(mean(importanceValues)!, 2),
      linked_to_big_goal: linkedTasks,
      unlinked_to_big_goal: unlinkedTasks,
      linked_ratio: round(completionRatio(linkedTasks, totalTasks), 3),
    },
    user_goals_overview: {
      total: userGoals.length,
      completed: userGoals.filter((g) => g.is_completed).length,
      active: activeUserGoals.length,
      inactive: inactiveUserGoals.length,
      with_overdue_tasks: goalsWithOverdue.length,
      by_horizon: ["tactical", "mid", "long"].reduce((acc: Record<string, number>, h) => {
        acc[h] = userGoals.filter((g) => g.horizon === h).length;
        return acc;
      }, {}),
      progress: userGoalProgress,
    },
    balance: {
      tasks_by_life_block: tasksByLifeBlock,
      most_active_blocks: topEntries(
        Object.entries(tasksByLifeBlock).map(([life_block, v]) => ({ life_block, ...v })),
        (x) => x.total,
        5,
      ),
      ignored_goal_blocks: [...new Set(inactiveUserGoals.map((g) => g.life_block ?? "general"))],
    },
    mood: {
      days_with_mood: daysWithMood,
      average_score: avgMood === null ? null : round(avgMood, 2),
      correlation_with_tasks_done: moodEffect,
    },
    habits: {
      total_habits: habits.length,
      positive_habits: habits.filter((h) => !h.is_negative).length,
      negative_habits: habits.filter((h) => h.is_negative).length,
      effects: habitEffects,
      most_frequent_negative: topEntries(
        habits
          .filter((h) => h.is_negative)
          .map((h) => ({
            habit: h.title,
            days: daily.filter((d) => d.negative_habit_titles.includes(h.title)).length,
          })),
        (x) => x.days,
        3,
      ),
    },
    meals: {
      days_with_meals: daysWithMeals,
      days_with_breakfast: daysWithBreakfast,
      days_without_breakfast: days - daysWithBreakfast,
      average_calories_on_logged_days: avgCalories === null ? null : round(avgCalories, 0),
    },
    mental: {
      effects: mentalEffects.slice(0, 10),
    },
    daily,
  };

  const stats = {
    sufficiency,
    strongest_habit_effects: habitEffects
      .filter((h) => h.status === "ok" && h.delta_tasks_done !== null)
      .sort((a, b) => Math.abs(b.delta_tasks_done ?? 0) - Math.abs(a.delta_tasks_done ?? 0))
      .slice(0, 5),
    mood_effect: moodEffect,
    mental_effects: mentalEffects.slice(0, 10),
    risks: {
      overdue_open: overdueOpen,
      inactive_user_goals: inactiveUserGoals.length,
      unlinked_tasks: unlinkedTasks,
      days_without_breakfast: days - daysWithBreakfast,
    },
  };

  return { period, fromDay, toDay, snapshot, stats };
}

// ─────────────────────────────────────────────────────────────
// Rule-based insights
// ─────────────────────────────────────────────────────────────
function buildRuleBasedInsights(snapshot: any, stats: any): Insight[] {
  const insights: Insight[] = [];
  const t = snapshot.tasks_overview;
  const ug = snapshot.user_goals_overview;
  const suff = stats.sufficiency;

  if (!suff.ok_for_basic) {
    insights.push({
      type: "data_quality",
      priority: "high",
      title: "Пока мало данных для сильных выводов",
      insight: "За выбранный период недостаточно дней с задачами, поэтому рекомендации будут осторожными.",
      evidence: [
        `Дней с задачами: ${suff.days_with_tasks}`,
        `Период: ${suff.date_from} — ${suff.date_to}`,
      ],
      suggestion: "Заполняй задачи, настроение и привычки хотя бы 7 дней подряд — после этого AI сможет находить более точные паттерны.",
    });
  }

  insights.push({
    type: "day_quality",
    priority: t.overdue_open > 0 ? "high" : "medium",
    title: "Итог по задачам",
    insight: `Выполнено ${t.completed} из ${t.total} задач (${Math.round(t.completed_ratio * 100)}%).${t.overdue_open > 0 ? ` Осталось ${t.overdue_open} просроченных задач.` : " Просроченных открытых задач нет."}`,
    evidence: [
      `Всего задач: ${t.total}`,
      `Выполнено: ${t.completed}`,
      `Затрачено часов: ${t.total_spent_hours}`,
      `Средняя важность: ${t.average_importance ?? "нет данных"}`,
    ],
    suggestion: t.overdue_open > 0
      ? "Сначала выбери 1–2 просроченные задачи с высокой важностью и перенеси остальные осознанно, чтобы не копить долг."
      : "Сохрани этот ритм, но проверь, достаточно ли выполненные задачи связаны с большими целями.",
  });

  if (t.total > 0 && t.linked_ratio < 0.5) {
    insights.push({
      type: "goal",
      priority: "high",
      title: "Много задач не связано с большими целями",
      insight: `Только ${Math.round(t.linked_ratio * 100)}% задач связаны с user_goals через user_goal_id. Из-за этого прогресс по большим целям виден не полностью.`,
      evidence: [
        `Связанных задач: ${t.linked_to_big_goal}`,
        `Несвязанных задач: ${t.unlinked_to_big_goal}`,
      ],
      suggestion: "При создании задачи выбирай связанную большую цель. Это даст AI возможность точнее показывать прогресс и пробелы.",
    });
  }

  if (ug.inactive > 0) {
    const inactive = ug.progress
      .filter((g: any) => g.status === "inactive")
      .slice(0, 3)
      .map((g: any) => `${g.title} (${g.life_block ?? "general"}, ${g.horizon})`);

    insights.push({
      type: "goal",
      priority: "high",
      title: "Есть цели без активности",
      insight: `У ${ug.inactive} незавершённых больших целей нет связанных задач в выбранном периоде.`,
      evidence: inactive.length ? inactive : [`Неактивных целей: ${ug.inactive}`],
      suggestion: "Выбери одну такую цель и добавь к ней маленькую задачу на ближайший день. Лучше один конкретный шаг, чем абстрактный план.",
    });
  }

  if (ug.with_overdue_tasks > 0) {
    const risky = ug.progress
      .filter((g: any) => g.status === "has_overdue")
      .slice(0, 3)
      .map((g: any) => `${g.title}: просрочено ${g.overdue_open}`);

    insights.push({
      type: "risk",
      priority: "high",
      title: "Риск по целям с просроченными задачами",
      insight: "Часть больших целей имеет просроченные связанные задачи. Это может тормозить прогресс.",
      evidence: risky,
      suggestion: "Раздели просроченные задачи на: удалить, перенести, сделать сегодня. Не оставляй их в неопределённом состоянии.",
    });
  }

  const blocks = Object.entries(snapshot.balance.tasks_by_life_block ?? {}) as [string, any][];
  if (blocks.length >= 2) {
    const sorted = [...blocks].sort((a, b) => b[1].total - a[1].total);
    const top = sorted[0];
    const low = sorted.filter(([, v]) => v.total <= 1).map(([k]) => k);

    insights.push({
      type: "balance",
      priority: low.length > 0 ? "medium" : "low",
      title: "Баланс сфер жизни",
      insight: `Самая активная сфера — ${top[0]} (${top[1].total} задач).${low.length ? ` Почти без активности: ${low.join(", ")}.` : " Активность распределена относительно равномерно."}`,
      evidence: sorted.slice(0, 5).map(([k, v]) => `${k}: ${v.total} задач, ${v.completed} выполнено, ${v.hours} ч.`),
      suggestion: low.length
        ? `Добавь одну короткую задачу в сферу ${low[0]}, чтобы не терять баланс.`
        : "Продолжай поддерживать распределение задач по нескольким сферам, а не только по одной.",
    });
  }

  const strongestHabit = stats.strongest_habit_effects?.[0];
  if (strongestHabit) {
    const delta = strongestHabit.delta_tasks_done;
    insights.push({
      type: "habit",
      priority: Math.abs(delta) >= 1 ? "medium" : "low",
      title: `Привычка: ${strongestHabit.habit}`,
      insight: `В дни, когда привычка отмечена, среднее число выполненных задач ${delta >= 0 ? "выше" : "ниже"} на ${Math.abs(delta)}. Это ассоциация, не доказанная причинность.`,
      evidence: [
        `Дней с привычкой: ${strongestHabit.days_done}`,
        `Дней без привычки: ${strongestHabit.days_not_done}`,
        `Среднее tasks_done с привычкой: ${strongestHabit.avg_tasks_done_when_done}`,
        `Среднее tasks_done без привычки: ${strongestHabit.avg_tasks_done_when_not_done}`,
      ],
      suggestion: strongestHabit.is_negative
        ? "Понаблюдай за этой привычкой ещё 1–2 недели и попробуй ограничить её в первой половине дня."
        : "Попробуй закрепить эту привычку как утренний или вечерний якорь, если она действительно помогает продуктивности.",
    });
  } else if (!suff.ok_for_patterns) {
    insights.push({
      type: "habit",
      priority: "low",
      title: "Паттерны по привычкам пока неустойчивы",
      insight: "Недостаточно данных, чтобы сравнить дни с привычками и без них.",
      evidence: [`Дней с задачами: ${suff.days_with_tasks}`, "Для паттернов желательно 7+ дней."],
      suggestion: "Отмечай привычки ежедневно, включая негативные. Особенно важны дни, когда привычка не была выполнена — без них сравнение невозможно.",
    });
  }

  if (snapshot.mood.correlation_with_tasks_done?.status === "ok") {
    const r = snapshot.mood.correlation_with_tasks_done.correlation_r;
    insights.push({
      type: "mood",
      priority: Math.abs(r) >= 0.4 ? "medium" : "low",
      title: "Настроение и продуктивность",
      insight: `Между mood score и количеством выполненных задач наблюдается корреляция r=${r}. Это не причинность, но полезный сигнал для самонаблюдения.`,
      evidence: [
        `Дней с настроением: ${snapshot.mood.days_with_mood}`,
        `Средний mood score: ${snapshot.mood.average_score}`,
      ],
      suggestion: "В дни с низким настроением планируй меньше задач, но оставляй одну маленькую задачу, связанную с важной целью.",
    });
  }

  if (snapshot.meals.days_with_meals > 0) {
    insights.push({
      type: "meal",
      priority: snapshot.meals.days_without_breakfast >= Math.ceil(suff.period_days / 2) ? "medium" : "low",
      title: "Питание и ритм дня",
      insight: `Завтрак отмечен в ${snapshot.meals.days_with_breakfast} из ${suff.period_days} дней.`,
      evidence: [
        `Дней с любыми meal entries: ${snapshot.meals.days_with_meals}`,
        `Дней без завтрака: ${snapshot.meals.days_without_breakfast}`,
        `Средние калории в дни с логами: ${snapshot.meals.average_calories_on_logged_days ?? "нет данных"}`,
      ],
      suggestion: "Если хочешь анализ энергии точнее, отмечай не только калории, но и субъективную энергию/усталость в mental_answers.",
    });
  }

  return insights.slice(0, 8);
}

// ─────────────────────────────────────────────────────────────
// LLM polish / coach message
// ─────────────────────────────────────────────────────────────
const SYSTEM_PROMPT = `Ты AI-коуч и аналитик персональной продуктивности внутри мобильного приложения.

Правила:
- Используй только переданные факты, snapshot, stats и evidence.
- Не выдумывай данные.
- Не делай медицинских, психологических или причинных диагнозов.
- Формулируй как наблюдения: "наблюдается", "похоже", "в выбранном периоде".
- Советы должны быть конкретными и короткими.
- Верни только валидный JSON в формате:
{
  "summary": string,
  "insights": Insight[],
  "tomorrow_plan": string[],
  "coach_message": string
}`;

function shouldUseLlm(body: any, normalizedPeriod: string) {
  // По умолчанию LLM включаем только для 7 дней.
  // 30/90 дней могут упереться в timeout или слишком большой payload.
  if (body?.use_llm === false) return false;
  if (body?.force_llm === true) return true;
  if (body?.use_llm === true) return normalizedPeriod === "week";
  return normalizedPeriod === "week";
}

async function buildFinalInsightsWithLLM(ruleInsights: Insight[], snapshot: any, stats: any) {

  const fallback = {
    summary: ruleInsights[0]?.insight ?? "Недостаточно данных для подробного анализа.",
    insights: ruleInsights,
    tomorrow_plan: buildTomorrowPlan(ruleInsights, snapshot),
    coach_message: "Я проанализировал твои записи и выделил самые важные наблюдения. Чем регулярнее данные, тем точнее будут рекомендации.",
  };

  if (!OPENAI_API_KEY) return fallback;

  const compactFacts = {
    period: snapshot.period,
    date_from: snapshot.date_from,
    date_to: snapshot.date_to,
    tasks_overview: snapshot.tasks_overview,
    user_goals_overview: {
      total: snapshot.user_goals_overview.total,
      completed: snapshot.user_goals_overview.completed,
      active: snapshot.user_goals_overview.active,
      inactive: snapshot.user_goals_overview.inactive,
      with_overdue_tasks: snapshot.user_goals_overview.with_overdue_tasks,
      progress: snapshot.user_goals_overview.progress.slice(0, 20),
    },
    balance: {
      most_active_blocks: snapshot.balance.most_active_blocks?.slice?.(0, 5) ?? [],
      ignored_goal_blocks: snapshot.balance.ignored_goal_blocks?.slice?.(0, 10) ?? [],
    },
    mood: snapshot.mood,
    habits: {
      total_habits: snapshot.habits.total_habits,
      most_frequent_negative: snapshot.habits.most_frequent_negative,
    },
    meals: snapshot.meals,
    stats: {
      sufficiency: stats.sufficiency,
      strongest_habit_effects: stats.strongest_habit_effects?.slice?.(0, 5) ?? [],
      mood_effect: stats.mood_effect,
      risks: stats.risks,
    },
    rule_insights: ruleInsights.slice(0, 10),
  };

  try {
    const r = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${OPENAI_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: OPENAI_MODEL,
        input: [
          { role: "system", content: SYSTEM_PROMPT },
          {
            role: "user",
            content: `Сформируй финальный JSON для UI на русском языке. Улучши формулировки, но не добавляй новые факты.\n\nDATA:\n${JSON.stringify(compactFacts)}`,
          },
        ],
        text: { format: { type: "json_object" } },
      }),
    });

    if (!r.ok) {
      console.warn("OpenAI failed:", await r.text());
      return fallback;
    }

    const data = await r.json();
    const outputText = data?.output_text ?? data?.output?.[0]?.content?.[0]?.text ?? null;
    if (!outputText) return fallback;

    const parsed = JSON.parse(outputText);
    if (!parsed || !Array.isArray(parsed.insights)) return fallback;

    return {
      summary: typeof parsed.summary === "string" ? parsed.summary : fallback.summary,
      insights: parsed.insights.filter((x: any) => x?.title && x?.insight && Array.isArray(x?.evidence)).slice(0, 8),
      tomorrow_plan: Array.isArray(parsed.tomorrow_plan) ? parsed.tomorrow_plan.slice(0, 5).map(String) : fallback.tomorrow_plan,
      coach_message: typeof parsed.coach_message === "string" ? parsed.coach_message : fallback.coach_message,
    };
  } catch (e) {
    console.warn("OpenAI parsing failed:", String(e));
    return fallback;
  }
}

function buildTomorrowPlan(insights: Insight[], snapshot: any): string[] {
  const plan: string[] = [];

  const inactiveGoal = snapshot.user_goals_overview.progress.find((g: any) => g.status === "inactive");
  if (inactiveGoal) plan.push(`Сделать одну маленькую задачу по цели: ${inactiveGoal.title}.`);

  if (snapshot.tasks_overview.overdue_open > 0) {
    plan.push("Разобрать 1–2 просроченные задачи: сделать, перенести или удалить.");
  }

  const ignoredBlock = snapshot.balance.ignored_goal_blocks?.[0];
  if (ignoredBlock) plan.push(`Добавить короткую задачу в сферу ${ignoredBlock}.`);

  if (snapshot.meals.days_without_breakfast > 0) {
    plan.push("Отметить завтрак и уровень энергии, чтобы улучшить аналитику ритма дня.");
  }

  if (plan.length === 0) {
    plan.push("Выбрать одну задачу с высокой важностью и сделать её первой.");
    plan.push("Связать новые задачи с большими целями через user_goal_id.");
  }

  return plan.slice(0, 5);
}

// ─────────────────────────────────────────────────────────────
// Persistence
// ─────────────────────────────────────────────────────────────
async function saveRun(params: {
  userId: string;
  period: string;
  fromDay: string;
  toDay: string;
  snapshot: any;
  stats: any;
  insights: any;
  usedLlm?: boolean;
}) {
  const payload = {
    user_id: params.userId,
    period: params.period,
    date_from: params.fromDay,
    date_to: params.toDay,
    version: "v2",
    model: params.usedLlm ? OPENAI_MODEL : null,
    snapshot: params.snapshot,
    stats: params.stats,
    insights: params.insights,
  };

  const { data, error } = await admin
    .from("ai_insights_runs")
    .insert(payload)
    .select("id,created_at")
    .single();

  if (error) throw new Error(`ai_insights_runs insert failed: ${error.message}`);
  return data;
}

// ─────────────────────────────────────────────────────────────
// Handler
// ─────────────────────────────────────────────────────────────
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return jsonResponse({ ok: true }, 200);
  if (req.method !== "POST") return errorResponse("Method not allowed", 405);

  try {
    if (!SUPABASE_URL) return errorResponse("Missing SUPABASE_URL or PROJECT_URL", 500);
    if (!SERVICE_ROLE_KEY) return errorResponse("Missing SUPABASE_SERVICE_ROLE_KEY or SERVICE_ROLE_KEY", 500);

    const authHeader = req.headers.get("authorization") ?? "";
    const jwt = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : null;
    if (!jwt) return errorResponse("Missing Authorization bearer token", 401);

    const { data: authData, error: authError } = await admin.auth.getUser(jwt);
    if (authError || !authData?.user) {
      return errorResponse("Invalid token", 401, authError?.message);
    }

    const userId = authData.user.id;
    const body = await req.json().catch(() => ({}));

    const hasClientContext =
      body?.client_context &&
      typeof body.client_context === "object" &&
      Object.keys(body.client_context).length > 0;

    if (hasClientContext && body?.ai_consent !== true) {
      return errorResponse("AI consent required for client_context", 403);
    }

    const { period, fromDay, toDay, snapshot, stats } = await buildAnalytics(
      userId,
      body.period ?? "week",
      body.date_from,
      body.date_to,
      body.client_context,
    );

    const ruleInsights = buildRuleBasedInsights(snapshot, stats);
    const useLlm = shouldUseLlm(body, period);

    const finalInsights = !useLlm
      ? {
          summary: ruleInsights[0]?.insight ?? "Инсайты сформированы на основе правил.",
          insights: ruleInsights,
          tomorrow_plan: buildTomorrowPlan(ruleInsights, snapshot),
          coach_message: period === "week"
            ? "Инсайты сформированы без LLM на основе статистики и правил."
            : "Для длинного периода я использовал быстрый rule-based анализ, чтобы избежать таймаута и стабильно сохранить результат.",
        }
      : await buildFinalInsightsWithLLM(ruleInsights, snapshot, stats);

    const allowPlaintextPersist = body?.allow_plaintext_persist === true;
    const shouldPersistRun = !hasClientContext || allowPlaintextPersist;

    const run = shouldPersistRun
      ? await saveRun({
          userId,
          period,
          fromDay,
          toDay,
          snapshot,
          stats,
          insights: finalInsights,
          usedLlm: useLlm,
        })
      : null;

    return jsonResponse({
      ok: true,
      run,
      requires_client_side_persist: hasClientContext && !allowPlaintextPersist,
      period,
      date_from: fromDay,
      date_to: toDay,
      used_llm: useLlm,
      data_summary: {
        tasks_total: snapshot.tasks_overview.total,
        user_goals_total: snapshot.user_goals_overview.total,
        period_days: stats.sufficiency.period_days,
        days_with_tasks: stats.sufficiency.days_with_tasks,
      },
      insights: finalInsights,
    });
  } catch (e) {
    console.error(e);
    return errorResponse("Unhandled error", 500, String(e));
  }
});
