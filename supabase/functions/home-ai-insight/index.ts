import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "@supabase/supabase-js";

type JsonMap = Record<string, unknown>;

type GoalContext = {
  id: string;
  title: string;
  description: string;
  life_block: string;
  importance: number;
  is_completed: boolean;
  spent_hours: number;
  start_time: string;
  deadline: string;
};

type HabitContext = {
  day: string;
  done: boolean;
  value: number;
};

type MoodContext = {
  date: string;
  emoji: string;
  has_note: boolean;
};

type MentalContext = {
  day: string;
  value_bool: boolean | null;
  value_int: number | null;
  has_text: boolean;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(body: JsonMap, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json; charset=utf-8" },
  });
}

function toIsoDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function startOfLocalDay(base = new Date()): Date {
  return new Date(base.getFullYear(), base.getMonth(), base.getDate(), 0, 0, 0, 0);
}

function addDays(date: Date, days: number): Date {
  const copy = new Date(date);
  copy.setDate(copy.getDate() + days);
  return copy;
}

function mondayOfWeek(date: Date): Date {
  const d = startOfLocalDay(date);
  const day = d.getDay();
  const diff = day === 0 ? -6 : 1 - day;
  return addDays(d, diff);
}

function isSunday(date: Date): boolean {
  return date.getDay() === 0;
}

function insightTextFromRow(row: JsonMap): string {
  const insights = asMap(row.insights);
  return asString(insights.insight ?? insights.text ?? row.insight);
}

function asMap(value: unknown): JsonMap {
  if (value && typeof value === "object" && !Array.isArray(value)) {
    return value as JsonMap;
  }
  return {};
}

function asString(value: unknown, fallback = ""): string {
  if (typeof value === "string") return value.trim();
  if (value == null) return fallback;
  return String(value).trim();
}

function asNumber(value: unknown, fallback = 0): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function safePlainPayload(row: JsonMap): JsonMap {
  const payload = asMap(row.encrypted_payload);
  // In encrypted rows this usually contains ciphertext/iv/tag/version.
  // Do not send ciphertext to OpenAI. Only use it when it already looks like plain JSON.
  const technicalKeys = new Set(["ciphertext", "cipher_text", "iv", "tag", "salt", "alg", "algorithm", "version"]);
  if (Object.keys(payload).some((key) => technicalKeys.has(key))) return {};
  return payload;
}

function goalFromRow(row: JsonMap): GoalContext {
  const payload = safePlainPayload(row);
  return {
    id: asString(row.id),
    title: asString(payload.title ?? row.title, "Untitled task"),
    description: asString(payload.description ?? row.description),
    life_block: asString(payload.life_block ?? row.life_block ?? row.lifeBlock ?? "general"),
    importance: Math.max(1, Math.min(3, Math.round(asNumber(payload.importance ?? row.importance, 1)))),
    is_completed: row.is_completed === true,
    spent_hours: asNumber(payload.spent_hours ?? row.spent_hours, 0),
    start_time: asString(row.start_time),
    deadline: asString(row.deadline),
  };
}

function habitFromRow(row: JsonMap): HabitContext {
  const payload = safePlainPayload(row);
  return {
    day: asString(row.day),
    done: (payload.done ?? row.done) === true,
    value: Math.max(0, Math.round(asNumber(payload.value ?? row.value, 0))),
  };
}

function moodFromRow(row: JsonMap): MoodContext {
  const payload = safePlainPayload(row);
  return {
    date: asString(row.date),
    emoji: asString(payload.emoji ?? row.emoji, ""),
    has_note: asString(payload.note ?? row.note).length > 0,
  };
}

function mentalFromRow(row: JsonMap): MentalContext {
  const payload = safePlainPayload(row);
  const valueText = asString(payload.value_text ?? row.value_text);
  const rawBool = payload.value_bool ?? row.value_bool;
  const rawInt = payload.value_int ?? row.value_int;
  return {
    day: asString(row.day),
    value_bool: typeof rawBool === "boolean" ? rawBool : null,
    value_int: rawInt == null ? null : Math.round(asNumber(rawInt, 0)),
    has_text: valueText.length > 0,
  };
}

function completionRate(goals: GoalContext[]): number {
  if (!goals.length) return 0;
  return Math.round((goals.filter((goal) => goal.is_completed).length / goals.length) * 100);
}

function doneHabitsCount(habits: HabitContext[]): number {
  return habits.filter((habit) => habit.done).length;
}

