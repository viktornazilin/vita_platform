// supabase/functions/ai-insights/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ─────────────────────────────────────────────────────────────
// Secrets / Env
// ─────────────────────────────────────────────────────────────
// Supabase Edge обычно прокидывает SUPABASE_URL автоматически.
// Но если вдруг нет — можно завести secret PROJECT_URL и читать его как fallback.
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? Deno.env.get("PROJECT_URL");

// ВАЖНО: ты сохранил service role под именем SERVICE_ROLE_KEY (без SUPABASE_*)
const SERVICE_ROLE_KEY = Deno.env.get("SERVICE_ROLE_KEY");

// OpenAI
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
const OPENAI_MODEL = Deno.env.get("OPENAI_MODEL") ?? "gpt-4.1-mini";

if (!SUPABASE_URL) console.error("Missing SUPABASE_URL (or PROJECT_URL)");
if (!SERVICE_ROLE_KEY) console.error("Missing SERVICE_ROLE_KEY");
if (!OPENAI_API_KEY) console.error("Missing OPENAI_API_KEY");

const admin = createClient(SUPABASE_URL!, SERVICE_ROLE_KEY!, {
  auth: { persistSession: false },
});

// ─────────────────────────────────────────────────────────────
// Prompt
// ─────────────────────────────────────────────────────────────
const SYSTEM_PROMPT = `You are an analytical AI system for personal life analytics.
Your task is to detect meaningful patterns in user's real-life data and explain how behaviors/events influence progress toward goals.

Rules:
- No generic advice, no motivational talk.
- Do NOT invent facts. If data is insufficient, output fewer insights.
- Avoid causal claims; use "tends to", "is associated with".
- Every insight must include evidence based on provided aggregated data.
Return ONLY valid JSON (an array of insights). No markdown.`;

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

function errorResponse(message: string, status = 400, details?: unknown) {
  return jsonResponse({ error: message, details }, status);
}

function periodToRange(period: string) {
  const now = new Date();
  const p = (period ?? "last_30_days").toLowerCase();
  const days = p === "last_7_days" ? 7 : p === "last_90_days" ? 90 : 30;
  const from = new Date(now.getTime() - days * 24 * 3600 * 1000);
  return { from, to: now, days };
}

function bucketTimeOfDay(hour: number) {
  if (hour >= 5 && hour <= 11) return "morning";
  if (hour >= 12 && hour <= 17) return "afternoon";
  if (hour >= 18 && hour <= 23) return "evening";
  return "night";
}

function safeNum(n: unknown, fallback = 0) {
  const x = Number(n);
  return Number.isFinite(x) ? x : fallback;
}

