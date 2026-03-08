// supabase/functions/ai-planner/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ─────────────────────────────────────────────────────────────
// Env
// ─────────────────────────────────────────────────────────────
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? Deno.env.get("PROJECT_URL");
const SERVICE_ROLE_KEY = Deno.env.get("SERVICE_ROLE_KEY");

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
const OPENAI_MODEL = Deno.env.get("OPENAI_MODEL") ?? "gpt-4.1-mini";

if (!SUPABASE_URL) console.error("[ai-planner] Missing SUPABASE_URL (or PROJECT_URL)");
if (!SERVICE_ROLE_KEY) console.error("[ai-planner] Missing SERVICE_ROLE_KEY");

const admin = createClient(SUPABASE_URL!, SERVICE_ROLE_KEY!, {
  auth: { persistSession: false },
});

// ─────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────
type Horizon = "week" | "month";

type UserGoalRow = {
  id: string;
  life_block: string | null;
  horizon: string;
  title: string;
  description: string | null;
  target_date: string | null;
  is_completed: boolean;
  sort_order: number;
  created_at: string;
  updated_at: string;
};

type GoalTaskRow = {
  id: string;
  title: string | null;
  description: string | null;
  life_block: string | null;
  importance: number | null;
  is_completed: boolean | null;
  deadline: string | null;
  start_time: string | null;
  created_at: string | null;
  spent_hours: number | null;
};

type PlanItem = {
  title: string;
  description: string;
  life_block: string;
  importance: 1 | 2 | 3;
  start_time: string;
  planned_hours: number;
  reason: string;
};

type SnapshotOk = {
  ok: true;
  horizon: Horizon;
  window: {
    from: string;
    to: string;
    planning_days: number;
    days: string[];
  };
  profile: {
    profile_source: "users.id" | "users.user_id" | "not_found";
    archetype: string | null;
    target_hours_per_day: number | null;
    priorities: unknown;
    life_blocks: unknown;
  };
  user_goals: Array<{
    id: string;
    horizon: string;
    life_block: string;
    title: string;
    description: string;
    target_date: string | null;
    updated_at: string;
  }>;
  latest_insights_run: null | {
    id: string;
    created_at: string;
    period: string;
    date_from: string;
    date_to: string;
    version: string;
    insights: unknown;
    stats: unknown;
  };
  workload_by_day: Array<{
    day: string;
    existing_count: number;
    existing_hours_est: number;
  }>;
  recent_task_titles_norm: string[];
  task_patterns: {
    time_preference: Array<{
      bucket: string;
      completion_ratio: number;
      n: number;
    }>;
    by_life_block_60d: Record<
      string,
      {
        tasks_total_60d: number;
        completion_ratio_60d: number;
        spent_hours_sum_60d: number;
      }
    >;
  };
  habits_summary_30d: Array<{
    name: string;
    done_days_30d: number;
    value_sum_30d: number;
  }>;
  mental_coverage_30d: Array<{
    code: string;
    days_with_answers_30d: number;
  }>;
  upcoming_tasks_in_window: Array<{
    id: string;
    title: string;
    life_block: string;
    start_time: string | null;
    deadline: string | null;
    importance: number;
  }>;
};

type SnapshotFail = {
  ok: false;
  reason: string;
  hint?: string;
  debug?: Record<string, unknown>;
};

type Snapshot = SnapshotOk | SnapshotFail;

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────
function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
    },
  });
}

function errorResponse(
  code: string,
  message: string,
  status = 400,
  details?: unknown,
) {
  return jsonResponse(
    {
      ok: false,
      code,
      message,
      details: details ?? null,
    },
    status,
  );
}

function dateOnlyISO(d: Date) {
  return d.toISOString().slice(0, 10);
}

function safeNum(n: unknown, fallback = 0) {
  const x = Number(n);
  return Number.isFinite(x) ? x : fallback;
}

function horizonToDays(h: string): number {
  return String(h).toLowerCase() === "month" ? 30 : 7;
}

function clamp(n: number, min: number, max: number) {
  return Math.max(min, Math.min(max, n));
}

function timeBucket(hour: number) {
  if (hour >= 5 && hour <= 11) return "morning";
  if (hour >= 12 && hour <= 17) return "afternoon";
  if (hour >= 18 && hour <= 23) return "evening";
  return "night";
}

