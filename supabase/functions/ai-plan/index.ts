import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ─────────────────────────────────────────────────────────────
// Secrets / Env
// ─────────────────────────────────────────────────────────────
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? Deno.env.get("PROJECT_URL");
const SERVICE_ROLE_KEY = Deno.env.get("SERVICE_ROLE_KEY");

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
const OPENAI_MODEL = Deno.env.get("OPENAI_MODEL") ?? "gpt-4.1-mini";

if (!SUPABASE_URL) console.error("Missing SUPABASE_URL (or PROJECT_URL)");
if (!SERVICE_ROLE_KEY) console.error("Missing SERVICE_ROLE_KEY");
if (!OPENAI_API_KEY) console.error("Missing OPENAI_API_KEY");

const admin = createClient(SUPABASE_URL!, SERVICE_ROLE_KEY!, {
  auth: { persistSession: false },
});

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

function errorResponse(message: string, status = 400, details?: unknown) {
  return jsonResponse({ error: message, details }, status);
}

function dateOnlyISO(d: Date) {
  return d.toISOString().slice(0, 10);
}

function safeNum(n: unknown, fallback = 0) {
  const x = Number(n);
  return Number.isFinite(x) ? x : fallback;
}

function horizonToDays(h: string) {
  const v = (h ?? "week").toLowerCase();
  return v === "month" ? 30 : 7;
}

// Простейшая нормализация item’а из LLM, чтобы не сломать insert
function normalizeItem(raw: any) {
  const title = String(raw?.title ?? "").trim();
  const description = String(raw?.description ?? "").trim();
  const life_block = String(raw?.life_block ?? "general").trim() || "general";

  let importance = Number(raw?.importance ?? 1);
  if (![1, 2, 3].includes(importance)) importance = 1;

  const planned_hours = safeNum(raw?.planned_hours, 0);
  const reason = String(raw?.reason ?? "").trim();

  const start_time = String(raw?.start_time ?? "").trim();
  // start_time обязателен — но если модель “съехала”, отсекаем такой item
  if (!start_time) return null;

  return { title, description, life_block, importance, start_time, planned_hours, reason };
}

