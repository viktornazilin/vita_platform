// supabase/functions/ai-insights/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ─────────────────────────────────────────────────────────────
// Env / Clients
// ─────────────────────────────────────────────────────────────
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? Deno.env.get("PROJECT_URL");
const SERVICE_ROLE_KEY = Deno.env.get("SERVICE_ROLE_KEY");

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
const OPENAI_MODEL = Deno.env.get("OPENAI_MODEL") ?? "gpt-4.1-mini";

if (!SUPABASE_URL) console.error("Missing SUPABASE_URL (or PROJECT_URL)");
if (!SERVICE_ROLE_KEY) console.error("Missing SERVICE_ROLE_KEY");
if (!OPENAI_API_KEY) console.warn("Missing OPENAI_API_KEY — will return rule-based insights only");

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

function periodToRange(period: string) {
  const now = new Date();
  const p = (period ?? "last_30_days").toLowerCase();
  const days = p === "last_7_days" ? 7 : p === "last_90_days" ? 90 : 30;
  const from = new Date(now.getTime() - days * 24 * 3600 * 1000);
  return { from, to: now, days };
}

function dayKey(d: Date) {
  return d.toISOString().slice(0, 10); // YYYY-MM-DD
}

function safeNum(n: unknown, fallback = 0) {
  const x = Number(n);
  return Number.isFinite(x) ? x : fallback;
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
  const mx = mean(x), my = mean(y);
  if (mx === null || my === null) return null;
  const sx = std(x), sy = std(y);
  if (!sx || !sy) return null;
  let cov = 0;
  for (let i = 0; i < x.length; i++) cov += (x[i] - mx) * (y[i] - my);
  cov /= x.length;
  return cov / (sx * sy);
}

function diffOfMeans(flag: boolean[], y: number[]) {
  if (flag.length !== y.length) return null;
  const a: number[] = [];
  const b: number[] = [];
  for (let i = 0; i < flag.length; i++) (flag[i] ? a : b).push(y[i]);
  if (a.length < 3 || b.length < 3) return null;
  const ma = mean(a), mb = mean(b);
  if (ma === null || mb === null) return null;
  return { delta: ma - mb, n1: a.length, n0: b.length, m1: ma, m0: mb };
}

// ─────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────
type Daily = {
  day: string;

  tasks_total: number;
  tasks_done: number;
  tasks_spent_hours: number;
  tasks_overdue_open: number;

  moods_present: boolean;

  // habit name -> flags
  habits_flag: Record<string, boolean>;
  habits_value: Record<string, number>;

  // mental scale by question code (avg per day)
  mental_int_avg: Record<string, number>;
};

type HabitEffect = {
  habit: string;
  metric: "tasks_done" | "completion_ratio";
  status: "ok" | "insufficient_data";
  reason?: string;
  delta?: number;
  n1?: number;
  n0?: number;
  m1?: number;
  m0?: number;
};

type MentalEffect = {
  question: string; // code
  metric: "tasks_done";
  status: "ok" | "insufficient_data";
  reason?: string;
  r?: number;
  n?: number;
};