function normalizeTitle(s: unknown) {
  return String(s ?? "")
    .trim()
    .toLowerCase()
    .replace(/\s+/g, " ");
}

function isValidDateTime(s: string) {
  const t = Date.parse(s);
  return Number.isFinite(t);
}

function startOfDay(d: Date) {
  const x = new Date(d);
  x.setHours(0, 0, 0, 0);
  return x;
}

function endOfDay(d: Date) {
  const x = new Date(d);
  x.setHours(23, 59, 59, 999);
  return x;
}

function addDays(d: Date, days: number) {
  const x = new Date(d);
  x.setDate(x.getDate() + days);
  return x;
}

function mean(arr: number[]) {
  if (!arr.length) return null;
  return arr.reduce((a, b) => a + b, 0) / arr.length;
}

function isWithinWindow(iso: string, fromISO: string, toISO: string) {
  const t = Date.parse(iso);
  const a = Date.parse(fromISO);
  const b = Date.parse(toISO);
  return Number.isFinite(t) && Number.isFinite(a) && Number.isFinite(b) && t >= a && t <= b;
}

// Только точное совпадение, без агрессивного fuzzy matching
function isTooSimilar(title: string, existingTitlesNorm: Set<string>) {
  const t = normalizeTitle(title);
  if (!t) return true;
  return existingTitlesNorm.has(t);
}

// Minimal item normalization to protect inserts
function normalizeItem(raw: any): PlanItem | null {
  const title = String(raw?.title ?? "").trim();
  if (!title) return null;

  const description = String(raw?.description ?? "").trim();
  const life_block = String(raw?.life_block ?? "general").trim() || "general";

  let importance = Number(raw?.importance ?? 1);
  if (![1, 2, 3].includes(importance)) importance = 1;

  const planned_hours = clamp(safeNum(raw?.planned_hours, 1), 0.25, 6);
  const reason = String(raw?.reason ?? "").trim();

  const start_time = String(raw?.start_time ?? "").trim();
  if (!start_time || !isValidDateTime(start_time)) return null;

  return {
    title,
    description,
    life_block,
    importance: importance as 1 | 2 | 3,
    start_time,
    planned_hours,
    reason,
  };
}

// ─────────────────────────────────────────────────────────────
// Profile resolver
// Supports both:
// - public.users.id = auth.users.id
// - public.users.user_id = auth.users.id
// ─────────────────────────────────────────────────────────────
async function resolveUserProfile(authUserId: string) {
  // 1) direct match on users.id
  const { data: rowById, error: errById } = await admin
    .from("users")
    .select("id,user_id,archetype,target_hours,priorities,life_blocks")
    .eq("id", authUserId)
    .maybeSingle();

  if (errById) {
    throw new Error(`users select by id failed: ${errById.message}`);
  }
  if (rowById) {
    return {
      profileSource: "users.id" as const,
      row: rowById,
    };
  }

  // 2) fallback match on users.user_id
  const { data: rowByUserId, error: errByUserId } = await admin
    .from("users")
    .select("id,user_id,archetype,target_hours,priorities,life_blocks")
    .eq("user_id", authUserId)
    .maybeSingle();

  if (errByUserId) {
    // column may not exist or query may fail depending on schema
    console.warn("[ai-planner] users select by user_id failed:", errByUserId.message);
  }

  if (rowByUserId) {
    return {
      profileSource: "users.user_id" as const,
      row: rowByUserId,
    };
  }

  return {
    profileSource: "not_found" as const,
    row: null,
  };
}