// ─────────────────────────────────────────────────────────────
// Snapshot builder: контекст для планирования
// ─────────────────────────────────────────────────────────────
async function buildPlanSnapshot(userId: string, horizon: string) {
  const days = horizonToDays(horizon);

  const now = new Date();
  const from = new Date(now.getTime() - 60 * 24 * 3600 * 1000); // история за 60 дней
  const to = new Date(now.getTime() + days * 24 * 3600 * 1000); // + горизонта вперёд

  // 1) Профиль/онбординг
  const { data: userRow, error: userErr } = await admin
    .from("users")
    .select(
      "archetype,sleep,activity,energy,stress,target_hours,goals_by_block,priorities,life_blocks",
    )
    .eq("id", userId)
    .maybeSingle();

  if (userErr) throw new Error(`users select failed: ${userErr.message}`);

  // 2) Goals: прошлые и ближайшие (чтобы модель видела нагрузку и дедлайны)
  const { data: goals, error: goalsErr } = await admin
    .from("goals")
    .select(
      "id,title,description,life_block,importance,is_completed,deadline,start_time,created_at,spent_hours",
    )
    .eq("user_id", userId)
    .gte("start_time", from.toISOString())
    .lte("start_time", to.toISOString())
    .order("start_time", { ascending: true });

  if (goalsErr) throw new Error(`goals select failed: ${goalsErr.message}`);

  // 3) Moods (последние 30 дней)
  const moodsFrom = new Date(now.getTime() - 30 * 24 * 3600 * 1000);
  const { data: moods, error: moodsErr } = await admin
    .from("moods")
    .select("date,emoji")
    .eq("user_id", userId)
    .gte("date", dateOnlyISO(moodsFrom))
    .lte("date", dateOnlyISO(now));

  if (moodsErr) throw new Error(`moods select failed: ${moodsErr.message}`);

  // 4) Transactions (последние 30 дней)
  const { data: txs, error: txErr } = await admin
    .from("transactions")
    .select("ts,kind,amount,category_id")
    .eq("user_id", userId)
    .gte("ts", moodsFrom.toISOString())
    .lte("ts", now.toISOString());

  if (txErr) throw new Error(`transactions select failed: ${txErr.message}`);

  // ── Aggregations ───────────────────────────────────────────
  const all = goals ?? [];

  const nowTime = now.getTime();
  const upcoming = all
    .filter((g) => !g.is_completed && new Date(g.start_time).getTime() >= nowTime)
    .slice(0, 200);

  const overdue = all.filter((g) => !g.is_completed && new Date(g.deadline).getTime() < nowTime);

  // занятость по дням
  const loadByDay = new Map<string, number>();
  for (const g of upcoming) {
    const k = (g.start_time as string).slice(0, 10);
    loadByDay.set(k, (loadByDay.get(k) ?? 0) + 1);
  }

  // самый частый emoji
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

  let expense_total = 0;
  let income_total = 0;
  for (const t of (txs ?? [])) {
    const amt = safeNum(t.amount, 0);
    if (t.kind === "expense") expense_total += amt;
    else income_total += amt;
  }

  return {
    horizon: (horizon ?? "week").toLowerCase(),
    window: {
      from: from.toISOString(),
      to: to.toISOString(),
      planning_days: days,
    },
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

    workload: {
      upcoming_count: upcoming.length,
      overdue_open_count: overdue.length,
      load_by_day: Object.fromEntries(loadByDay.entries()),
    },

    upcoming_goals: upcoming.map((g) => ({
      id: g.id,
      title: g.title ?? null,
      life_block: g.life_block ?? "general",
      importance: g.importance ?? 1,
      start_time: g.start_time,
      deadline: g.deadline,
      spent_hours: g.spent_hours ?? 0,
      is_completed: !!g.is_completed,
    })),

    mood: {
      days_with_mood: (moods ?? []).length,
      most_common_emoji,
    },

    finance: {
      expense_total_30d: expense_total,
      income_total_30d: income_total,
      tx_count_30d: (txs ?? []).length,
    },
  };
}

// ─────────────────────────────────────────────────────────────
// Prompt + LLM
// ─────────────────────────────────────────────────────────────
const SYSTEM_PROMPT = `You are an AI planning engine for a personal life management app.
You must generate an actionable plan as a list of suggested goals/tasks for the user's calendar.

Rules:
- Do NOT invent facts beyond the provided data.
- Avoid generic motivation.
- Suggestions must be realistic for the horizon and avoid overloading days that already have many tasks.
- Each item must include a specific start_time (ISO) within the planning window.
- Return ONLY valid JSON. Prefer {"items":[...]} as the top-level object.`;

