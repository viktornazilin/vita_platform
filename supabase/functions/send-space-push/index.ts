// supabase/functions/send-space-push/index.ts
//
// Триггерится Database Webhook'ами (настраиваются в дашборде Supabase, см.
// инструкцию) на:
//   - INSERT в space_invites → "Тебя пригласили в пространство"
//   - UPDATE в goals         → "Тебе назначили задачу" / "Готово в пространстве"
//
// Payload Database Webhook всегда содержит и record (новая версия строки),
// и old_record (версия до изменения) — этого достаточно, чтобы понять, что
// именно поменялось (assigned_to, is_completed), без похода в Dart-код.

import { createClient } from "npm:@supabase/supabase-js@2";
import admin from "npm:firebase-admin@12";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("DB_WEBHOOK_SECRET")!;
const FIREBASE_SERVICE_ACCOUNT_JSON = Deno.env.get(
  "FIREBASE_SERVICE_ACCOUNT_JSON",
)!;

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(
      JSON.parse(FIREBASE_SERVICE_ACCOUNT_JSON),
    ),
  });
}

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

Deno.serve(async (req) => {
  // Простая защита: Database Webhook шлёт этот секрет в заголовке (мы сами
  // его задаём при настройке вебхука в дашборде) — без него кто угодно мог
  // бы дёргать этот публичный URL и слать произвольные push.
  const secret = req.headers.get("x-webhook-secret");
  if (secret !== WEBHOOK_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }

  let payload: any;
  try {
    payload = await req.json();
  } catch {
    return new Response("Bad request", { status: 400 });
  }

  const { table, type, record, old_record } = payload;

  try {
    if (table === "space_invites" && type === "INSERT") {
      await handleSpaceInvite(record);
    } else if (table === "goals" && (type === "UPDATE" || type === "INSERT")) {
      // INSERT тоже нужен: createGoal/createGoalsBulk может проставить
      // assigned_to сразу при создании (не только через последующий
      // update) — тогда old_record будет отсутствовать, и это ок:
      // handleGoalUpdate ниже корректно трактует "нет старого значения" как
      // "было пусто", то есть назначение всё равно будет замечено.
      await handleGoalUpdate(record, old_record, type);
    }
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
    });
  }

  return new Response(JSON.stringify({ ok: true }), { status: 200 });
});

async function handleSpaceInvite(record: any) {
  const email = (record.email as string | null)?.toLowerCase();
  if (!email) return;

  // space_invites хранит email, а не user_id (приглашённый мог ещё не
  // зарегистрироваться) — резолвим через Auth Admin API. Если человека с
  // таким email нет — просто выходим, push слать некому (когда он
  // зарегистрируется и зайдёт, приглашение он увидит и так, через
  // listIncomingSpaceInvites).
  const { data: userList, error } = await supabase.auth.admin.listUsers();
  if (error) throw error;
  const invitedUser = userList.users.find(
    (u) => u.email?.toLowerCase() === email,
  );
  if (!invitedUser) return;

  const [{ data: space }, { data: inviter }] = await Promise.all([
    supabase.from("spaces").select("name").eq("id", record.space_id)
      .maybeSingle(),
    supabase.from("users").select("name").eq("id", record.invited_by)
      .maybeSingle(),
  ]);

  const spaceName = space?.name ?? "пространство";
  const inviterName = inviter?.name?.trim() || "Кто-то";

  await sendPushToUser(invitedUser.id, {
    title: "🤝 Тебя пригласили в пространство",
    body: `${inviterName} зовёт тебя в «${spaceName}»`,
    data: { type: "space_invite", space_id: String(record.space_id) },
  });
}

async function handleGoalUpdate(record: any, oldRecord: any, eventType: string) {
  // Сценарий 1: назначили задачу (assigned_to появился/сменился). Работает
  // и для INSERT (назначили сразу при создании), и для UPDATE.
  const assignedChanged = record.assigned_to &&
    record.assigned_to !== oldRecord?.assigned_to;
  if (assignedChanged && record.assigned_to !== record.user_id) {
    const timeLabel = record.start_time ? formatTime(record.start_time) : "";
    await sendPushToUser(record.assigned_to, {
      title: "👥 Тебе назначили задачу",
      body: timeLabel
        ? `«${record.title}» — ${timeLabel}`
        : `«${record.title}»`,
      data: { type: "goal_assigned", goal_id: String(record.id) },
    });
    return;
  }

  // Сценарий 2: завершили общую цель (is_completed false → true). Только
  // для UPDATE — если цель вставлена уже завершённой (например, bulk-импорт
  // повторяющихся целей с is_completed: true), это не момент, когда кто-то
  // её только что выполнил на глазах у остальных, уведомлять не нужно.
  if (eventType !== "UPDATE") return;

  const justCompleted = record.is_completed === true &&
    oldRecord?.is_completed !== true;
  if (justCompleted && record.space_id && record.completed_by) {
    const { data: members } = await supabase
      .from("space_members")
      .select("user_id")
      .eq("space_id", record.space_id)
      .eq("status", "active");

    const [{ data: completer }, { data: space }] = await Promise.all([
      supabase.from("users").select("name").eq("id", record.completed_by)
        .maybeSingle(),
      supabase.from("spaces").select("name").eq("id", record.space_id)
        .maybeSingle(),
    ]);

    const completerName = completer?.name?.trim() || "Кто-то";
    const spaceName = space?.name ?? "пространстве";

    const recipients = (members ?? [])
      .map((m: any) => m.user_id as string)
      .filter((id: string) => id !== record.completed_by);

    await Promise.all(
      recipients.map((userId) =>
        sendPushToUser(userId, {
          title: `✅ Готово в пространстве «${spaceName}»`,
          body: `${completerName} отметил «${record.title}» выполненным`,
          data: { type: "goal_completed", goal_id: String(record.id) },
        })
      ),
    );
  }
}

function formatTime(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleTimeString("ru-RU", {
    hour: "2-digit",
    minute: "2-digit",
    timeZone: "UTC",
  });
}

async function sendPushToUser(
  userId: string,
  payload: { title: string; body: string; data?: Record<string, string> },
) {
  const { data: tokens, error } = await supabase
    .from("device_tokens")
    .select("token")
    .eq("user_id", userId);

  if (error || !tokens || tokens.length === 0) return;

  await Promise.all(
    tokens.map(async (row) => {
      try {
        await admin.messaging().send({
          token: row.token,
          notification: { title: payload.title, body: payload.body },
          data: payload.data ?? {},
          apns: { payload: { aps: { sound: "default" } } },
        });
      } catch (e: any) {
        // Токен больше не валиден (приложение удалили/переустановили) —
        // чистим, чтобы не пытаться слать сюда снова каждый раз.
        if (
          e?.code === "messaging/registration-token-not-registered" ||
          e?.code === "messaging/invalid-registration-token"
        ) {
          await supabase.from("device_tokens").delete().eq(
            "token",
            row.token,
          );
        } else {
          console.error("FCM send error:", e);
        }
      }
    }),
  );
}