function averageMentalScore(items: MentalContext[]): number | null {
  const values = items
    .map((item) => item.value_int)
    .filter((value): value is number => typeof value === "number" && Number.isFinite(value));
  if (!values.length) return null;
  return Math.round((values.reduce((sum, value) => sum + value, 0) / values.length) * 10) / 10;
}

function compactGoals(goals: GoalContext[]): JsonMap[] {
  return goals.slice(0, 10).map((goal) => ({
    title: goal.title,
    life_block: goal.life_block,
    importance: goal.importance,
    is_completed: goal.is_completed,
    spent_hours: goal.spent_hours,
  }));
}

function buildFallbackInsight(locale: string, source: string, context: JsonMap): string {
  const isRu = locale.toLowerCase().startsWith("ru");
  const goals = (context.goals_today as JsonMap[] | undefined) ?? [];
  const done = asNumber(context.goals_today_done, 0);
  const total = goals.length;

  if (total > 0) {
    const next = goals.find((goal) => goal.is_completed !== true);
    if (isRu) {
      return next
        ? `Сегодня у тебя ${done} из ${total} задач выполнено. Начни с «${asString(next.title, "следующей задачи")}» — это поможет быстрее вернуть день под контроль.`
        : `Сегодня все ${total} задачи уже закрыты. Хороший момент зафиксировать результат и не перегружать вечер новыми делами.`;
    }
    return next
      ? `You have completed ${done} of ${total} tasks today. Start with “${asString(next.title, "the next task")}” to bring the day back under control.`
      : `All ${total} tasks are already completed today. It may be a good moment to record the result and avoid overloading the evening.`;
  }

  const weekCompletion = asNumber(context.previous_period_completion_rate, 0);
  const habitDone = asNumber(context.previous_period_habits_done, 0);
  const habitTotal = asNumber(context.previous_period_habits_total, 0);

  if (isRu) {
    if (source === "previous_week") {
      return `На сегодня задач нет, поэтому я посмотрел прошлую неделю: выполнение задач — ${weekCompletion}%, привычки — ${habitDone}/${habitTotal}. Выбери одну маленькую задачу на сегодня, чтобы сохранить ритм.`;
    }
    return `На сегодня задач нет. Можно использовать этот день как лёгкий: добавь одну короткую задачу или отметь настроение, чтобы AI-наблюдения стали точнее.`;
  }

  if (source === "previous_week") {
    return `There are no tasks today, so I reviewed last week: task completion was ${weekCompletion}% and habits were ${habitDone}/${habitTotal}. Pick one small task today to keep the rhythm.`;
  }
  return `There are no tasks today. Use the day lightly: add one short task or log your mood so AI observations become more accurate.`;
}

