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

if (!SUPABASE_URL) console.error("Missing SUPABASE_URL (or PROJECT_URL)");
if (!SERVICE_ROLE_KEY) console.error("Missing SERVICE_ROLE_KEY");

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

function mean(arr: number[]) {
  if (!arr.length) return null;
  return arr.reduce((a, b) => a + b, 0) / arr.length;
}

// Minimal item normalization to protect inserts
function normalizeItem(raw: any) {
  const title = String(raw?.title ?? "").trim();
  if (!title) return null;

  const description = String(raw?.description ?? "").trim();
  const life_block = String(raw?.life_block ?? "general").trim() || "general";

  let importance = Number(raw?.importance ?? 1);
  if (![1, 2, 3].includes(importance)) importance = 1;

  const planned_hours = clamp(safeNum(raw?.planned_hours, 0), 0, 6);
  const reason = String(raw?.reason ?? "").trim();

  const start_time = String(raw?.start_time ?? "").trim();
  if (!start_time) return null;

  return { title, description, life_block, importance, start_time, planned_hours, reason };
}

function isWithinWindow(iso: string, fromISO: string, toISO: string) {
  const t = Date.parse(iso);
  const a = Date.parse(fromISO);
  const b = Date.parse(toISO);
  return Number.isFinite(t) && t >= a && t <= b;
}

// Simple “too similar to existing tasks” guard
function isTooSimilar(title: string, existingTitlesNorm: Set<string>) {
  const t = normalizeTitle(title);
  if (!t) return true;
  if (existingTitlesNorm.has(t)) return true;

  // substring overlap check (cheap heuristic)
  for (const e of existingTitlesNorm) {
    if (e.length >= 10 && (t.includes(e) || e.includes(t))) return true;
  }
  return false;
}