// ─────────────────────────────────────────────────────────────
// Snapshot builder
// ─────────────────────────────────────────────────────────────
async function buildPlanSnapshot(authUserId: string, horizon: Horizon): Promise<Snapshot> {
  const days = horizonToDays(horizon);

  const now = new Date();
  const planFrom = startOfDay(now);
  const planTo = endOfDay(addDays(planFrom, days - 1));

  const historyFrom = startOfDay(addDays(planFrom, -60));
  const insightsLookbackFrom = startOfDay(addDays(planFrom, -30));
  const habitsFrom = startOfDay(addDays(planFrom, -30));

  console.log("[ai-planner] buildPlanSnapshot authUserId =", authUserId);
  console.log("[ai-planner] window =", {
    from: planFrom.toISOString(),
    to: planTo.toISOString(),
    days,
  });

  // 0) user profile
  const { profileSource, row: userRow } = await resolveUserProfile(authUserId);
  console.log("[ai-planner] profileSource =", profileSource);

  // 1) user_goals
  const { data: userGoals, error: ugErr } = await admin
    .from("user_goals")
    .select("id,life_block,horizon,title,description,target_date,is_completed,sort_order,created_at,updated_at")
    .eq("user_id", authUserId)
    .order("sort_order", { ascending: true })
    .order("created_at", { ascending: false });

  if (ugErr) throw new Error(`user_goals select failed: ${ugErr.message}`);

  const activeGoals = ((userGoals ?? []) as UserGoalRow[]).filter((g) => !g.is_completed);
  console.log("[ai-planner] activeGoals =", activeGoals.length);

  if (activeGoals.length === 0) {
    return {
      ok: false,
      reason: "У пользователя нет активных целей в user_goals.",
      hint: "Добавь 1–3 активные цели и попробуй снова.",
      debug: {
        auth_user_id: authUserId,
        profile_source: profileSource,
        user_goals_count: (userGoals ?? []).length,
      },
    };
  }

  // 2) latest ai_insights run
  const { data: insightsRun, error: irErr } = await admin
    .from("ai_insights_runs")
    .select("id,created_at,period,date_from,date_to,version,model,stats,insights,snapshot")
    .eq("user_id", authUserId)
    .gte("created_at", insightsLookbackFrom.toISOString())
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (irErr) throw new Error(`ai_insights_runs select failed: ${irErr.message}`);

  // 3) tasks history + planning window
  const { data: tasks, error: tasksErr } = await admin
    .from("goals")
    .select("id,title,description,life_block,importance,is_completed,deadline,start_time,created_at,spent_hours")
    .eq("user_id", authUserId)
    .gte("start_time", historyFrom.toISOString())
    .lte("start_time", planTo.toISOString())
    .order("start_time", { ascending: true });

  if (tasksErr) throw new Error(`goals select failed: ${tasksErr.message}`);

  const allTasks = ((tasks ?? []) as GoalTaskRow[]).filter((t) => !!t.start_time && isValidDateTime(String(t.start_time)));
  const historyTasks = allTasks.filter((t) => Date.parse(String(t.start_time)) < planFrom.getTime());
  const upcomingTasks = allTasks.filter((t) => Date.parse(String(t.start_time)) >= planFrom.getTime());

  console.log("[ai-planner] tasks =", {
    all: allTasks.length,
    history: historyTasks.length,
    upcoming: upcomingTasks.length,
  });

  // 4) habits
  const { data: habits, error: hErr } = await admin
    .from("habits")
    .select("id,title,is_negative,created_at")
    .eq("user_id", authUserId);

  if (hErr) throw new Error(`habits select failed: ${hErr.message}`);

  const habitTitleById = new Map<string, string>();
  (habits ?? []).forEach((h: any) => habitTitleById.set(h.id, h.title));

  const { data: habitEntries, error: heErr } = await admin
    .from("habit_entries")
    .select("habit_id,day,done,value")
    .eq("user_id", authUserId)
    .gte("day", dateOnlyISO(habitsFrom))
    .lte("day", dateOnlyISO(now));

  if (heErr) throw new Error(`habit_entries select failed: ${heErr.message}`);

  // 5) mental answers
  const { data: questions, error: qErr } = await admin
    .from("mental_questions")
    .select("id,code,answer_type,is_active");

  if (qErr) throw new Error(`mental_questions select failed: ${qErr.message}`);

  const qById = new Map<string, { code: string; type: string }>();
  (questions ?? []).forEach((q: any) => qById.set(q.id, { code: q.code, type: q.answer_type }));

  const { data: answers, error: aErr } = await admin
    .from("mental_answers")
    .select("day,question_id,value_bool,value_int,value_text")
    .eq("user_id", authUserId)
    .gte("day", dateOnlyISO(habitsFrom))
    .lte("day", dateOnlyISO(now));

  if (aErr) throw new Error(`mental_answers select failed: ${aErr.message}`);

  // ─────────────────────────────────────────────
  // Aggregations for planning realism
  // ─────────────────────────────────────────────

  const loadByDay = new Map<string, { count: number; hours: number }>();
  for (const t of upcomingTasks) {
    if (t.is_completed) continue;
    const d = String(t.start_time).slice(0, 10);
    const rec = loadByDay.get(d) ?? { count: 0, hours: 0 };
    rec.count += 1;

    const est =
      safeNum(t.spent_hours, 0) > 0
        ? safeNum(t.spent_hours, 0)
        : Number(t.importance ?? 1) === 3
        ? 1.5
        : Number(t.importance ?? 1) === 2
        ? 1.0
        : 0.5;

    rec.hours += clamp(est, 0, 6);
    loadByDay.set(d, rec);
  }

  const bucketDone: Record<string, number> = { morning: 0, afternoon: 0, evening: 0, night: 0 };
  const bucketTotal: Record<string, number> = { morning: 0, afternoon: 0, evening: 0, night: 0 };

  const byBlock = new Map<string, { total: number; done: number; hours: number }>();

  for (const t of historyTasks) {
    const st = new Date(String(t.start_time));
    const b = timeBucket(st.getHours());
    bucketTotal[b] += 1;
    if (t.is_completed) bucketDone[b] += 1;

    const lb = String(t.life_block ?? "general");
    const rec = byBlock.get(lb) ?? { total: 0, done: 0, hours: 0 };
    rec.total += 1;
    if (t.is_completed) rec.done += 1;
    rec.hours += safeNum(t.spent_hours, 0);
    byBlock.set(lb, rec);
  }

  const timePreference = Object.keys(bucketTotal)
    .map((k) => ({
      bucket: k,
      completion_ratio: bucketTotal[k]
        ? bucketDone[k] / bucketTotal[k]
        : 0,
      n: bucketTotal[k],
    }))
    .sort((a, b) => b.completion_ratio - a.completion_ratio);

  const blockStats: Record<string, { tasks_total_60d: number; completion_ratio_60d: number; spent_hours_sum_60d: number }> = {};
  for (const [k, v] of byBlock.entries()) {
    blockStats[k] = {
      tasks_total_60d: v.total,
      completion_ratio_60d: v.total ? v.done / v.total : 0,
      spent_hours_sum_60d: v.hours,
    };
  }

  const recentTitlesNorm = new Set<string>();
  for (const t of allTasks.slice(-250)) {
    const nt = normalizeTitle(t.title);
    if (nt) recentTitlesNorm.add(nt);
  }

  const habitDoneDays = new Map<string, number>();
  const habitValueSum = new Map<string, number>();
  for (const e of habitEntries ?? []) {
    const name = habitTitleById.get(e.habit_id) ?? String(e.habit_id);
    if (e.done) habitDoneDays.set(name, (habitDoneDays.get(name) ?? 0) + 1);
    habitValueSum.set(name, (habitValueSum.get(name) ?? 0) + safeNum(e.value, 0));
  }

  const habitsSummary = Array.from(habitTitleById.values()).map((name) => ({
    name,
    done_days_30d: habitDoneDays.get(name) ?? 0,
    value_sum_30d: habitValueSum.get(name) ?? 0,
  }));

  const mentalDaysByCode = new Map<string, Set<string>>();
  for (const a of answers ?? []) {
    const meta = qById.get(a.question_id);
    if (!meta) continue;

    if (
      a.value_bool === null &&
      a.value_int === null &&
      !String(a.value_text ?? "").trim()
    ) {
      continue;
    }

    const set = mentalDaysByCode.get(meta.code) ?? new Set<string>();
    set.add(String(a.day));
    mentalDaysByCode.set(meta.code, set);
  }

  const mentalCoverage = Array.from(mentalDaysByCode.entries()).map(([code, set]) => ({
    code,
    days_with_answers_30d: set.size,
  }));

  const targetHoursRaw = userRow?.target_hours;
  const targetHours =
    targetHoursRaw === null || targetHoursRaw === undefined
      ? null
      : safeNum(targetHoursRaw, 0);

  const windowDays: string[] = [];
  for (let i = 0; i < days; i++) {
    windowDays.push(dateOnlyISO(addDays(planFrom, i)));
  }

  const workloadByDay = windowDays.map((d) => ({
    day: d,
    existing_count: loadByDay.get(d)?.count ?? 0,
    existing_hours_est: Number((loadByDay.get(d)?.hours ?? 0).toFixed(2)),
  }));

  return {
    ok: true,
    horizon,
    window: {
      from: planFrom.toISOString(),
      to: planTo.toISOString(),
      planning_days: days,
      days: windowDays,
    },
    profile: {
      profile_source: profileSource,
      archetype: userRow?.archetype ?? null,
      target_hours_per_day: targetHours,
      priorities: userRow?.priorities ?? null,
      life_blocks: userRow?.life_blocks ?? null,
    },
    user_goals: activeGoals.map((g) => ({
      id: g.id,
      horizon: g.horizon,
      life_block: g.life_block ?? "general",
      title: g.title,
      description: g.description ?? "",
      target_date: g.target_date ?? null,
      updated_at: g.updated_at,
    })),
    latest_insights_run: insightsRun
      ? {
          id: insightsRun.id,
          created_at: insightsRun.created_at,
          period: insightsRun.period,
          date_from: insightsRun.date_from,
          date_to: insightsRun.date_to,
          version: insightsRun.version,
          insights: insightsRun.insights ?? [],
          stats: insightsRun.stats ?? {},
        }
      : null,
    workload_by_day: workloadByDay,
    recent_task_titles_norm: Array.from(recentTitlesNorm).slice(0, 200),
    task_patterns: {
      time_preference: timePreference,
      by_life_block_60d: blockStats,
    },
    habits_summary_30d: habitsSummary,
    mental_coverage_30d: mentalCoverage,
    upcoming_tasks_in_window: upcomingTasks
      .filter((t) => !t.is_completed)
      .slice(0, 120)
      .map((t) => ({
        id: t.id,
        title: t.title ?? "",
        life_block: t.life_block ?? "general",
        start_time: t.start_time,
        deadline: t.deadline,
        importance: Number(t.importance ?? 1),
      })),
  };
}