// ─────────────────────────────────────────────────────────────
// Build analytics snapshot (server-side facts)
// ─────────────────────────────────────────────────────────────
async function buildAnalytics(userId: string, period: string) {
  const { from, to, days } = periodToRange(period);
  const fromDay = dayKey(from);
  const toDay = dayKey(to);

  // user_goals
  const { data: userGoals, error: ugErr } = await admin
    .from("user_goals")
    .select("id,life_block,horizon,title,is_completed,target_date,created_at,updated_at")
    .eq("user_id", userId);

  if (ugErr) throw new Error(`user_goals select failed: ${ugErr.message}`);

  // goals (daily tasks)
  const { data: tasks, error: tErr } = await admin
    .from("goals")
    .select("id,life_block,is_completed,deadline,start_time,created_at,spent_hours,importance")
    .eq("user_id", userId)
    .gte("start_time", from.toISOString())
    .lte("start_time", to.toISOString());

  if (tErr) throw new Error(`goals select failed: ${tErr.message}`);

  // moods
  const { data: moods, error: mErr } = await admin
    .from("moods")
    .select("date,emoji")
    .eq("user_id", userId)
    .gte("date", fromDay)
    .lte("date", toDay);

  if (mErr) throw new Error(`moods select failed: ${mErr.message}`);

  // habits + habit_entries
  const { data: habits, error: hErr } = await admin
    .from("habits")
    .select("id,title,is_negative")
    .eq("user_id", userId);

  if (hErr) throw new Error(`habits select failed: ${hErr.message}`);

  const habitTitleById = new Map<string, string>();
  (habits ?? []).forEach((h) => habitTitleById.set(h.id, h.title));

  const { data: habitEntries, error: heErr } = await admin
    .from("habit_entries")
    .select("habit_id,day,done,value")
    .eq("user_id", userId)
    .gte("day", fromDay)
    .lte("day", toDay);

  if (heErr) throw new Error(`habit_entries select failed: ${heErr.message}`);

  // mental questions + answers
  const { data: questions, error: qErr } = await admin
    .from("mental_questions")
    .select("id,code,answer_type,is_active");

  if (qErr) throw new Error(`mental_questions select failed: ${qErr.message}`);

  const qById = new Map<string, { code: string; answer_type: string }>();
  (questions ?? []).forEach((q) => qById.set(q.id, { code: q.code, answer_type: q.answer_type }));

  const { data: answers, error: aErr } = await admin
    .from("mental_answers")
    .select("day,question_id,value_bool,value_int,value_text")
    .eq("user_id", userId)
    .gte("day", fromDay)
    .lte("day", toDay);

  if (aErr) throw new Error(`mental_answers select failed: ${aErr.message}`);

  // ─────────────────────────────────────────────
  // Daily aggregation
  // ─────────────────────────────────────────────
  const dailyMap = new Map<string, Daily>();

  function ensureDay(d: string) {
    const existing = dailyMap.get(d);
    if (existing) return existing;
    const init: Daily = {
      day: d,
      tasks_total: 0,
      tasks_done: 0,
      tasks_spent_hours: 0,
      tasks_overdue_open: 0,
      moods_present: false,
      habits_flag: {},
      habits_value: {},
      mental_int_avg: {},
    };
    dailyMap.set(d, init);
    return init;
  }

  // tasks
  const now = new Date();
  for (const t of (tasks ?? [])) {
    const st = new Date(t.start_time);
    const d = dayKey(st);
    const row = ensureDay(d);

    row.tasks_total += 1;
    if (t.is_completed) row.tasks_done += 1;
    row.tasks_spent_hours += safeNum(t.spent_hours, 0);

    if (!t.is_completed && new Date(t.deadline) < now) {
      row.tasks_overdue_open += 1;
    }
  }

  // moods presence
  for (const m of (moods ?? [])) {
    const row = ensureDay(m.date);
    row.moods_present = true;
  }

  // habits: flag = true if any entry done=true that day for that habit
  for (const e of (habitEntries ?? [])) {
    const row = ensureDay(e.day);
    const name = habitTitleById.get(e.habit_id) ?? e.habit_id;
    if (e.done) row.habits_flag[name] = true;
    row.habits_value[name] = (row.habits_value[name] ?? 0) + safeNum(e.value, 0);
  }

  // mental: store day-average for value_int per code
  const mentalCollector = new Map<string, Map<string, number[]>>(); // day -> code -> values
  for (const a of (answers ?? [])) {
    const meta = qById.get(a.question_id);
    if (!meta) continue;
    if (a.value_int === null || a.value_int === undefined) continue;
    const d = a.day;
    const byCode = mentalCollector.get(d) ?? new Map<string, number[]>();
    const arr = byCode.get(meta.code) ?? [];
    arr.push(safeNum(a.value_int, 0));
    byCode.set(meta.code, arr);
    mentalCollector.set(d, byCode);
  }
  for (const [d, byCode] of mentalCollector.entries()) {
    const row = ensureDay(d);
    for (const [code, vals] of byCode.entries()) {
      const m = mean(vals);
      if (m !== null) row.mental_int_avg[code] = m;
    }
  }

  const daily = Array.from(dailyMap.values()).sort((a, b) => a.day.localeCompare(b.day));

  // ─────────────────────────────────────────────
  // Sufficiency checks
  // ─────────────────────────────────────────────
  const daysWithTasks = daily.filter((d) => d.tasks_total > 0).length;
  const sufficiency = {
    period_days: days,
    date_from: fromDay,
    date_to: toDay,
    days_with_any_data: daily.length,
    days_with_tasks: daysWithTasks,
    ok_for_basic: daysWithTasks >= 7,
    ok_for_correlation: daysWithTasks >= 14,
    notes: [] as string[],
  };

  if (daysWithTasks < 7) {
    sufficiency.notes.push(
      "Недостаточно дней с задачами для осмысленных инсайтов. Нужны минимум 7 дней, лучше 14+."
    );
  }

  // ─────────────────────────────────────────────
  // Habit effects (tasks_done / completion_ratio)
  // ─────────────────────────────────────────────
  const tasksDone = daily.map((d) => d.tasks_done);
  const completionRatio = daily.map((d) => (d.tasks_total ? d.tasks_done / d.tasks_total : 0));

  const habitNames = new Set<string>();
  for (const d of daily) Object.keys(d.habits_flag).forEach((h) => habitNames.add(h));
  // also include habits that exist but were never flagged in period (for "no data" messaging)
  (habits ?? []).forEach((h) => habitNames.add(h.title));

  const habitEffects: HabitEffect[] = [];

  for (const habit of habitNames) {
    const flag = daily.map((d) => !!d.habits_flag[habit]);

    // For each metric we compute diff-of-means
    for (const metric of ["tasks_done", "completion_ratio"] as const) {
      const y = metric === "tasks_done" ? tasksDone : completionRatio;

      // Need enough data
      if (!sufficiency.ok_for_correlation) {
        habitEffects.push({
          habit,
          metric,
          status: "insufficient_data",
          reason: "Для корреляций нужно минимум 14 дней с задачами в выбранном периоде.",
        });
        continue;
      }

      const dm = diffOfMeans(flag, y);
      if (!dm) {
        // likely too few habit days vs non-habit days
        const n1 = flag.filter(Boolean).length;
        const n0 = flag.filter((x) => !x).length;
        habitEffects.push({
          habit,
          metric,
          status: "insufficient_data",
          reason:
            `Недостаточно наблюдений для сравнения. Нужно хотя бы 3 дня с привычкой и 3 дня без неё (сейчас: ${n1} vs ${n0}).`,
        });
        continue;
      }

      habitEffects.push({
        habit,
        metric,
        status: "ok",
        delta: dm.delta,
        n1: dm.n1,
        n0: dm.n0,
        m1: dm.m1,
        m0: dm.m0,
      });
    }
  }

  // ─────────────────────────────────────────────
  // Mental effects: correlation r(value_int_avg, tasks_done)
  // ─────────────────────────────────────────────
  const mentalCodes = new Set<string>();
  for (const d of daily) Object.keys(d.mental_int_avg).forEach((c) => mentalCodes.add(c));

  const mentalEffects: MentalEffect[] = [];

  for (const code of mentalCodes) {
    if (!sufficiency.ok_for_correlation) {
      mentalEffects.push({
        question: code,
        metric: "tasks_done",
        status: "insufficient_data",
        reason: "Для корреляций нужно минимум 14 дней с задачами в выбранном периоде.",
      });
      continue;
    }

    const xs: number[] = [];
    const ys: number[] = [];
    for (const d of daily) {
      const x = d.mental_int_avg[code];
      if (x === undefined) continue;
      xs.push(x);
      ys.push(d.tasks_done);
    }

    if (xs.length < 7) {
      mentalEffects.push({
        question: code,
        metric: "tasks_done",
        status: "insufficient_data",
        reason: `Недостаточно дней с ответами по этому вопросу (нужно ~7+, сейчас ${xs.length}).`,
      });
      continue;
    }

    const r = pearson(xs, ys);
    if (r === null) {
      mentalEffects.push({
        question: code,
        metric: "tasks_done",
        status: "insufficient_data",
        reason: "Недостаточно вариативности данных для расчёта корреляции.",
      });
      continue;
    }

    mentalEffects.push({
      question: code,
      metric: "tasks_done",
      status: "ok",
      r,
      n: xs.length,
    });
  }

  mentalEffects.sort((a, b) => (Math.abs((b.r ?? 0)) - Math.abs((a.r ?? 0))));

  // ─────────────────────────────────────────────
  // Simple overview metrics (server facts)
  // ─────────────────────────────────────────────
  const totalTasks = (tasks ?? []).length;
  const completedTasks = (tasks ?? []).filter((t) => t.is_completed).length;
  const overdueOpen = (tasks ?? []).filter((t) => !t.is_completed && new Date(t.deadline) < now).length;
  const spentHours = (tasks ?? []).reduce((s, t) => s + safeNum(t.spent_hours, 0), 0);

  const userGoalsTotal = (userGoals ?? []).length;
  const userGoalsCompleted = (userGoals ?? []).filter((g) => g.is_completed).length;

  const snapshot = {
    period,
    date_from: fromDay,
    date_to: toDay,
    tasks_overview: {
      total: totalTasks,
      completed: completedTasks,
      completed_ratio: totalTasks ? completedTasks / totalTasks : 0,
      overdue_open: overdueOpen,
      total_spent_hours: spentHours,
    },
    user_goals_overview: {
      total: userGoalsTotal,
      completed: userGoalsCompleted,
      completed_ratio: userGoalsTotal ? userGoalsCompleted / userGoalsTotal : 0,
      by_horizon: ["tactical", "mid", "long"].reduce((acc: any, h) => {
        acc[h] = (userGoals ?? []).filter((g) => g.horizon === h).length;
        return acc;
      }, {}),
      by_life_block: (userGoals ?? []).reduce((acc: any, g) => {
        const k = g.life_block ?? "general";
        acc[k] = (acc[k] ?? 0) + 1;
        return acc;
      }, {}),
    },
    daily, // keep for debug / UI drill-down
  };

  const stats = {
    sufficiency,
    habit_effects: habitEffects,
    mental_effects: mentalEffects.slice(0, 10), // top 10 by |r|
  };

  return { snapshot, stats, fromDay, toDay };
}