// ─────────────────────────────────────────────────────────────
// Snapshot builder
// - Core: user_goals
// - Context: latest insights run (ai_insights_runs), recent goals patterns, habits, mental answers
// ─────────────────────────────────────────────────────────────
async function buildPlanSnapshot(userId: string, horizon: string) {
  const days = horizonToDays(horizon);
  const now = new Date();
  const planFrom = now;
  const planTo = new Date(now.getTime() + days * 24 * 3600 * 1000);

  const historyFrom = new Date(now.getTime() - 60 * 24 * 3600 * 1000); // 60d history
  const insightsLookbackFrom = new Date(now.getTime() - 30 * 24 * 3600 * 1000); // latest run within 30d

  // 0) user profile (optional, for capacity hints)
  const { data: userRow, error: userErr } = await admin
    .from("users")
    .select("archetype,target_hours,priorities,life_blocks")
    .eq("id", userId)
    .maybeSingle();
  if (userErr) throw new Error(`users select failed: ${userErr.message}`);

  // 1) user_goals: planning anchor
  const { data: userGoals, error: ugErr } = await admin
    .from("user_goals")
    .select("id,life_block,horizon,title,description,target_date,is_completed,sort_order,created_at,updated_at")
    .eq("user_id", userId)
    .order("sort_order", { ascending: true })
    .order("created_at", { ascending: false });
  if (ugErr) throw new Error(`user_goals select failed: ${ugErr.message}`);

  const activeGoals = (userGoals ?? []).filter((g) => !g.is_completed);
  if (activeGoals.length === 0) {
    return {
      ok: false,
      reason:
        "У пользователя нет активных целей (user_goals). Планировать нечего без опоры на цели.",
      hint:
        "Добавь 1–3 цели в user_goals (tactical/mid/long) и попробуй снова.",
    };
  }

  // 2) Latest ai_insights run (optional but preferred)
  const { data: insightsRun, error: irErr } = await admin
    .from("ai_insights_runs")
    .select("id,created_at,period,date_from,date_to,version,model,stats,insights,snapshot")
    .eq("user_id", userId)
    .gte("created_at", insightsLookbackFrom.toISOString())
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();
  if (irErr) throw new Error(`ai_insights_runs select failed: ${irErr.message}`);

  // 3) Tasks (goals table) history + planning window
  const { data: tasks, error: tasksErr } = await admin
    .from("goals")
    .select("id,title,description,life_block,importance,is_completed,deadline,start_time,created_at,spent_hours")
    .eq("user_id", userId)
    .gte("start_time", historyFrom.toISOString())
    .lte("start_time", planTo.toISOString())
    .order("start_time", { ascending: true });
  if (tasksErr) throw new Error(`goals select failed: ${tasksErr.message}`);

  const allTasks = tasks ?? [];
  const historyTasks = allTasks.filter((t) => Date.parse(String(t.start_time)) < planFrom.getTime());
  const upcomingTasks = allTasks.filter((t) => Date.parse(String(t.start_time)) >= planFrom.getTime());

  // 4) Habits (titles + entries last 30d) — used only as constraints context
  const habitsFrom = new Date(now.getTime() - 30 * 24 * 3600 * 1000);
  const { data: habits, error: hErr } = await admin
    .from("habits")
    .select("id,title,is_negative,created_at")
    .eq("user_id", userId);
  if (hErr) throw new Error(`habits select failed: ${hErr.message}`);

  const habitTitleById = new Map<string, string>();
  (habits ?? []).forEach((h) => habitTitleById.set(h.id, h.title));

  const { data: habitEntries, error: heErr } = await admin
    .from("habit_entries")
    .select("habit_id,day,done,value")
    .eq("user_id", userId)
    .gte("day", dateOnlyISO(habitsFrom))
    .lte("day", dateOnlyISO(now));
  if (heErr) throw new Error(`habit_entries select failed: ${heErr.message}`);

  // 5) Mental answers (last 30d), keep as simple per-code coverage summary
  const { data: questions, error: qErr } = await admin
    .from("mental_questions")
    .select("id,code,answer_type,is_active");
  if (qErr) throw new Error(`mental_questions select failed: ${qErr.message}`);

  const qById = new Map<string, { code: string; type: string }>();
  (questions ?? []).forEach((q) => qById.set(q.id, { code: q.code, type: q.answer_type }));

  const { data: answers, error: aErr } = await admin
    .from("mental_answers")
    .select("day,question_id,value_bool,value_int,value_text")
    .eq("user_id", userId)
    .gte("day", dateOnlyISO(habitsFrom))
    .lte("day", dateOnlyISO(now));
  if (aErr) throw new Error(`mental_answers select failed: ${aErr.message}`);

  // ─────────────────────────────────────────────
  // Aggregations for planning realism
  // ─────────────────────────────────────────────

  // Existing load in planning window by day (count + estimated hours)
  const loadByDay = new Map<string, { count: number; hours: number }>();
  for (const t of upcomingTasks) {
    if (t.is_completed) continue;
    const d = String(t.start_time).slice(0, 10);
    const rec = loadByDay.get(d) ?? { count: 0, hours: 0 };
    rec.count += 1;
    // prefer spent_hours if user uses it, else estimate by importance
    const est =
      safeNum(t.spent_hours, 0) > 0
        ? safeNum(t.spent_hours, 0)
        : (Number(t.importance ?? 1) === 3 ? 1.5 : Number(t.importance ?? 1) === 2 ? 1.0 : 0.5);
    rec.hours += clamp(est, 0, 6);
    loadByDay.set(d, rec);
  }

  // Typical completion rate and typical time-of-day buckets for completed tasks
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
      completion_ratio: bucketTotal[k as keyof typeof bucketTotal]
        ? bucketDone[k as keyof typeof bucketDone] / bucketTotal[k as keyof typeof bucketTotal]
        : 0,
      n: bucketTotal[k as keyof typeof bucketTotal],
    }))
    .sort((a, b) => b.completion_ratio - a.completion_ratio);

  const blockStats: Record<string, any> = {};
  for (const [k, v] of byBlock.entries()) {
    blockStats[k] = {
      tasks_total_60d: v.total,
      completion_ratio_60d: v.total ? v.done / v.total : 0,
      spent_hours_sum_60d: v.hours,
    };
  }

  // Recent task titles to avoid duplicates
  const recentTitlesNorm = new Set<string>();
  for (const t of allTasks.slice(-250)) {
    const nt = normalizeTitle(t.title);
    if (nt) recentTitlesNorm.add(nt);
  }

  // Habit summary last 30d (done days per habit)
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

  // Mental coverage summary (how many days with answers per code)
  const mentalDaysByCode = new Map<string, Set<string>>();
  for (const a of answers ?? []) {
    const meta = qById.get(a.question_id);
    if (!meta) continue;
    if (a.value_bool === null && a.value_int === null && !String(a.value_text ?? "").trim()) continue;
    const set = mentalDaysByCode.get(meta.code) ?? new Set<string>();
    set.add(String(a.day));
    mentalDaysByCode.set(meta.code, set);
  }

  const mentalCoverage = Array.from(mentalDaysByCode.entries()).map(([code, set]) => ({
    code,
    days_with_answers_30d: set.size,
  }));

  // Capacity hint (hours/day) from profile.target_hours if present
  const targetHoursRaw = userRow?.target_hours;
  const targetHours = targetHoursRaw === null || targetHoursRaw === undefined ? null : safeNum(targetHoursRaw, 0);

  // Plan window day list
  const windowDays: string[] = [];
  for (let i = 0; i <= days; i++) {
    const d = new Date(planFrom.getTime() + i * 24 * 3600 * 1000);
    windowDays.push(dateOnlyISO(d));
  }

  const workloadByDay = windowDays.map((d) => ({
    day: d,
    existing_count: loadByDay.get(d)?.count ?? 0,
    existing_hours_est: Number((loadByDay.get(d)?.hours ?? 0).toFixed(2)),
  }));

  return {
    ok: true,
    horizon: (horizon ?? "week").toLowerCase(),
    window: {
      from: planFrom.toISOString(),
      to: planTo.toISOString(),
      planning_days: days,
      days: windowDays,
    },
    profile: {
      archetype: userRow?.archetype ?? null,
      target_hours_per_day: targetHours, // can be null
      priorities: userRow?.priorities ?? null,
      life_blocks: userRow?.life_blocks ?? null,
    },

    // ── Anchors
    user_goals: activeGoals.map((g) => ({
      id: g.id,
      horizon: g.horizon,
      life_block: g.life_block ?? "general",
      title: g.title,
      description: g.description ?? "",
      target_date: g.target_date ?? null,
      updated_at: g.updated_at,
    })),

    // ── Latest insights run (optional)
    latest_insights_run: insightsRun
      ? {
          id: insightsRun.id,
          created_at: insightsRun.created_at,
          period: insightsRun.period,
          date_from: insightsRun.date_from,
          date_to: insightsRun.date_to,
          version: insightsRun.version,
          // keep only what planner needs
          insights: insightsRun.insights ?? [],
          stats: insightsRun.stats ?? {},
        }
      : null,

    // ── Realism / constraints
    workload_by_day: workloadByDay,
    recent_task_titles_norm: Array.from(recentTitlesNorm).slice(0, 200), // for LLM duplicate avoidance
    task_patterns: {
      time_preference: timePreference, // sorted by completion ratio
      by_life_block_60d: blockStats,
    },
    habits_summary_30d: habitsSummary,
    mental_coverage_30d: mentalCoverage,

    // Provide a compact view of upcoming tasks titles (to avoid repeating)
    upcoming_tasks_in_window: upcomingTasks
      .filter((t) => !t.is_completed)
      .slice(0, 120)
      .map((t) => ({
        id: t.id,
        title: t.title ?? "",
        life_block: t.life_block ?? "general",
        start_time: t.start_time,
        deadline: t.deadline,
        importance: t.importance ?? 1,
      })),
  };
}