async function generateWithOpenAI(params: {
  apiKey: string;
  model: string;
  locale: string;
  source: string;
  context: JsonMap;
}): Promise<string> {
  const system = [
    "You generate a short home-screen insight for a self-management app called Ladna.",
    "Return one concise insight only. No markdown. No bullet points.",
    "Use the user's locale. For ru, write in natural Russian.",
    "Do not invent facts beyond the provided JSON.",
    "Do not provide medical, diagnostic, therapy, financial, or legal advice.",
    "If data is sparse, say that the insight is based on limited data and suggest one small next action.",
    "Length: 1-2 sentences, max 220 characters for Russian or max 180 chars for English-like languages.",
  ].join(" ");

  const user = JSON.stringify({
    locale: params.locale,
    source: params.source,
    data: params.context,
  });

  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${params.apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: params.model,
      temperature: 0.4,
      max_tokens: 140,
      messages: [
        { role: "system", content: system },
        { role: "user", content: user },
      ],
    }),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`OpenAI request failed: ${response.status} ${text}`);
  }

  const data = await response.json();
  const content = data?.choices?.[0]?.message?.content;
  return typeof content === "string" ? content.trim() : "";
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ ok: false, error: "Method not allowed" }, 405);

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader.toLowerCase().startsWith("bearer ")) {
      return jsonResponse({ ok: false, error: "Missing Authorization header" }, 401);
    }

    const body = await req.json().catch(() => ({}));
    const locale = asString((body as JsonMap).locale, "ru");

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? Deno.env.get("SUPABASE_PUBLISHABLE_KEY");
    const openAiKey = Deno.env.get("OPENAI_API_KEY");
    const model = Deno.env.get("OPENAI_MODEL") ?? "gpt-4o-mini";

    if (!supabaseUrl || !supabaseAnonKey) {
      return jsonResponse({ ok: false, error: "Missing Supabase environment variables" }, 500);
    }
    if (!openAiKey) {
      return jsonResponse({ ok: false, error: "Missing OPENAI_API_KEY" }, 500);
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false },
    });

    const { data: userData, error: userError } = await supabase.auth.getUser();
    if (userError || !userData?.user) {
      return jsonResponse({ ok: false, error: "Unauthorized" }, 401);
    }
    const userId = userData.user.id;

    const today = startOfLocalDay();
    const tomorrow = addDays(today, 1);
    const yesterday = addDays(today, -1);
    const weekStart = mondayOfWeek(today);
    const previousWeekStart = addDays(weekStart, -7);
    const previousWeekEnd = weekStart;

    const todayStartIso = today.toISOString();
    const tomorrowIso = tomorrow.toISOString();
    const todayDate = toIsoDate(today);
    const yesterdayDate = toIsoDate(yesterday);
    const currentWeekStartDate = toIsoDate(weekStart);
    const currentWeekEndDate = toIsoDate(addDays(weekStart, 6));
    const previousWeekStartDate = toIsoDate(previousWeekStart);
    const previousWeekEndDate = toIsoDate(addDays(previousWeekEnd, -1));

    const [goalsByStartRes, goalsByDeadlineRes] = await Promise.all([
      supabase
        .from("goals")
        .select("id,title,description,deadline,is_completed,life_block,importance,emotion,spent_hours,start_time,user_goal_id,encrypted_payload")
        .eq("user_id", userId)
        .gte("start_time", todayStartIso)
        .lt("start_time", tomorrowIso)
        .order("importance", { ascending: false })
        .limit(12),
      supabase
        .from("goals")
        .select("id,title,description,deadline,is_completed,life_block,importance,emotion,spent_hours,start_time,user_goal_id,encrypted_payload")
        .eq("user_id", userId)
        .gte("deadline", todayStartIso)
        .lt("deadline", tomorrowIso)
        .order("importance", { ascending: false })
        .limit(12),
    ]);

    if (goalsByStartRes.error) throw goalsByStartRes.error;
    if (goalsByDeadlineRes.error) throw goalsByDeadlineRes.error;

    const seen = new Set<string>();
    const todayGoals = [...(goalsByStartRes.data ?? []), ...(goalsByDeadlineRes.data ?? [])]
      .map((row) => goalFromRow(row as JsonMap))
      .filter((goal) => {
        if (!goal.id || seen.has(goal.id)) return false;
        seen.add(goal.id);
        return true;
      })
      .sort((a, b) => Number(b.importance) - Number(a.importance));

    let source = "today_goals";
    let context: JsonMap;

    if (todayGoals.length > 0) {
      context = {
        goals_today: compactGoals(todayGoals),
        goals_today_total: todayGoals.length,
        goals_today_done: todayGoals.filter((goal) => goal.is_completed).length,
        goals_today_completion_rate: completionRate(todayGoals),
      };
    } else {
      const [previousGoalsRes, yesterdayGoalsRes, habitsRes, mentalRes, moodsRes, userGoalsRes] = await Promise.all([
        supabase
          .from("goals")
          .select("id,title,description,deadline,is_completed,life_block,importance,emotion,spent_hours,start_time,user_goal_id,encrypted_payload")
          .eq("user_id", userId)
          .gte("start_time", previousWeekStart.toISOString())
          .lt("start_time", previousWeekEnd.toISOString())
          .order("start_time", { ascending: false })
          .limit(25),
        supabase
          .from("goals")
          .select("id,title,description,deadline,is_completed,life_block,importance,emotion,spent_hours,start_time,user_goal_id,encrypted_payload")
          .eq("user_id", userId)
          .gte("start_time", yesterday.toISOString())
          .lt("start_time", today.toISOString())
          .order("importance", { ascending: false })
          .limit(12),
        supabase
          .from("habit_entries")
          .select("day,done,value,encrypted_payload")
          .eq("user_id", userId)
          .gte("day", previousWeekStartDate)
          .lte("day", previousWeekEndDate)
          .limit(200),
        supabase
          .from("mental_answers")
          .select("day,value_bool,value_int,value_text,encrypted_payload")
          .eq("user_id", userId)
          .gte("day", previousWeekStartDate)
          .lte("day", previousWeekEndDate)
          .limit(200),
        supabase
          .from("moods")
          .select("date,emoji,note,encrypted_payload")
          .eq("user_id", userId)
          .gte("date", previousWeekStartDate)
          .lte("date", todayDate)
          .order("date", { ascending: false })
          .limit(12),
        supabase
          .from("user_goals")
          .select("id,life_block,horizon,title,description,target_date,is_completed,encrypted_payload")
          .eq("user_id", userId)
          .eq("is_completed", false)
          .order("sort_order", { ascending: true })
          .limit(8),
      ]);

      for (const result of [previousGoalsRes, yesterdayGoalsRes, habitsRes, mentalRes, moodsRes, userGoalsRes]) {
        if (result.error) throw result.error;
      }

      const previousGoals = (previousGoalsRes.data ?? []).map((row) => goalFromRow(row as JsonMap));
      const yesterdayGoals = (yesterdayGoalsRes.data ?? []).map((row) => goalFromRow(row as JsonMap));
      const habits = (habitsRes.data ?? []).map((row) => habitFromRow(row as JsonMap));
      const mental = (mentalRes.data ?? []).map((row) => mentalFromRow(row as JsonMap));
      const moods = (moodsRes.data ?? []).map((row) => moodFromRow(row as JsonMap));
      const activeUserGoals = (userGoalsRes.data ?? []).map((row) => {
        const map = row as JsonMap;
        const payload = safePlainPayload(map);
        return {
          title: asString(payload.title ?? map.title, "Untitled goal"),
          life_block: asString(payload.life_block ?? map.life_block, "general"),
          horizon: asString(payload.horizon ?? map.horizon, ""),
          target_date: asString(map.target_date),
        };
      });

      source = previousGoals.length > 0 || habits.length > 0 || mental.length > 0 || moods.length > 0
        ? "previous_week"
        : "sparse";

      context = {
        today_date: todayDate,
        yesterday_date: yesterdayDate,
        previous_week: { from: previousWeekStartDate, to: previousWeekEndDate },
        yesterday_goals: compactGoals(yesterdayGoals),
        previous_period_goals_total: previousGoals.length,
        previous_period_goals_done: previousGoals.filter((goal) => goal.is_completed).length,
        previous_period_completion_rate: completionRate(previousGoals),
        previous_period_spent_hours: Math.round(previousGoals.reduce((sum, goal) => sum + goal.spent_hours, 0) * 10) / 10,
        previous_period_habits_done: doneHabitsCount(habits),
        previous_period_habits_total: habits.length,
        previous_period_mental_avg: averageMentalScore(mental),
        recent_moods: moods,
        active_user_goals: activeUserGoals,
      };
    }

    const fallback = buildFallbackInsight(locale, source, context);
    let insight = fallback;
    let aiUsed = false;
    let cached = false;

    try {
      const { data: existingRows, error: existingError } = await supabase
        .from("ai_insights_runs")
        .select("id,insights,created_at")
        .eq("user_id", userId)
        .eq("period", "home_weekly")
        .eq("date_from", currentWeekStartDate)
        .eq("date_to", currentWeekEndDate)
        .order("created_at", { ascending: false })
        .limit(1);

      if (!existingError && existingRows && existingRows.length > 0) {
        const cachedText = insightTextFromRow(existingRows[0] as JsonMap);
        if (cachedText.length >= 10) {
          insight = cachedText;
          aiUsed = true;
          cached = true;
        }
      } else if (existingError) {
        console.error("home-ai-insight cache lookup skipped:", existingError);
      }
    } catch (error) {
      console.error("home-ai-insight cache lookup failed:", error);
    }

    if (!cached && isSunday(today)) {
      try {
        const aiText = await generateWithOpenAI({ apiKey: openAiKey, model, locale, source, context });
        if (aiText.length >= 10) {
          insight = aiText.replace(/^"|"$/g, "").trim();
          aiUsed = true;
        }
      } catch (error) {
        console.error("home-ai-insight OpenAI fallback:", error);
      }

      try {
        const { error: insertError } = await supabase.from("ai_insights_runs").insert({
          user_id: userId,
          period: "home_weekly",
          date_from: currentWeekStartDate,
          date_to: currentWeekEndDate,
          version: "home_weekly_v1",
          model: aiUsed ? model : "fallback",
          snapshot: context,
          stats: { source, fallback, ai_used: aiUsed },
          insights: { insight, source, ai_used: aiUsed, generated_at: new Date().toISOString() },
        });
        if (insertError) console.error("home-ai-insight history insert skipped:", insertError);
      } catch (error) {
        console.error("home-ai-insight history insert failed:", error);
      }
    }

    return jsonResponse({
      ok: true,
      insight,
      source: cached ? "home_weekly_cached" : source,
      ai_used: aiUsed,
      cached,
      weekly_ai_day: isSunday(today),
      generated_at: new Date().toISOString(),
    });
  } catch (error) {
    console.error("home-ai-insight error:", error);
    return jsonResponse({ ok: false, error: error instanceof Error ? error.message : String(error) }, 500);
  }
});