// ─────────────────────────────────────────────────────────────
// Prompt + LLM
// ─────────────────────────────────────────────────────────────
const SYSTEM_PROMPT = `Ты — строгий AI-планировщик для приложения самоменеджмента.

Требования:
- План строится ОТ user_goals. Каждая предлагаемая задача должна иметь понятную связь с одной или несколькими целями.
- Используй ТОЛЬКО данные snapshot.
- Не выдумывай факты.
- Если используешь инсайты, формулируй осторожно: "наблюдалась ассоциация", "есть тенденция", "по данным периода".
- План должен быть реалистичным: не перегружай дни, учитывай текущую нагрузку и привычное время успешного выполнения.
- Не предлагай дубликаты уже существующих задач.
- Каждая задача обязана иметь start_time в ISO datetime внутри окна snapshot.window.
- Максимум: week=12 задач, month=20 задач.
- Верни ТОЛЬКО валидный JSON-объект вида {"items":[...]} без markdown и без пояснительного текста.`;

async function callPlanLLM(snapshot: SnapshotOk) {
  if (!OPENAI_API_KEY) {
    throw new Error("Missing OPENAI_API_KEY");
  }

  const userPrompt = `Сгенерируй план задач.

Схема ответа (СТРОГО):
{
  "items": [
    {
      "title": "string",
      "description": "string",
      "life_block": "string",
      "importance": 1,
      "start_time": "2026-03-10T18:00:00.000Z",
      "planned_hours": 1.0,
      "reason": "короткое объяснение связи с целями и почему задача уместна"
    }
  ]
}

Ограничения:
- Делай конкретные действия, без абстрактных формулировок.
- planned_hours обычно 0.5..2.0, редко до 3.0.
- Выбирай дни с меньшей нагрузкой по snapshot.workload_by_day.
- Учитывай snapshot.task_patterns.time_preference.
- Используй snapshot.latest_insights_run только как мягкий контекст, а не как доказанный факт.
- Если данных мало, делай более консервативный и короткий план.
- Избегай названий, совпадающих с snapshot.recent_task_titles_norm.
- start_time должен попадать внутрь snapshot.window.
- Если целей много, выбери 2–4 ключевые и сделай по ним шаги.

Данные snapshot:
${JSON.stringify(snapshot)}`;

  const r = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${OPENAI_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: OPENAI_MODEL,
      input: [
        {
          role: "system",
          content: [{ type: "input_text", text: SYSTEM_PROMPT }],
        },
        {
          role: "user",
          content: [{ type: "input_text", text: userPrompt }],
        },
      ],
      text: {
        format: {
          type: "json_object",
        },
      },
    }),
  });

  if (!r.ok) {
    const errText = await r.text();
    throw new Error(`LLM request failed: ${errText}`);
  }

  const data = await r.json();

  let outputText: string | null = null;

  if (typeof data?.output_text === "string" && data.output_text.trim()) {
    outputText = data.output_text.trim();
  }

  if (!outputText && Array.isArray(data?.output)) {
    for (const out of data.output) {
      const contents = Array.isArray(out?.content) ? out.content : [];
      for (const c of contents) {
        if (typeof c?.text === "string" && c.text.trim()) {
          outputText = c.text.trim();
          break;
        }
      }
      if (outputText) break;
    }
  }

  if (!outputText) {
    console.error("[ai-planner] bad LLM response shape:", JSON.stringify(data));
    throw new Error("Bad LLM response shape");
  }

  let parsed: any;
  try {
    parsed = JSON.parse(outputText);
  } catch {
    console.error("[ai-planner] LLM output not JSON:", outputText);
    throw new Error("LLM output is not valid JSON");
  }

  const items: any[] | null =
    Array.isArray(parsed?.items)
      ? parsed.items
      : Array.isArray(parsed)
      ? parsed
      : Array.isArray(parsed?.plan)
      ? parsed.plan
      : null;

  if (!Array.isArray(items)) {
    console.error("[ai-planner] LLM parsed keys:", parsed ? Object.keys(parsed) : null);
    throw new Error("LLM output does not contain items[]");
  }

  return items;
}