// ─────────────────────────────────────────────────────────────
// Snapshot builder: собираем "выжимку" из твоих таблиц
// ─────────────────────────────────────────────────────────────
async function buildSnapshot(userId: string, period: string) {
  const { from, to } = periodToRange(period);

  // 1) Users profile + goals_by_block (онбординг)
  const { data: userRow, error: userErr } = await admin
    .from("users")
    .select(
      "archetype,sleep,activity,energy,stress,target_hours,goals_by_block,priorities,life_blocks",
    )
    .eq("id", userId)
    .maybeSingle();

  if (userErr) throw new Error(`users select failed: ${userErr.message}`);

  // 2) "Goals" table (по твоему коду это фактически задачи/цели с временем)
  const { data: tasks, error: tasksErr } = await admin
    .from("goals")
    .select(
      "id,life_block,importance,is_completed,deadline,start_time,created_at,spent_hours",
    )
    .eq("user_id", userId)
    .gte("start_time", from.toISOString())
    .lte("start_time", to.toISOString());

  if (tasksErr) throw new Error(`goals select failed: ${tasksErr.message}`);

  // 3) Moods
  const { data: moods, error: moodsErr } = await admin
    .from("moods")
    .select("date,emoji")
    .eq("user_id", userId)
    .gte("date", from.toISOString().slice(0, 10))
    .lte("date", to.toISOString().slice(0, 10));

  if (moodsErr) throw new Error(`moods select failed: ${moodsErr.message}`);

  // 4) Transactions (+ categories for names)
  const { data: txs, error: txErr } = await admin
    .from("transactions")
    .select("ts,kind,amount,category_id")
    .eq("user_id", userId)
    .gte("ts", from.toISOString())
    .lte("ts", to.toISOString());

  if (txErr) throw new Error(`transactions select failed: ${txErr.message}`);

  const categoryIds = Array.from(
    new Set((txs ?? []).map((t) => t.category_id).filter(Boolean)),
  ) as string[];

  const categoriesMap = new Map<string, { name: string; kind: string }>();
  if (categoryIds.length > 0) {
    const { data: cats, error: catErr } = await admin
      .from("categories")
      .select("id,name,kind")
      .in("id", categoryIds);

    if (catErr) throw new Error(`categories select failed: ${catErr.message}`);
    (cats ?? []).forEach((c) => categoriesMap.set(c.id, { name: c.name, kind: c.kind }));
  }

  // ── Aggregations ───────────────────────────────────────────
  const totalTasks = (tasks ?? []).length;
  const completedTasks = (tasks ?? []).filter((t) => t.is_completed).length;
  const completedRatio = totalTasks > 0 ? completedTasks / totalTasks : 0;

  const now = new Date();
  const overdueOpen = (tasks ?? []).filter((t) =>
    !t.is_completed && new Date(t.deadline) < now
  ).length;

  // by_time_of_day / by_weekday / by_life_block
  const byTime = new Map<string, { total: number; done: number }>();
  const byWday = new Map<number, { total: number; done: number }>();
  const byBlock = new Map<
    string,
    { count: number; done: number; sumImportance: number; sumHours: number }
  >();

  for (const t of (tasks ?? [])) {
    const st = new Date(t.start_time);
    const hour = st.getHours();
    const bucket = bucketTimeOfDay(hour);

    // JS: 0=Sun -> 7
    const wd = st.getDay() === 0 ? 7 : st.getDay();
    const done = !!t.is_completed;

    const bt = byTime.get(bucket) ?? { total: 0, done: 0 };
    bt.total += 1;
    bt.done += done ? 1 : 0;
    byTime.set(bucket, bt);

    const bw = byWday.get(wd) ?? { total: 0, done: 0 };
    bw.total += 1;
    bw.done += done ? 1 : 0;
    byWday.set(wd, bw);

    const lb = (t.life_block ?? "general").toString();
    const bb = byBlock.get(lb) ?? {
      count: 0,
      done: 0,
      sumImportance: 0,
      sumHours: 0,
    };
    bb.count += 1;
    bb.done += done ? 1 : 0;
    bb.sumImportance += safeNum(t.importance, 1);
    bb.sumHours += safeNum(t.spent_hours, 0);
    byBlock.set(lb, bb);
  }

  const by_time_of_day: Record<string, number> = {};
  for (const [k, v] of byTime.entries()) {
    by_time_of_day[k] = v.total > 0 ? v.done / v.total : 0;
  }

  const by_weekday: Record<string, number> = {};
  for (let i = 1; i <= 7; i++) {
    const v = byWday.get(i) ?? { total: 0, done: 0 };
    by_weekday[String(i)] = v.total > 0 ? v.done / v.total : 0;
  }

  const by_life_block: Record<string, unknown> = {};
  for (const [k, v] of byBlock.entries()) {
    by_life_block[k] = {
      count: v.count,
      completed_ratio: v.count > 0 ? v.done / v.count : 0,
      avg_importance: v.count > 0 ? v.sumImportance / v.count : 0,
      sum_spent_hours: v.sumHours,
    };
  }

  // moods: most common emoji
  const moodEmojiCounts = new Map<string, number>();
  for (const m of (moods ?? [])) {
    moodEmojiCounts.set(m.emoji, (moodEmojiCounts.get(m.emoji) ?? 0) + 1);
  }
  let most_common_emoji: string | null = null;
  let best = 0;
  for (const [e, c] of moodEmojiCounts.entries()) {
    if (c > best) {
      best = c;
      most_common_emoji = e;
    }
  }

  // finance totals + top categories
  let expense_total = 0;
  let income_total = 0;
  const expenseByCat = new Map<string, number>();

  for (const t of (txs ?? [])) {
    const amt = safeNum(t.amount, 0);
    if (t.kind === "expense") {
      expense_total += amt;
      const catName = t.category_id
        ? categoriesMap.get(t.category_id)?.name ?? "Uncategorized"
        : "Uncategorized";
      expenseByCat.set(catName, (expenseByCat.get(catName) ?? 0) + amt);
    } else {
      income_total += amt;
    }
  }

  const top_expense_categories = Array.from(expenseByCat.entries())
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .map(([name, amount]) => ({ name, amount }));

  return {
    period,
    profile: {
      archetype: userRow?.archetype ?? null,
      sleep: userRow?.sleep ?? null,
      activity: userRow?.activity ?? null,
      energy: userRow?.energy ?? null,
      stress: userRow?.stress ?? null,
      target_hours: userRow?.target_hours ?? null,
      priorities: userRow?.priorities ?? null,
      life_blocks: userRow?.life_blocks ?? null,
    },
    goals_by_block: userRow?.goals_by_block ?? null,
    goals_overview: {
      total: totalTasks,
      completed_ratio: completedRatio,
      overdue_open: overdueOpen,
    },
    task_patterns: {
      by_time_of_day,
      by_weekday,
      by_life_block,
    },
    mood_patterns: {
      days_with_mood: (moods ?? []).length,
      most_common_emoji,
    },
    finance_patterns: {
      expense_total,
      income_total,
      top_expense_categories,
      tx_count: (txs ?? []).length,
    },
  };
}