// ─────────────────────────────────────────────────────────────
// Prompt + LLM
// - Planner must be anchored to user_goals
// - Must use latest insights (if present) as constraints/priorities, not as “facts”
// - Must respect workload_by_day + avoid duplicates + stay realistic
// ─────────────────────────────────────────────────────────────
const SYSTEM_PROMPT = `Ты — строгий AI-планировщик для приложения самоменеджмента.

Требования:
- План строится ОТ user_goals (это основа). Каждая предлагаемая задача должна объяснять связь с одной или несколькими целями.
- Не выдумывай факты. Используй ТОЛЬКО данные snapshot.
- Не делай причинных утверждений. Если используешь инсайты, формулируй как "наблюдалась ассоциация", "есть тенденция".
- План должен быть реалистичным: не перегружай дни с высокой нагрузкой и учитывай типичное время выполнения (task_patterns.time_preference).
- Не предлагай дубликаты уже существующих задач (ориентируйся на upcoming_tasks_in_window и recent_task_titles_norm).
- Каждая задача обязана иметь start_time (ISO) внутри snapshot.window.
- Максимум: week=12 задач, month=20 задач.
- Верни ТОЛЬКО валидный JSON-объект вида {"items":[...]} без markdown.`;

async function callPlanLLM(snapshot: unknown) {
  if (!OPENAI_API_KEY) {
    // Without LLM we cannot produce a smart plan; keep behavior strict.
    throw new Error("Missing OPENAI_API_KEY");
  }

  const userPrompt = `Сгенерируй план задач.

Схема ответа (СТРОГО):
{
  "items": [
    {
      "title": "string",
      "description": "string (может быть пустым)",
      "life_block": "string",
      "importance": 1|2|3,
      "start_time": "ISO datetime",
      "planned_hours": number,
      "reason": "короткое доказательное объяснение: к каким user_goals относится и почему это уместно с учетом нагрузки/инсайтов"
    }
  ]
}

Ограничения и качество:
- НИ ОДНА задача не должна быть «абстрактной» (типа “работать над собой”). Делай конкретные действия.
- planned_hours обычно 0.5..2.0 (редко до 3.0). Не ставь 0, если это не микро-задача.
- Используй snapshot.workload_by_day: выбирай дни с меньшей existing_hours_est и existing_count.
- Учитывай snapshot.task_patterns.time_preference (время дня, когда у пользователя выше completion_ratio) при выборе start_time.
- Используй snapshot.latest_insights_run (если есть) только как приоритет/ограничение (напр. если есть инсайт "недостаточно данных" — не делай сильных выводов).
- Избегай дубликатов: не используй формулировки, похожие на snapshot.upcoming_tasks_in_window.title или snapshot.recent_task_titles_norm.
- Если активных целей много, выбери 2–4 ключевые цели и сделай по ним шаги (balanced across life_block).
- Если данные недостаточны (например, нет insights_run и мало истории задач), делай более консервативный план (меньше задач, проще).

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
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: userPrompt },
      ],
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
    console.error("LLM output (not JSON):", outputText);
    throw new Error("LLM output is not valid JSON");
  }

  const items: any[] | null =
    Array.isArray(parsed?.items) ? parsed.items
      : Array.isArray(parsed) ? parsed
      : Array.isArray(parsed?.plan) ? parsed.plan
      : null;

  if (!Array.isArray(items)) {
    console.error("LLM parsed keys:", parsed ? Object.keys(parsed) : null);
    throw new Error("LLM output does not contain items[]");
  }

  return items;
}

// ─────────────────────────────────────────────────────────────
// Post-filtering & realism guards (server-side)
// ─────────────────────────────────────────────────────────────
function postFilterItems(
  normalized: any[],
  snapshot: any,
) {
  const fromISO = snapshot.window.from as string;
  const toISO = snapshot.window.to as string;

  const existingTitlesNorm = new Set<string>();
  for (const t of (snapshot.upcoming_tasks_in_window ?? [])) {
    const nt = normalizeTitle(t.title);
    if (nt) existingTitlesNorm.add(nt);
  }
  for (const nt of (snapshot.recent_task_titles_norm ?? [])) {
    if (typeof nt === "string" && nt.trim()) existingTitlesNorm.add(nt.trim());
  }

  const maxItems = snapshot.horizon === "month" ? 20 : 12;

  // Load map (to avoid overloading)
  const loadMap = new Map<string, { count: number; hours: number }>();
  for (const d of (snapshot.workload_by_day ?? [])) {
    loadMap.set(String(d.day), { count: Number(d.existing_count ?? 0), hours: Number(d.existing_hours_est ?? 0) });
  }

  const targetHours = snapshot.profile?.target_hours_per_day;
  const hardHoursCap = typeof targetHours === "number" && Number.isFinite(targetHours) && targetHours > 0
    ? clamp(targetHours, 2, 10)
    : 6; // fallback

  const kept: any[] = [];
  for (const it of normalized) {
    if (kept.length >= maxItems) break;

    if (!isWithinWindow(it.start_time, fromISO, toISO)) continue;
    if (isTooSimilar(it.title, existingTitlesNorm)) continue;

    const day = String(it.start_time).slice(0, 10);
    const rec = loadMap.get(day) ?? { count: 0, hours: 0 };

    // avoid overloading: count cap and hours cap
    const estH = clamp(safeNum(it.planned_hours, 1), 0.25, 6);
    const countCap = snapshot.horizon === "month" ? 5 : 4;

    if (rec.count >= countCap) continue;
    if (rec.hours + estH > hardHoursCap) continue;

    // accept item
    kept.push(it);
    existingTitlesNorm.add(normalizeTitle(it.title));
    rec.count += 1;
    rec.hours += estH;
    loadMap.set(day, rec);
  }

  return kept;
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
    if (!snapshot?.ok) {
      // return a strict message instead of toy plan
      return errorResponse("Planning preconditions not met", 422, snapshot);
    }

    // 2) LLM plan
    const rawItems = await callPlanLLM(snapshot);

    // 3) normalize
    const normalized = rawItems
      .map((x: any) => normalizeItem(x))
      .filter((x: any) => !!x);

    if (normalized.length === 0) {
      return errorResponse("LLM returned no valid items", 422, { rawItems });
    }

    // 4) server-side realism filters (window, duplicates, overload)
    const filtered = postFilterItems(normalized, snapshot);

    if (filtered.length === 0) {
      return errorResponse(
        "LLM returned items, but all were filtered as unrealistic/duplicates/outside window",
        422,
        { rawCount: normalized.length, sample: normalized.slice(0, 5) },
      );
    }

    // 5) Save plan header
    const { data: planRow, error: planErr } = await admin
      .from("ai_plans")
      .insert({
        user_id: userId,
        horizon,
        status: "draft",
        snapshot, // jsonb: includes goals + latest insights + constraints
      })
      .select("id,created_at,horizon,status")
      .single();

    if (planErr) throw new Error(`ai_plans insert failed: ${planErr.message}`);
    const planId = planRow.id as string;

    // 6) Save items
    const rows = filtered.map((it: any) => ({
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