// ─────────────────────────────────────────────────────────────
// Optional local fallback
// ─────────────────────────────────────────────────────────────
function buildFallbackItems(snapshot: SnapshotOk): PlanItem[] {
  const maxItems = snapshot.horizon === "month" ? 6 : 3;
  const preferredBuckets = snapshot.task_patterns.time_preference
    .filter((x) => x.n > 0)
    .map((x) => x.bucket);

  const bucketToHour: Record<string, number> = {
    morning: 9,
    afternoon: 14,
    evening: 19,
    night: 21,
  };

  const existingTitlesNorm = new Set<string>(snapshot.recent_task_titles_norm);
  const loadMap = new Map<string, { count: number; hours: number }>();
  for (const d of snapshot.workload_by_day) {
    loadMap.set(d.day, {
      count: d.existing_count,
      hours: d.existing_hours_est,
    });
  }

  const sortedDays = [...snapshot.workload_by_day].sort((a, b) => {
    if (a.existing_hours_est !== b.existing_hours_est) {
      return a.existing_hours_est - b.existing_hours_est;
    }
    return a.existing_count - b.existing_count;
  });

  const chosenGoals = snapshot.user_goals.slice(0, 4);
  const result: PlanItem[] = [];

  for (let i = 0; i < chosenGoals.length && result.length < maxItems; i++) {
    const goal = chosenGoals[i];
    const dayInfo = sortedDays[i % Math.max(sortedDays.length, 1)];
    if (!dayInfo) break;

    const preferredBucket = preferredBuckets[0] ?? "evening";
    const hour = bucketToHour[preferredBucket] ?? 19;

    const start = new Date(`${dayInfo.day}T00:00:00.000Z`);
    start.setUTCHours(hour, 0, 0, 0);

    const title = `Шаг по цели: ${goal.title}`;
    if (isTooSimilar(title, existingTitlesNorm)) continue;

    result.push({
      title,
      description: goal.description
        ? `Сделать конкретный шаг по цели: ${goal.description}`
        : `Сделать конкретный шаг по цели "${goal.title}".`,
      life_block: goal.life_block || "general",
      importance: 2,
      start_time: start.toISOString(),
      planned_hours: 1,
      reason: `Fallback-план на основе активной цели "${goal.title}" и свободного дня ${dayInfo.day}.`,
    });

    existingTitlesNorm.add(normalizeTitle(title));
  }

  return result;
}