// ─────────────────────────────────────────────────────────────
// Insight generation (rule-based + optional LLM phrasing)
// ─────────────────────────────────────────────────────────────
const SYSTEM_PROMPT = `Ты аналитическая система для персональной аналитики жизни.

Правила:
- Никакой мотивации и общих советов.
- НЕ выдумывай факты: используй ТОЛЬКО переданные метрики и статистику.
- Не делай причинных утверждений. Только "ассоциировано", "наблюдается тенденция".
- Если данных недостаточно — прямо говори "данных недостаточно" и почему/что нужно собрать.
- Верни ТОЛЬКО валидный JSON массив инсайтов (без markdown).`;

type Insight = {
  type: "goal" | "behavioral" | "emotional" | "habit" | "risk" | "data_quality";
  title: string;
  insight: string;
  impact?: { goal: string; direction: "positive" | "negative" | "mixed"; strength: number };
  evidence: string[];
  suggestion?: string;
};

function buildRuleBasedInsights(snapshot: any, stats: any): Insight[] {
  const out: Insight[] = [];
  const suff = stats?.sufficiency;

  if (!suff?.ok_for_basic) {
    out.push({
      type: "data_quality",
      title: "Недостаточно данных для осмысленной аналитики",
      insight:
        "За выбранный период слишком мало дней с задачами. Я не буду делать выводы, чтобы не вводить в заблуждение.",
      evidence: [
        `Дней с задачами: ${suff?.days_with_tasks ?? 0}`,
        `Рекомендуемый минимум: 7 дней (базовые инсайты), 14+ дней (корреляции).`,
      ],
      suggestion:
        "Отмечай задачи ежедневно минимум 1–2 недели; для корреляций по привычкам/самочувствию нужно, чтобы были и дни с привычкой, и дни без неё.",
    });
    return out;
  }

  // tasks overview
  const t = snapshot.tasks_overview;
  out.push({
    type: "goal",
    title: "Итог по задачам за период",
    insight:
      `Выполнено ${t.completed} из ${t.total} задач (доля выполнения ${(t.completed_ratio * 100).toFixed(0)}%). ` +
      (t.overdue_open > 0 ? `Есть ${t.overdue_open} просроченных невыполненных задач.` : "Просроченных задач нет."),
    evidence: [
      `Задачи всего: ${t.total}`,
      `Выполнено: ${t.completed}`,
      `Просроченных открытых: ${t.overdue_open}`,
      `Суммарно затрачено часов (spent_hours): ${t.total_spent_hours.toFixed(1)}`,
    ],
  });

  // strongest habit effects (only ok)
  const habitOk = (stats.habit_effects as HabitEffect[])
    .filter((x) => x.status === "ok" && x.metric === "tasks_done" && typeof x.delta === "number")
    .sort((a, b) => Math.abs((b.delta ?? 0)) - Math.abs((a.delta ?? 0)))
    .slice(0, 3);

  for (const h of habitOk) {
    const delta = h.delta ?? 0;
    const direction = delta >= 0 ? "positive" : "negative";
    out.push({
      type: "habit",
      title: `Привычка "${h.habit}" и выполнение задач`,
      insight:
        `Наблюдается ассоциация: в дни, когда привычка отмечена, среднее число выполненных задач ` +
        `${delta >= 0 ? "выше" : "ниже"} на ${Math.abs(delta).toFixed(2)}.`,
      impact: { goal: "продуктивность", direction, strength: Math.min(1, Math.abs(delta) / 5) },
      evidence: [
        `Среднее tasks_done при привычке: ${Number(h.m1).toFixed(2)} (дней: ${h.n1})`,
        `Среднее tasks_done без привычки: ${Number(h.m0).toFixed(2)} (дней: ${h.n0})`,
      ],
      suggestion:
        "Это не причинность. Если привычка потенциально мешает — попробуй наблюдать её вместе с контекстом (сон/стресс/нагрузка) ещё 2–3 недели.",
    });
  }

  // mental correlations top (only ok)
  const mentalOk = (stats.mental_effects as MentalEffect[])
    .filter((x) => x.status === "ok" && typeof x.r === "number")
    .slice(0, 2);

  for (const m of mentalOk) {
    out.push({
      type: "emotional",
      title: `Самочувствие "${m.question}" и выполненные задачи`,
      insight:
        `Есть статистическая связь (корреляция): r=${(m.r as number).toFixed(2)} ` +
        `между значением "${m.question}" и количеством выполненных задач.`,
      evidence: [
        `Наблюдений (дней с ответом): ${m.n}`,
        `Метрика: tasks_done`,
      ],
      suggestion:
        "Чтобы сделать выводы надёжнее, нужен период 4+ недель и стабильное заполнение этого вопроса.",
    });
  }

  // user_goals note (data limitation)
  const ug = snapshot.user_goals_overview;
  if ((ug?.total ?? 0) > 0) {
    out.push({
      type: "goal",
      title: "Прогресс по большим целям (user_goals)",
      insight:
        "Прямой прогресс по большим целям нельзя измерить без явной связки 'задача → цель'. Сейчас можно оценивать только косвенно через активность по life_block.",
      evidence: [
        `Целей всего: ${ug.total}`,
        `Целей завершено: ${ug.completed}`,
        `Цели по горизонтам: ${JSON.stringify(ug.by_horizon)}`,
      ],
      suggestion:
        "Если хочешь прямую аналитику по целям: добавь к tasks поле goal_id (ссылка на user_goals) или таблицу связей task_goal_links.",
    });
  }

  // if correlations requested but insufficient
  if (!stats?.sufficiency?.ok_for_correlation) {
    out.push({
      type: "data_quality",
      title: "Корреляции пока рано считать",
      insight:
        "Для корреляций по привычкам/самочувствию нужно больше дней с данными, иначе вывод будет шумным.",
      evidence: [
        `Дней с задачами: ${stats?.sufficiency?.days_with_tasks ?? 0}`,
        "Рекомендуемый минимум: 14 дней (лучше 28+).",
      ],
      suggestion:
        "Заполняй задачи и привычки минимум 2–4 недели, чтобы были и дни 'привычка была', и дни 'привычки не было'.",
    });
  }

  return out.slice(0, 7);
}

