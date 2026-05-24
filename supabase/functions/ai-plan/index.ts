// supabase/functions/ai-plan/index.ts
// AI Plan v5: concrete goal-linked task planning
// Main idea: generate not generic advice, but actionable tasks that move active user_goals forward.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type Horizon = "week" | "month";
type AnyRow = Record<string, unknown>;

type PlanDraft = {
  title: string;
  description: string;
  life_block: string;
  importance: number;
  planned_hours: number;
  reason: string;
  source: string;
  user_goal_id: string | null;
  source_goal_title?: string;
  source_task_id?: string | null;
  start_time?: string;
  recurring?: string | null;
};

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function asString(v: unknown): string {
  return typeof v === "string" ? v.trim() : "";
}

function asNumber(v: unknown, fallback = 1): number {
  const n = typeof v === "number" ? v : Number(v ?? fallback);
  return Number.isFinite(n) ? n : fallback;
}

function asBool(v: unknown): boolean {
  return v === true;
}

function isPlainObject(v: unknown): v is Record<string, unknown> {
  return !!v && typeof v === "object" && !Array.isArray(v);
}

function isEncryptedPlaceholder(v: unknown): boolean {
  const s = asString(v).toLowerCase();
  return !s || s === "[encrypted]" || s === "encrypted" || s.includes("encrypted_payload");
}

function shortId(v: unknown): string {
  const s = asString(v);
  return s.length >= 8 ? s.slice(0, 8) : s || "item";
}

function safeDisplayText(v: unknown, fallback: string): string {
  const s = asString(v);
  return isEncryptedPlaceholder(s) ? fallback : s;
}

function hasClientContext(body: AnyRow): boolean {
  const ctx = body.client_context;
  if (!isPlainObject(ctx)) return false;

  return Array.isArray(ctx.user_goals) ||
    Array.isArray(ctx.goals) ||
    Array.isArray(ctx.tasks) ||
    Array.isArray(ctx.ai_plan_items);
}

function readClientRows(ctx: unknown, key: string): AnyRow[] {
  if (!isPlainObject(ctx)) return [];
  const rows = ctx[key];
  return Array.isArray(rows)
    ? rows.filter(isPlainObject).map((x) => ({ ...x }))
    : [];
}

function normalizeClientGoal(row: AnyRow): AnyRow {
  const id = asString(row.id);
  return {
    ...row,
    id,
    title: safeDisplayText(row.title, `Цель ${shortId(id)}`),
    description: safeDisplayText(row.description, ""),
    life_block: normalizeLifeBlock(row.life_block),
    horizon: asString(row.horizon) || "tactical",
    is_completed: asBool(row.is_completed),
  };
}

function normalizeClientTask(row: AnyRow): AnyRow {
  const id = asString(row.id);
  return {
    ...row,
    id,
    title: safeDisplayText(row.title, `Задача ${shortId(id)}`),
    description: safeDisplayText(row.description, ""),
    life_block: normalizeLifeBlock(row.life_block),
    is_completed: asBool(row.is_completed),
  };
}

function clampPlannedHours(v: unknown): number {
  return Math.max(0.25, Math.min(8, asNumber(v, 1)));
}

function clampNonNegative(v: unknown): number {
  return Math.max(0, asNumber(v, 0));
}

function clampTargetMinutes(v: unknown): number {
  const n = Math.round(asNumber(v, 0));
  return Math.max(0, n);
}

function clampImportance(v: unknown): number {
  const n = typeof v === "number" ? v : Number(v ?? 3);
  if (!Number.isFinite(n)) return 3;
  return Math.max(1, Math.min(5, Math.round(n)));
}

function normalizePeriod(v: unknown): Horizon {
  const s = asString(v).toLowerCase();
  if (["month", "monthly", "30", "30_days", "last_30_days"].includes(s)) return "month";
  return "week";
}

function normalizeLifeBlock(v: unknown): string {
  const s = asString(v);
  if (!s) return "other";

  const map: Record<string, string> = {
    work: "career",
    career: "career",
    job: "career",
    работа: "career",
    карьера: "career",
    health: "health",
    sport: "health",
    fitness: "health",
    здоровье: "health",
    спорт: "health",
    футбол: "health",
    rest: "health",
    family: "family",
    relationship: "family",
    social: "family",
    семья: "family",
    finance: "finance",
    money: "finance",
    финансы: "finance",
    деньги: "finance",
    education: "education",
    growth: "education",
    study: "education",
    learning: "education",
    обучение: "education",
    образование: "education",
    hobbies: "hobbies",
    hobby: "hobbies",
    хобби: "hobbies",
    other: "other",
  };

  return map[s.toLowerCase()] ?? s.toLowerCase();
}