async function callPlanLLM(snapshot: unknown) {
  const userPrompt = `Create a plan for the given horizon.

Return ONLY valid JSON OBJECT with schema EXACTLY:
{
  "items": [
    {
      "title": "string",
      "description": "string (can be empty)",
      "life_block": "string",
      "importance": 1|2|3,
      "start_time": "ISO datetime",
      "planned_hours": number,
      "reason": "short evidence-based reason referencing the snapshot"
    }
  ]
}

Constraints:
- Max 12 items for week, max 20 for month.
- Prefer distributing tasks across days with lower load_by_day.
- If overdue_open_count > 0, include 1-3 catch-up items.
- planned_hours usually 0.5..2.0.
- Do not schedule outside snapshot.window.

Data snapshot:
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
      // Мы просим объект, поэтому и формат json_object
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

  let parsed: any;
  try {
    parsed = JSON.parse(outputText);
  } catch {
    // иногда модель может вернуть уже объектоподобный текст — для логов
    console.error("LLM output (not JSON):", outputText);
    throw new Error("LLM output is not valid JSON");
  }

  // ✅ принимаем массив ИЛИ объект с items ИЛИ items строкой (редко)
  let items: any[] | null =
    Array.isArray(parsed) ? parsed
    : Array.isArray(parsed?.items) ? parsed.items
    : Array.isArray(parsed?.plan) ? parsed.plan
    : Array.isArray(parsed?.data) ? parsed.data
    : null;

  if (!items && typeof parsed?.items === "string") {
    try {
      const maybe = JSON.parse(parsed.items);
      if (Array.isArray(maybe)) items = maybe;
    } catch {}
  }

  if (!Array.isArray(items)) {
    console.error("LLM outputText:", outputText);
    console.error("LLM parsed keys:", parsed ? Object.keys(parsed) : null);
    throw new Error("LLM output is not an array");
  }

  // маленькая нормализация: убираем пустые title
  items = items
    .filter((x) => (x?.title ?? "").toString().trim().length > 0)
    .map((x) => ({
      title: String(x.title ?? "").trim(),
      description: String(x.description ?? ""),
      life_block: String(x.life_block ?? "general"),
      importance: [1, 2, 3].includes(Number(x.importance)) ? Number(x.importance) : 1,
      start_time: String(x.start_time),
      planned_hours: Number.isFinite(Number(x.planned_hours)) ? Number(x.planned_hours) : 0,
      reason: String(x.reason ?? ""),
    }));

  return items;
}


// ─────────────────────────────────────────────────────────────
// Handler
// ─────────────────────────────────────────────────────────────
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return jsonResponse({}, 200);

  try {
    if (!SUPABASE_URL) return errorResponse("Missing SUPABASE_URL (or PROJECT_URL)", 500);
    if (!SERVICE_ROLE_KEY) return errorResponse("Missing SERVICE_ROLE_KEY secret", 500);
    if (!OPENAI_API_KEY) return errorResponse("Missing OPENAI_API_KEY secret", 500);

    const auth = req.headers.get("authorization") ?? "";
    const jwt = auth.startsWith("Bearer ") ? auth.slice(7) : null;
    if (!jwt) return errorResponse("Missing Authorization bearer token", 401);

    const { data: u, error: uErr } = await admin.auth.getUser(jwt);
    if (uErr || !u?.user) return errorResponse("Invalid token", 401, uErr?.message);
    const userId = u.user.id;

    const payload = await req.json().catch(() => ({}));
    const horizon = (payload?.horizon ?? "week").toString().toLowerCase();

    if (horizon !== "week" && horizon !== "month") {
      return errorResponse("Invalid horizon. Use 'week' or 'month'.", 400);
    }

    // 1) snapshot
    const snapshot = await buildPlanSnapshot(userId, horizon);

    // 2) LLM plan
    const rawItems = await callPlanLLM(snapshot);

    // 3) normalize + filter
    const normalized = rawItems
      .map((x: any) => normalizeItem(x))
      .filter((x: any) => !!x);

    if (normalized.length === 0) {
      return errorResponse("LLM returned no valid items", 422, { rawItems });
    }

    // 4) Save plan header
    const { data: planRow, error: planErr } = await admin
      .from("ai_plans")
      .insert({
        user_id: userId,
        horizon,
        status: "draft",
        snapshot, // jsonb
      })
      .select("id,created_at,horizon,status")
      .single();

    if (planErr) throw new Error(`ai_plans insert failed: ${planErr.message}`);
    const planId = planRow.id as string;

    // 5) Save items
    const rows = normalized.map((it: any) => ({
      plan_id: planId,
      user_id: userId,
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

    if (itemsErr) throw new Error(`ai_plan_items insert failed: ${itemsErr.message}`);

    return jsonResponse(
      {
        plan_id: planId,
        plan: planRow,
        snapshot,
        items: savedItems ?? [],
      },
      200,
    );
  } catch (e) {
    return errorResponse("Unhandled error", 500, String(e));
  }
});