async function callLLMToPolish(insights: Insight[], snapshot: any, stats: any): Promise<Insight[]> {
  // If no key, return as-is
  if (!OPENAI_API_KEY) return insights;

  // We allow LLM ONLY to rephrase/compact, NOT to create new facts.
  const prompt = `У тебя есть предварительные инсайты и факты (snapshot/stats).
Задача: улучшить формулировки инсайтов, сохранив смысл и доказательства.
Запрещено добавлять новые утверждения/факты, которых нет в evidence/stats.
Если какой-то инсайт выглядит недоказуемо — удали его.

Верни ТОЛЬКО JSON массив инсайтов того же формата.

insights_in:
${JSON.stringify(insights)}

facts_summary:
${JSON.stringify({ tasks_overview: snapshot.tasks_overview, sufficiency: stats.sufficiency, habit_effects: stats.habit_effects, mental_effects: stats.mental_effects })}`;

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
        { role: "user", content: prompt },
      ],
      text: { format: { type: "json_object" } },
    }),
  });

  if (!r.ok) {
    // If LLM fails, fall back to rule-based
    return insights;
  }

  const data = await r.json();
  const outputText =
    data?.output?.[0]?.content?.[0]?.text ??
    data?.output_text ??
    null;

  if (!outputText) return insights;

  const parsed = JSON.parse(outputText);
  const arr = Array.isArray(parsed) ? parsed : (parsed?.insights && Array.isArray(parsed.insights) ? parsed.insights : null);
  if (!arr) return insights;

  // Basic shape guard
  return arr.filter((x: any) => x && typeof x.title === "string" && Array.isArray(x.evidence));
}