function parseDateOnly(v: unknown): Date | null {
  const s = asString(v);
  if (!s) return null;
  const d = new Date(`${s}T00:00:00.000Z`);
  return Number.isNaN(d.getTime()) ? null : d;
}

function toDateOnly(d: Date): string {
  return d.toISOString().slice(0, 10);
}

function addDays(date: Date, days: number): Date {
  const d = new Date(date);
  d.setUTCDate(d.getUTCDate() + days);
  return d;
}

function diffDaysInclusive(from: Date, to: Date): number {
  const ms = Date.UTC(to.getUTCFullYear(), to.getUTCMonth(), to.getUTCDate()) -
    Date.UTC(from.getUTCFullYear(), from.getUTCMonth(), from.getUTCDate());
  return Math.max(1, Math.floor(ms / 86400000) + 1);
}

function scheduledDate(index: number, total: number, start: Date, end: Date, period: Horizon): Date {
  const days = diffDaysInclusive(start, end);
  let offset = 0;

  if (period === "week") {
    // spread over week, skipping too much clustering
    offset = Math.min(days - 1, index % Math.max(1, days));
  } else {
    const denominator = Math.max(1, total - 1);
    offset = Math.round((index / denominator) * (days - 1));
  }

  const d = addDays(start, offset);
  const hour = 9 + (index % 4) * 2;
  d.setUTCHours(hour, 0, 0, 0);
  return d;
}

function goalId(g: AnyRow): string {
  return asString(g.id);
}

function goalTitle(g: AnyRow): string {
  const id = goalId(g);
  return safeDisplayText(g.title, `Цель ${shortId(id)}`);
}

function goalLifeBlock(g: AnyRow): string {
  return normalizeLifeBlock(g.life_block);
}

function planItemKey(it: PlanDraft): string {
  return `${it.user_goal_id ?? "none"}|${it.title.toLowerCase()}|${normalizeLifeBlock(it.life_block)}`;
}

function pickExistingColumns(row: AnyRow, columns: Set<string>): AnyRow {
  const out: AnyRow = {};
  for (const [k, v] of Object.entries(row)) {
    if (columns.has(k)) out[k] = v;
  }
  return out;
}

function errorToJson(err: unknown): AnyRow {
  if (err && typeof err === "object") {
    const e = err as AnyRow;
    return {
      message: asString(e.message) || String(err),
      code: asString(e.code),
      details: asString(e.details),
      hint: asString(e.hint),
      raw: JSON.stringify(err),
    };
  }
  return { message: String(err) };
}

async function getColumns(supabase: ReturnType<typeof createClient>, table: string): Promise<Set<string>> {
  const { data, error } = await supabase
    .from("information_schema.columns")
    .select("column_name")
    .eq("table_schema", "public")
    .eq("table_name", table);

  if (error) {
    if (table === "ai_plans") return new Set(["id", "user_id", "horizon", "created_at"]);
    if (table === "ai_plan_items") {
      return new Set([
        "id",
        "user_id",
        "plan_id",
        "title",
        "description",
        "life_block",
        "importance",
        "planned_hours",
        "reason",
        "state",
        "start_time",
        "created_at",
      ]);
    }
  }

  return new Set((data ?? []).map((r: AnyRow) => asString(r.column_name)).filter(Boolean));
}

function cleanTaskTitle(s: string): string {
  const title = s.replace(/\s+/g, " ").trim();
  if (title.length <= 125) return title;
  return `${title.slice(0, 122)}...`;
}

function inferHours(task: AnyRow, period: Horizon): number {
  const spent = asNumber(task.spent_hours, 0);
  if (spent > 0) return Math.max(0.25, Math.min(3, spent));
  return period === "month" ? 1.25 : 1;
}

function containsAny(s: string, words: string[]): boolean {
  const lower = s.toLowerCase();
  return words.some((w) => lower.includes(w.toLowerCase()));
}

function extractNumber(s: string): number | null {
  const m = s.match(/(\d+)/);
  if (!m) return null;
  const n = Number(m[1]);
  return Number.isFinite(n) ? n : null;
}

function incrementSequenceTitle(title: string): string | null {
  const patterns = [
    /(урок|lesson|модуль|module|глава|chapter|лекция|lecture)\s*№?\s*(\d+)/i,
    /(день|day)\s*№?\s*(\d+)/i,
  ];
  for (const p of patterns) {
    const m = title.match(p);
    if (!m) continue;
    const current = Number(m[2]);
    if (!Number.isFinite(current)) continue;
    return title.replace(m[0], `${m[1]} ${current + 1}`);
  }
  return null;
}