// ─────────────────────────────────────────────────────────────
// Post-filtering & realism guards
// ─────────────────────────────────────────────────────────────
function postFilterItems(
  normalized: PlanItem[],
  snapshot: SnapshotOk,
) {
  const fromISO = snapshot.window.from;
  const toISO = snapshot.window.to;

  const existingTitlesNorm = new Set<string>();
  for (const t of snapshot.upcoming_tasks_in_window ?? []) {
    const nt = normalizeTitle(t.title);
    if (nt) existingTitlesNorm.add(nt);
  }
  for (const nt of snapshot.recent_task_titles_norm ?? []) {
    if (typeof nt === "string" && nt.trim()) existingTitlesNorm.add(nt.trim());
  }

  const maxItems = snapshot.horizon === "month" ? 20 : 12;

  const loadMap = new Map<string, { count: number; hours: number }>();
  for (const d of snapshot.workload_by_day ?? []) {
    loadMap.set(String(d.day), {
      count: Number(d.existing_count ?? 0),
      hours: Number(d.existing_hours_est ?? 0),
    });
  }

  const targetHours = snapshot.profile?.target_hours_per_day;
  const hardHoursCap =
    typeof targetHours === "number" && Number.isFinite(targetHours) && targetHours > 0
      ? clamp(targetHours, 2, 10)
      : 6;

  const kept: PlanItem[] = [];
  const rejected: Array<{ title: string; reason: string }> = [];

  for (const it of normalized) {
    if (kept.length >= maxItems) break;

    if (!isWithinWindow(it.start_time, fromISO, toISO)) {
      rejected.push({ title: it.title, reason: "outside_window" });
      continue;
    }

    if (isTooSimilar(it.title, existingTitlesNorm)) {
      rejected.push({ title: it.title, reason: "duplicate_title" });
      continue;
    }

    const day = String(it.start_time).slice(0, 10);
    const rec = loadMap.get(day) ?? { count: 0, hours: 0 };

    const estH = clamp(safeNum(it.planned_hours, 1), 0.25, 6);
    const countCap = snapshot.horizon === "month" ? 5 : 4;

    if (rec.count >= countCap) {
      rejected.push({ title: it.title, reason: "day_count_overload" });
      continue;
    }

    if (rec.hours + estH > hardHoursCap) {
      rejected.push({ title: it.title, reason: "day_hours_overload" });
      continue;
    }

    kept.push({
      ...it,
      planned_hours: estH,
    });

    existingTitlesNorm.add(normalizeTitle(it.title));
    rec.count += 1;
    rec.hours += estH;
    loadMap.set(day, rec);
  }

  return { kept, rejected };
}