// ─────────────────────────────────────────────
// Save results to Supabase
// ─────────────────────────────────────────────
async function saveRun(userId: string, period: string, fromDay: string, toDay: string, snapshot: any, stats: any, insights: any) {
  // Requires table public.ai_insights_runs
  const payload = {
    user_id: userId,
    period,
    date_from: fromDay,
    date_to: toDay,
    version: "v2",
    model: OPENAI_API_KEY ? OPENAI_MODEL : null,
    snapshot,
    stats,
    insights,
  };

  const { data, error } = await admin
    .from("ai_insights_runs")
    .insert(payload)
    .select("id,created_at")
    .maybeSingle();

  if (error) throw new Error(`ai_insights_runs insert failed: ${error.message}`);
  return data;
}

// ─────────────────────────────────────────────
// Handler
// ─────────────────────────────────────────────
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return jsonResponse({}, 200);

  try {
    if (!SUPABASE_URL) return errorResponse("Missing SUPABASE_URL (or PROJECT_URL)", 500);
    if (!SERVICE_ROLE_KEY) return errorResponse("Missing SERVICE_ROLE_KEY secret", 500);

    const auth = req.headers.get("authorization") ?? "";
    const jwt = auth.startsWith("Bearer ") ? auth.slice(7) : null;
    if (!jwt) return errorResponse("Missing Authorization bearer token", 401);

    const { data: u, error: uErr } = await admin.auth.getUser(jwt);
    if (uErr || !u?.user) return errorResponse("Invalid token", 401, uErr?.message);
    const userId = u.user.id;

    const payload = await req.json().catch(() => ({}));
    const period = payload?.period ?? "last_30_days";
    const polish = payload?.polish_with_llm ?? true; // можно выключать

    const { snapshot, stats, fromDay, toDay } = await buildAnalytics(userId, period);

    // Rule-based insights (never hallucinate)
    let insights = buildRuleBasedInsights(snapshot, stats);

    // Optional: LLM only for phrasing/compacting (not for new facts)
    if (polish) {
      insights = await callLLMToPolish(insights, snapshot, stats);
    }

    // Persist
    const run = await saveRun(userId, period, fromDay, toDay, snapshot, stats, insights);

    return jsonResponse({ run, snapshot, stats, insights }, 200);
  } catch (e) {
    return errorResponse("Unhandled error", 500, String(e));
  }
});