type GoalDomain =
  | "football"
  | "fitness"
  | "language"
  | "programming"
  | "career"
  | "finance"
  | "writing"
  | "reading"
  | "nutrition"
  | "relationship"
  | "generic";

function detectDomain(goal: AnyRow): GoalDomain {
  const text = `${goalTitle(goal)} ${asString(goal.description)} ${goalLifeBlock(goal)}`.toLowerCase();
  if (containsAny(text, ["футбол", "football", "soccer"])) return "football";
  if (containsAny(text, ["зал", "gym", "трениров", "fitness", "спорт", "бег", "run", "мышц", "вес", "body"])) return "fitness";
  if (containsAny(text, ["немец", "англий", "language", "язык", "deutsch", "english", "слова", "grammar", "граммат"])) return "language";
  if (containsAny(text, ["flutter", "dart", "python", "javascript", "код", "app", "прилож", "программ", "supabase", "sap", "hana"])) return "programming";
  if (containsAny(text, ["карьер", "работ", "job", "cv", "резюме", "interview", "собесед", "сертифик", "promotion", "зарплат"])) return "career";
  if (containsAny(text, ["финанс", "деньг", "инвест", "акци", "budget", "бюджет", "накоп", "saving", "портфель"])) return "finance";
  if (containsAny(text, ["диссер", "стать", "напис", "publication", "текст", "chapter", "глава", "раздел"])) return "writing";
  if (containsAny(text, ["прочит", "книга", "reading", "read", "литератур"])) return "reading";
  if (containsAny(text, ["еда", "калор", "питани", "diet", "nutrition", "завтрак", "ужин"])) return "nutrition";
  if (containsAny(text, ["сем", "отнош", "жена", "девуш", "family", "relationship", "liza", "лиза"])) return "relationship";
  return "generic";
}