// ─────────────────────────────────────────────────────────────
// LLM call
// ─────────────────────────────────────────────────────────────
async function callInsightsLLM(snapshot: unknown) {
  const userPrompt = `Generate up to 5 high-quality insights explaining HOW behavior/context influences progress toward goals.

Rules:
- No generic advice, no motivational talk.
- Do not invent facts. If data is insufficient, output fewer insights.
- Use cautious language (associated with / tends to).
- Return ONLY JSON array.

INSIGHT SCHEMA:
{
  "type": "behavioral | goal | emotional | habit | risk",
  "title": "short clear title",
  "insight": "concise explanation of the observed pattern",
  "impact": {"goal":"goal name or life area","direction":"positive | negative | mixed","strength":0..1},
  "evidence":["data-based observation 1","data-based observation 2"],
  "suggestion":"optional reflective suggestion"
}

Data:
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
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: userPrompt },
      ],
      // Просим строгий JSON-вывод; иногда модель может вернуть объект — обработаем ниже
      text: { format: { type: "json_object" } },
    }),
  });

  if (!r.ok) {
    const errText = await r.text();
    throw new Error(`LLM request failed: ${errText}`);
  }

  const data = await r.json();
  const outputText =
    data?.output?.[0]?.content?.[0]?.text ??
    data?.output_text ??
    null;

  if (!outputText) throw new Error("Bad LLM response shape");

  const parsed = JSON.parse(outputText);

  // Ожидаем массив. Если модель вернула объект — пытаемся взять поле "insights"
  return Array.isArray(parsed)
    ? parsed
    : (parsed?.insights && Array.isArray(parsed.insights))
      ? parsed.insights
      : parsed;
}

// ─────────────────────────────────────────────────────────────
// Handler
// ─────────────────────────────────────────────────────────────
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return jsonResponse({}, 200);

  try {
    // Preconditions
    if (!SUPABASE_URL) return errorResponse("Missing SUPABASE_URL (or PROJECT_URL)", 500);
    if (!SERVICE_ROLE_KEY) return errorResponse("Missing SERVICE_ROLE_KEY secret", 500);
    if (!OPENAI_API_KEY) return errorResponse("Missing OPENAI_API_KEY secret", 500);

    // JWT из заголовка
    const auth = req.headers.get("authorization") ?? "";
    const jwt = auth.startsWith("Bearer ") ? auth.slice(7) : null;
    if (!jwt) return errorResponse("Missing Authorization bearer token", 401);

    // Пользователь
    const { data: u, error: uErr } = await admin.auth.getUser(jwt);
    if (uErr || !u?.user) return errorResponse("Invalid token", 401, uErr?.message);
    const userId = u.user.id;

    const payload = await req.json().catch(() => ({}));
    const period = payload?.period ?? "last_30_days";

    // 1) Собираем snapshot на сервере
    const snapshot = await buildSnapshot(userId, period);

    // 2) Вызываем LLM для инсайтов
    const insights = await callInsightsLLM(snapshot);

    // Возвращаем и snapshot (для дебага), и insights (для UI)
    return jsonResponse({ snapshot, insights }, 200);
  } catch (e) {
    return errorResponse("Unhandled error", 500, String(e));
  }
});