// ─────────────────────────────────────────────────────────────
// Handler
// ─────────────────────────────────────────────────────────────
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return jsonResponse({}, 200);

  try {
    if (!SUPABASE_URL) {
      return errorResponse("missing_supabase_url", "Missing SUPABASE_URL (or PROJECT_URL)", 500);
    }
    if (!SERVICE_ROLE_KEY) {
      return errorResponse("missing_service_role_key", "Missing SERVICE_ROLE_KEY secret", 500);
    }

    const auth = req.headers.get("authorization") ?? "";
    const jwt = auth.startsWith("Bearer ") ? auth.slice(7) : null;
    if (!jwt) {
      return errorResponse("missing_bearer_token", "Missing Authorization bearer token", 401);
    }

    const { data: u, error: uErr } = await admin.auth.getUser(jwt);
    if (uErr || !u?.user) {
      return errorResponse("invalid_token", "Invalid token", 401, uErr?.message ?? null);
    }

    const authUserId = u.user.id;
    const payload = await req.json().catch(() => ({}));
    const horizonRaw = String(payload?.horizon ?? "week").toLowerCase();

    if (horizonRaw !== "week" && horizonRaw !== "month") {
      return errorResponse("invalid_horizon", "Invalid horizon. Use 'week' or 'month'.", 400);
    }

    const horizon = horizonRaw as Horizon;

    console.log("[ai-planner] request start", {
      authUserId,
      horizon,
      hasOpenAiKey: !!OPENAI_API_KEY,
      model: OPENAI_MODEL,
    });

    // 1) snapshot
    const snapshot = await buildPlanSnapshot(authUserId, horizon);
    console.log("[ai-planner] snapshot ok =", snapshot.ok);

    if (!snapshot.ok) {
      return errorResponse(
        "planning_preconditions_not_met",
        "Planning preconditions not met",
        422,
        snapshot,
      );
    }

    console.log("[ai-planner] snapshot stats", {
      goals: snapshot.user_goals.length,
      hasInsights: !!snapshot.latest_insights_run,
      upcoming: snapshot.upcoming_tasks_in_window.length,
      profileSource: snapshot.profile.profile_source,
    });

    // 2) LLM plan or fallback
    let rawItems: any[] = [];
    let generationMode: "llm" | "fallback" = "llm";

    if (!OPENAI_API_KEY) {
      console.warn("[ai-planner] OPENAI_API_KEY missing, using fallback");
      rawItems = buildFallbackItems(snapshot);
      generationMode = "fallback";
    } else {
      try {
        rawItems = await callPlanLLM(snapshot);
      } catch (e) {
        console.error("[ai-planner] LLM failed, using fallback:", String(e));
        rawItems = buildFallbackItems(snapshot);
        generationMode = "fallback";
      }
    }

    console.log("[ai-planner] rawItems =", rawItems.length, "mode =", generationMode);

    // 3) normalize
    const normalized = rawItems
      .map((x: any) => normalizeItem(x))
      .filter((x: PlanItem | null): x is PlanItem => !!x);

    console.log("[ai-planner] normalized =", normalized.length);

    if (normalized.length === 0) {
      return errorResponse(
        "planner_returned_no_valid_items",
        "Planner returned no valid items",
        422,
        {
          generation_mode: generationMode,
          raw_items_count: rawItems.length,
          raw_items_sample: rawItems.slice(0, 5),
        },
      );
    }

    // 4) post-filter
    const { kept: filtered, rejected } = postFilterItems(normalized, snapshot);
    console.log("[ai-planner] filtered =", filtered.length, "rejected =", rejected.length);

    if (filtered.length === 0) {
      return errorResponse(
        "all_items_filtered",
        "Planner returned items, but all were filtered as duplicates, outside window, or overload",
        422,
        {
          generation_mode: generationMode,
          normalized_count: normalized.length,
          rejected_sample: rejected.slice(0, 10),
          normalized_sample: normalized.slice(0, 5),
        },
      );
    }

    // 5) save plan header
    const { data: planRow, error: planErr } = await admin
      .from("ai_plans")
      .insert({
        user_id: authUserId,
        horizon,
        status: "draft",
        snapshot: {
          ...snapshot,
          generation_mode: generationMode,
        },
      })
      .select("id,created_at,horizon,status")
      .single();

    if (planErr) {
      throw new Error(`ai_plans insert failed: ${planErr.message}`);
    }

    const planId = planRow.id as string;

    // 6) save items
    const rows = filtered.map((it) => ({
      plan_id: planId,
      user_id: authUserId,
      title: it.title,
      description: it.description,
      life_block: it.life_block,
      importance: it.importance,
      start_time: it.start_time,
      planned_hours: it.planned_hours,
      reason: it.reason,
      state: "suggested",
    }));

    const { data: savedItems, error: itemsErr } = await admin
      .from("ai_plan_items")
      .insert(rows)
      .select("id,title,description,life_block,importance,start_time,planned_hours,reason,state");

    if (itemsErr) {
      throw new Error(`ai_plan_items insert failed: ${itemsErr.message}`);
    }

    return jsonResponse(
      {
        ok: true,
        plan_id: planId,
        generation_mode: generationMode,
        plan: planRow,
        snapshot,
        items: savedItems ?? [],
        debug: {
          normalized_count: normalized.length,
          filtered_count: filtered.length,
          rejected_count: rejected.length,
        },
      },
      200,
    );
  } catch (e) {
    console.error("[ai-planner] unhandled error:", String(e));
    return errorResponse("unhandled_error", "Unhandled error", 500, String(e));
  }
});