function actionTemplatesForGoal(goal: AnyRow, period: Horizon): Array<{ title: string; desc: string; hours: number; importance: number; recurring?: string | null }> {
  const g = cleanTaskTitle(goalTitle(goal));
  const domain = detectDomain(goal);
  const month = period === "month";

  const map: Record<GoalDomain, Array<{ title: string; desc: string; hours: number; importance: number; recurring?: string | null }>> = {
    football: [
      {
        title: `Тренировка по футболу: 10 мин разминки + 25 мин техники + 10 мин заминки`,
        desc: `Конкретный шаг к цели «${g}»: потренировать базовую технику и физическую форму.`,
        hours: 0.75,
        importance: 4,
      },
      {
        title: `Отработать 50 касаний мяча и 20 передач в стену`,
        desc: `Измеримая футбольная задача для цели «${g}».`,
        hours: 0.75,
        importance: 4,
      },
      {
        title: `Посмотреть 15 минут обучающего видео по футболу и выписать 3 упражнения`,
        desc: `Задача даёт понятный следующий набор упражнений для цели «${g}».`,
        hours: 0.5,
        importance: 3,
      },
      {
        title: `Сыграть или организовать одну футбольную тренировку/матч`,
        desc: `Практический шаг: не просто подумать о цели, а выйти в игру.`,
        hours: 1.5,
        importance: 5,
      },
    ],
    fitness: [
      {
        title: `Сделать тренировку: 10 мин разминки + 3 упражнения по 3 подхода`,
        desc: `Конкретная тренировка для продвижения цели «${g}».`,
        hours: 1,
        importance: 4,
      },
      {
        title: `Записать текущие показатели: вес, энергия, сон и 1 фото прогресса`,
        desc: `Без измерения прогресса цель «${g}» сложнее контролировать.`,
        hours: 0.25,
        importance: 3,
      },
      {
        title: `Пройти 8–10 тыс. шагов и отметить самочувствие вечером`,
        desc: `Небольшой, но измеримый вклад в здоровье.`,
        hours: 1,
        importance: 3,
      },
    ],
    language: [
      {
        title: `Выучить 20 новых слов и составить 5 предложений`,
        desc: `Конкретная языковая практика для цели «${g}».`,
        hours: 0.75,
        importance: 4,
      },
      {
        title: `Пройти один урок и сделать 10 упражнений`,
        desc: `Продвижение по учебному материалу с проверяемым результатом.`,
        hours: 1,
        importance: 4,
      },
      {
        title: `Записать 2-минутный монолог и отметить 3 ошибки`,
        desc: `Практика речи для цели «${g}», а не пассивное изучение.`,
        hours: 0.5,
        importance: 4,
      },
      {
        title: `Повторить старые слова 15 минут и удалить те, которые уже знаешь`,
        desc: `Поддержание базы, чтобы прогресс не откатывался.`,
        hours: 0.25,
        importance: 3,
      },
    ],
    programming: [
      {
        title: `Реализовать один маленький экран/метод для цели «${g}»`,
        desc: `Не общий прогресс, а конкретный deliverable в коде.`,
        hours: 1.5,
        importance: 4,
      },
      {
        title: `Исправить одну ошибку и записать причину в заметку`,
        desc: `Техническая задача с результатом: ошибка закрыта, причина понятна.`,
        hours: 1,
        importance: 4,
      },
      {
        title: `Сделать refactor одного файла и проверить запуск приложения`,
        desc: `Улучшение качества проекта, связанного с целью «${g}».`,
        hours: 1,
        importance: 3,
      },
    ],
    career: [
      {
        title: `Сделать один карьерный deliverable по цели «${g}»`,
        desc: `Завершить маленький, но видимый результат: документ, письмо, подготовка или решение.`,
        hours: 1,
        importance: 4,
      },
      {
        title: `Обновить список следующих 3 шагов по цели «${g}»`,
        desc: `Сделать цель управляемой: что именно делать дальше и в каком порядке.`,
        hours: 0.5,
        importance: 3,
      },
      {
        title: `Подготовить один аргумент/пример результата для карьерного роста`,
        desc: `Материал для будущего performance review, резюме или переговоров.`,
        hours: 0.75,
        importance: 4,
      },
    ],
    finance: [
      {
        title: `Обновить бюджет: доходы, расходы, накопления за последние 7 дней`,
        desc: `Финансовая цель «${g}» требует регулярной сверки цифр.`,
        hours: 0.5,
        importance: 4,
      },
      {
        title: `Найти одну статью расходов для сокращения и записать действие`,
        desc: `Конкретное улучшение финансового поведения, а не общий анализ.`,
        hours: 0.5,
        importance: 3,
      },
      {
        title: `Проверить портфель/накопления и зафиксировать одно решение`,
        desc: `Задача должна закончиться решением: купить, не покупать, отложить, изучить.`,
        hours: 0.75,
        importance: 4,
      },
    ],
    writing: [
      {
        title: `Написать 500–700 слов по цели «${g}»`,
        desc: `Конкретный объём текста, который реально продвигает цель.`,
        hours: 1.5,
        importance: 5,
      },
      {
        title: `Составить структуру одного раздела: 5 пунктов + логика переходов`,
        desc: `Подготовка к написанию без хаоса.`,
        hours: 1,
        importance: 4,
      },
      {
        title: `Отредактировать один готовый фрагмент и убрать повторы`,
        desc: `Повышение качества уже созданного материала.`,
        hours: 1,
        importance: 4,
      },
    ],
    reading: [
      {
        title: `Прочитать 20 страниц и выписать 3 полезные идеи`,
        desc: `Чтение превращается в результат, если после него есть выводы.`,
        hours: 0.75,
        importance: 3,
      },
      {
        title: `Сделать короткий конспект прочитанного: 5 тезисов`,
        desc: `Фиксация прогресса по цели «${g}».`,
        hours: 0.5,
        importance: 3,
      },
    ],
    nutrition: [
      {
        title: `Запланировать 3 приёма пищи на завтра и купить недостающие продукты`,
        desc: `Конкретный шаг для цели «${g}», чтобы не принимать решения в последний момент.`,
        hours: 0.5,
        importance: 4,
      },
      {
        title: `Записать питание за день и отметить, где было лишнее/недостающее`,
        desc: `Без записи сложно понять, что реально улучшать.`,
        hours: 0.25,
        importance: 3,
      },
    ],
    relationship: [
      {
        title: `Запланировать 45 минут качественного времени без телефона`,
        desc: `Конкретное действие для цели «${g}».`,
        hours: 0.75,
        importance: 4,
      },
      {
        title: `Обсудить один открытый вопрос и договориться о следующем шаге`,
        desc: `Задача должна закончиться договорённостью, а не абстрактным разговором.`,
        hours: 0.75,
        importance: 4,
      },
    ],
    generic: [
      {
        title: `Сделать один измеримый шаг по цели «${g}» и записать результат`,
        desc: `Сформулируй результат в конце: что изменилось после выполнения задачи.`,
        hours: 1,
        importance: 4,
      },
      {
        title: `Разбить цель «${g}» на 3 конкретных действия`,
        desc: `После этого AI сможет предлагать более точный план.`,
        hours: 0.5,
        importance: 4,
      },
      {
        title: `Закрыть самый маленький следующий шаг по цели «${g}»`,
        desc: `Минимальное действие, которое уменьшает расстояние до цели.`,
        hours: 0.75,
        importance: 3,
      },
    ],
  };

  const base = map[domain] ?? map.generic;
  return month ? [...base, ...base] : base;
}

function makeContinuationTitle(task: AnyRow, goal: AnyRow): string {
  const rawTaskTitle = safeDisplayText(task.title, "");
  const taskTitle = cleanTaskTitle(rawTaskTitle);
  const g = cleanTaskTitle(goalTitle(goal));
  if (!taskTitle) return `Сделать конкретный шаг по цели «${g}»`;

  if (!asBool(task.is_completed)) {
    return `Завершить: ${taskTitle}`;
  }

  const inc = incrementSequenceTitle(taskTitle);
  if (inc && inc !== taskTitle) return `Продолжить: ${cleanTaskTitle(inc)}`;

  const lower = taskTitle.toLowerCase();
  const n = extractNumber(taskTitle);

  if (containsAny(lower, ["слов", "words", "vocab"])) {
    return `Выучить ${n ?? 20} новых слов и повторить старые`;
  }
  if (containsAny(lower, ["урок", "lesson", "модуль"])) {
    return `Пройти следующий урок и сделать упражнения`;
  }
  if (containsAny(lower, ["трениров", "зал", "спорт", "футбол", "football"])) {
    return `Повторить тренировку и добавить 1 усложнение`;
  }
  if (containsAny(lower, ["напис", "статья", "глава", "раздел", "текст"])) {
    return `Написать следующий фрагмент: 500–700 слов`;
  }
  if (containsAny(lower, ["прочит", "книга", "read"])) {
    return `Прочитать следующие 20 страниц и выписать 3 идеи`;
  }
  if (containsAny(lower, ["код", "fix", "bug", "flutter", "supabase", "реализ"])) {
    return `Продолжить разработку: закрыть один маленький технический шаг`;
  }

  const alreadyActionLike = /^(пройти|прочитать|сделать|подготовить|написать|изучить|выучить|тренировка|проверить|создать|обновить|разобрать|повторить|закрыть|исправить)/i.test(taskTitle);
  if (alreadyActionLike) return `Повторить/продолжить: ${taskTitle}`;

  return `Сделать следующий шаг после задачи: ${taskTitle}`;
}

function makeStarterTask(goal: AnyRow, index: number, period: Horizon): PlanDraft {
  const title = cleanTaskTitle(goalTitle(goal));
  const block = goalLifeBlock(goal);
  const templates = actionTemplatesForGoal(goal, period);
  const t = templates[index % templates.length];
  const horizon = asString(goal.horizon);

  return {
    title: cleanTaskTitle(t.title),
    description: t.desc || asString(goal.description) || `Конкретный шаг к большой цели «${title}».`,
    life_block: block,
    importance: Math.max(t.importance, horizon === "long" || period === "month" ? 4 : 3),
    planned_hours: t.hours,
    reason: `Конкретный шаг к цели: ${title}`,
    source: "user_goals_concrete_template",
    user_goal_id: goalId(goal),
    source_goal_title: title,
    recurring: t.recurring ?? null,
  };
}

function buildGoalScore(goal: AnyRow, tasks: AnyRow[], now: Date): number {
  let score = 0;

  const horizon = asString(goal.horizon);
  if (horizon === "tactical") score += 5;
  if (horizon === "mid") score += 3;
  if (horizon === "long") score += 2;

  const targetDate = parseDateOnly(goal.target_date);
  if (targetDate) {
    const daysLeft = Math.ceil((targetDate.getTime() - now.getTime()) / 86400000);
    if (daysLeft < 0) score += 8;
    else if (daysLeft <= 7) score += 7;
    else if (daysLeft <= 30) score += 4;
  }

  if (tasks.length === 0) score += 5;
  else {
    const unfinished = tasks.filter((t) => !asBool(t.is_completed)).length;
    score += Math.min(6, unfinished * 2);
  }

  score += Math.max(0, 8 - tasks.length);
  return score;
}

function buildActionablePlanItems(params: {
  period: Horizon;
  userGoals: AnyRow[];
  recentGoals: AnyRow[];
  periodStart: Date;
  periodEnd: Date;
  requestedLifeBlock: string;
  hasRequestedLifeBlock: boolean;
}): PlanDraft[] {
  const { period, userGoals, recentGoals, periodStart, requestedLifeBlock, hasRequestedLifeBlock } = params;
  const maxItems = period === "month" ? 18 : 8;
  const maxPerGoal = period === "month" ? 5 : 3;

  const goalsById = new Map(userGoals.map((g) => [goalId(g), g]));
  const tasksByGoal = new Map<string, AnyRow[]>();

  for (const t of recentGoals) {
    const gid = asString(t.user_goal_id);
    if (!gid || !goalsById.has(gid)) continue;
    const arr = tasksByGoal.get(gid) ?? [];
    arr.push(t);
    tasksByGoal.set(gid, arr);
  }

  const candidates = userGoals
    .filter((g) => !hasRequestedLifeBlock || goalLifeBlock(g) === requestedLifeBlock)
    .map((g) => ({
      goal: g,
      tasks: tasksByGoal.get(goalId(g)) ?? [],
      score: buildGoalScore(g, tasksByGoal.get(goalId(g)) ?? [], periodStart),
    }))
    .sort((a, b) => b.score - a.score);

  const drafts: PlanDraft[] = [];

  for (const c of candidates) {
    if (drafts.length >= maxItems) break;

    const g = c.goal;
    const gid = goalId(g);
    const goalName = cleanTaskTitle(goalTitle(g));
    const block = goalLifeBlock(g);

    const unfinished = c.tasks.filter((t) => !asBool(t.is_completed) && asString(t.title));
    const completed = c.tasks.filter((t) => asBool(t.is_completed) && asString(t.title));
    const orderedTasks = [...unfinished, ...completed].slice(0, Math.max(1, Math.floor(maxPerGoal / 2)));

    let addedForGoal = 0;

    for (const task of orderedTasks) {
      if (drafts.length >= maxItems || addedForGoal >= maxPerGoal) break;

      drafts.push({
        title: makeContinuationTitle(task, g),
        description: `Цель: ${goalName}. Основано на твоей прошлой задаче «${cleanTaskTitle(asString(task.title))}».`,
        life_block: block,
        importance: Math.max(clampImportance(task.importance), asString(g.horizon) === "long" ? 4 : 3),
        planned_hours: inferHours(task, period),
        reason: asBool(task.is_completed)
          ? `Следующий конкретный шаг по цели: ${goalName}`
          : `Нужно закрыть незавершённый шаг по цели: ${goalName}`,
        source: "past_goal_tasks_concrete",
        user_goal_id: gid,
        source_goal_title: goalName,
        source_task_id: asString(task.id) || null,
      });
      addedForGoal++;
    }

    while (drafts.length < maxItems && addedForGoal < maxPerGoal) {
      drafts.push(makeStarterTask(g, addedForGoal, period));
      addedForGoal++;
    }
  }

  if (drafts.length === 0) {
    const block = hasRequestedLifeBlock ? requestedLifeBlock : "career";
    drafts.push(
      {
        title: period === "month" ? "Выбрать 3 главные цели месяца и записать первый шаг к каждой" : "Выбрать 3 главные цели недели и записать первый шаг к каждой",
        description: "Сначала нужны активные большие цели. После этого AI сможет строить конкретный план действий.",
        life_block: block,
        importance: 4,
        planned_hours: 1,
        reason: "Недостаточно активных больших целей",
        source: "fallback_no_user_goals",
        user_goal_id: null,
      },
      {
        title: "Создать одну маленькую задачу и привязать её к большой цели",
        description: "После появления связанных задач AI будет предлагать следующие действия на основе истории.",
        life_block: block,
        importance: 3,
        planned_hours: 0.5,
        reason: "Нужно накопить историю задач по целям",
        source: "fallback_no_user_goals",
        user_goal_id: null,
      },
    );
  }

  const seen = new Set<string>();
  return drafts
    .filter((it) => {
      const key = planItemKey(it);
      if (!it.title || seen.has(key)) return false;
      seen.add(key);
      return true;
    })
    .slice(0, maxItems);
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return jsonResponse({ ok: false, error: "Method not allowed" }, 405);

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !serviceRoleKey) {
      return jsonResponse({ ok: false, error: "Missing Supabase environment variables" }, 500);
    }

    const authHeader = req.headers.get("Authorization") ?? "";

    const userClient = createClient(supabaseUrl, serviceRoleKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false },
    });

    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData.user?.id) {
      return jsonResponse({ ok: false, error: "Unauthorized: cannot resolve current user", details: userError }, 401);
    }

    const userId = userData.user.id;

    const supabase = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false },
    });

    const body = await req.json().catch(() => ({})) as AnyRow;
    const period = normalizePeriod(body.period ?? body.horizon);

    const clientContextUsed = hasClientContext(body);
    if (clientContextUsed && body.ai_consent !== true) {
      return jsonResponse({
        ok: false,
        error: "AI consent is required when client_context contains locally decrypted user data.",
        code: "AI_CONSENT_REQUIRED",
      }, 403);
    }

    const now = new Date();
    const requestStart = parseDateOnly(body.date_from ?? body.date) ?? now;
    const periodStart = new Date(requestStart);
    periodStart.setUTCHours(0, 0, 0, 0);

    const periodEnd = parseDateOnly(body.date_to) ?? addDays(periodStart, period === "month" ? 29 : 6);
    periodEnd.setUTCHours(23, 59, 59, 999);

    const contextStart = addDays(periodStart, period === "month" ? -120 : -60);

    const [planColumns, itemColumns] = await Promise.all([
      getColumns(supabase, "ai_plans"),
      getColumns(supabase, "ai_plan_items"),
    ]);

    const { data: insightRun } = await supabase
      .from("ai_insights_runs")
      .select("id, created_at, period, date_from, date_to, insights, stats")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    const rawRequestedLifeBlock = asString(body.life_block);
    const hasRequestedLifeBlock = rawRequestedLifeBlock.length > 0;
    const requestedLifeBlock = hasRequestedLifeBlock ? normalizeLifeBlock(rawRequestedLifeBlock) : "";

    let userGoals: AnyRow[] = [];
    let recentGoals: AnyRow[] = [];

    if (clientContextUsed) {
      const ctx = body.client_context;
      userGoals = readClientRows(ctx, "user_goals")
        .map(normalizeClientGoal)
        .filter((g) => !asBool(g.is_completed))
        .filter((g) => !hasRequestedLifeBlock || goalLifeBlock(g) === requestedLifeBlock)
        .slice(0, 40);

      recentGoals = [
        ...readClientRows(ctx, "goals"),
        ...readClientRows(ctx, "tasks"),
      ]
        .map(normalizeClientTask)
        .filter((t) => {
          const st = parseDateOnly(t.start_time) ?? (asString(t.start_time) ? new Date(asString(t.start_time)) : null);
          if (!st || Number.isNaN(st.getTime())) return true;
          return st >= contextStart;
        })
        .slice(0, 500);
    } else {
      let goalsQuery = supabase
        .from("user_goals")
        .select("id, title, description, life_block, horizon, target_date, is_completed, sort_order, created_at")
        .eq("user_id", userId)
        .eq("is_completed", false)
        .order("sort_order", { ascending: true })
        .order("created_at", { ascending: false })
        .limit(40);

      if (hasRequestedLifeBlock) goalsQuery = goalsQuery.eq("life_block", requestedLifeBlock);

      const { data: userGoalsRaw, error: userGoalsError } = await goalsQuery;
      if (userGoalsError) {
        return jsonResponse({ ok: false, stage: "load_user_goals", error: errorToJson(userGoalsError) }, 500);
      }

      userGoals = (Array.isArray(userGoalsRaw) ? userGoalsRaw as AnyRow[] : [])
        .map(normalizeClientGoal);

      const goalIds = userGoals.map(goalId).filter(Boolean);

      if (goalIds.length > 0) {
        const { data: goalsRaw, error: goalsError } = await supabase
          .from("goals")
          .select("id, title, description, life_block, importance, is_completed, spent_hours, start_time, deadline, user_goal_id, created_at")
          .eq("user_id", userId)
          .in("user_goal_id", goalIds)
          .gte("start_time", contextStart.toISOString())
          .order("start_time", { ascending: false })
          .limit(500);

        if (goalsError) {
          return jsonResponse({ ok: false, stage: "load_goals", error: errorToJson(goalsError) }, 500);
        }

        recentGoals = (Array.isArray(goalsRaw) ? goalsRaw as AnyRow[] : [])
          .map(normalizeClientTask);
      }
    }

    const drafts = buildActionablePlanItems({
      period,
      userGoals,
      recentGoals,
      periodStart,
      periodEnd,
      requestedLifeBlock,
      hasRequestedLifeBlock,
    });

    const finalItems = drafts.map((it, index) => {
      const itemDate = scheduledDate(index, drafts.length, periodStart, periodEnd, period);
      return {
        user_id: userId,
        title: cleanTaskTitle(it.title) || "AI-задача",
        description: it.description,
        life_block: normalizeLifeBlock(it.life_block),
        importance: clampImportance(it.importance),
        planned_hours: clampPlannedHours(it.planned_hours),
        reason: it.reason,
        state: "suggested",
        start_time: itemDate.toISOString(),
        user_goal_id: it.user_goal_id,
        source_task_id: it.source_task_id ?? null,
        recurring: it.recurring ?? null,
      };
    });

    if (clientContextUsed) {
      const temporaryPlan = {
        id: null,
        user_id: userId,
        horizon: period,
        period,
        date_from: toDateOnly(periodStart),
        date_to: toDateOnly(periodEnd),
        source_insight_run_id: insightRun?.id ?? null,
        input_snapshot: {
          strategy: "concrete_goal_linked_tasks_v5_encryption_aware_encryption_aware",
          period,
          date_from: toDateOnly(periodStart),
          date_to: toDateOnly(periodEnd),
          latest_insight_run_id: insightRun?.id ?? null,
          active_user_goals_count: userGoals.length,
          linked_history_tasks_count: recentGoals.length,
          auto_distribution: true,
          link_user_goal_id: true,
          generated_at: now.toISOString(),
          client_context_used: true,
          persisted_server_side: false,
        },
      };

      const responseItems = finalItems.map((it, index) => ({
        id: null,
        plan_id: null,
        ...it,
        sort_order: index,
      }));

      return jsonResponse({
        ok: true,
        plan_id: null,
        plan: temporaryPlan,
        items: responseItems,
        requires_client_side_persist: true,
        reason: "client_context_used_with_locally_decrypted_data",
        meta: {
          strategy: "concrete_goal_linked_tasks_v5_encryption_aware_encryption_aware",
          period,
          date_from: toDateOnly(periodStart),
          date_to: toDateOnly(periodEnd),
          active_user_goals_count: userGoals.length,
          linked_history_tasks_count: recentGoals.length,
          auto_distribution: true,
          link_user_goal_id: true,
          client_context_used: true,
          persisted_server_side: false,
        },
      });
    }

    const desiredPlanRow: AnyRow = {
      user_id: userId,
      horizon: period,
      period,
      date_from: toDateOnly(periodStart),
      date_to: toDateOnly(periodEnd),
      source_insight_run_id: insightRun?.id ?? null,
      input_snapshot: {
        strategy: "concrete_goal_linked_tasks_v5_encryption_aware",
        period,
        date_from: toDateOnly(periodStart),
        date_to: toDateOnly(periodEnd),
        latest_insight_run_id: insightRun?.id ?? null,
        active_user_goals_count: userGoals.length,
        linked_history_tasks_count: recentGoals.length,
        auto_distribution: true,
        link_user_goal_id: true,
        generated_at: now.toISOString(),
      },
    };

    const planInsert = pickExistingColumns(desiredPlanRow, planColumns);
    const { data: plan, error: planError } = await supabase
      .from("ai_plans")
      .insert(planInsert)
      .select("*")
      .single();

    if (planError) {
      return jsonResponse({ ok: false, stage: "insert_ai_plans", error: errorToJson(planError), inserted: planInsert }, 500);
    }

    const planId = asString(plan.id);
    const rowsToInsert = finalItems.map((it) => pickExistingColumns({ ...it, plan_id: planId }, itemColumns));

    const { data: insertedItems, error: itemsError } = await supabase
      .from("ai_plan_items")
      .insert(rowsToInsert)
      .select("*");

    if (itemsError) {
      return jsonResponse({ ok: false, stage: "insert_ai_plan_items", error: errorToJson(itemsError), inserted_sample: rowsToInsert[0] ?? null }, 500);
    }

    const itemsFromDb = Array.isArray(insertedItems) ? insertedItems as AnyRow[] : [];

    const responseItems = itemsFromDb.map((row, i) => ({
      ...row,
      user_goal_id: row.user_goal_id ?? finalItems[i]?.user_goal_id ?? null,
      source_task_id: row.source_task_id ?? finalItems[i]?.source_task_id ?? null,
      recurring: row.recurring ?? finalItems[i]?.recurring ?? null,
    }));

    return jsonResponse({
      ok: true,
      plan_id: planId,
      plan,
      items: responseItems,
      meta: {
        strategy: "concrete_goal_linked_tasks_v5_encryption_aware",
        period,
        date_from: toDateOnly(periodStart),
        date_to: toDateOnly(periodEnd),
        active_user_goals_count: userGoals.length,
        linked_history_tasks_count: recentGoals.length,
        auto_distribution: true,
        link_user_goal_id: true,
        user_goal_id_persisted: itemColumns.has("user_goal_id"),
        client_context_used: false,
        persisted_server_side: true,
      },
    });
  } catch (err) {
    return jsonResponse({ ok: false, stage: "unexpected", error: errorToJson(err) }, 500);
  }
});
