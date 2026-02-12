import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
const OPENAI_MODEL = Deno.env.get("OPENAI_MODEL") ?? "gpt-4.1-mini";

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

const SYSTEM_PROMPT = `You convert messy OCR text from a handwritten daily journal into structured tasks.
Rules:
- Do NOT invent tasks not present in the text.
- Keep Russian output by default (unless locale says otherwise).
- If time is missing, use empty string (do not guess).
- If duration is missing, keep hours=1.
- Keep description empty unless it clearly exists in text.
Return ONLY valid JSON object with fields: cleanedText, tasks.
tasks item schema:
{
  "title": string,
  "description": string,
  "startTime": "HH:MM" | "",
  "hours": number,
  "lifeBlock": "general",
  "importance": 1|2|3,
  "emotion": ""
}`;

// Небольшой санитайзер времени
function normalizeTime(t: unknown): string {
  const s = String(t ?? "").trim();
  if (!s) return "";
  const m = s.match(/^(\d{1,2})[:.](\d{2})$/);
  if (!m) return "";
  const hh = Math.min(23, Math.max(0, Number(m[1])));
  const mm = Math.min(59, Math.max(0, Number(m[2])));
  const HH = String(hh).padStart(2, "0");
  const MM = String(mm).padStart(2, "0");
  return `${HH}:${MM}`;
}

function toImportance(x: unknown): 1 | 2 | 3 {
  const n = Number(x);
  if (n === 1) return 1;
  if (n === 3) return 3;
  return 2;
}

function toHours(x: unknown): number {
  const n = Number(x);
  if (!Number.isFinite(n)) return 1;
  // разумные границы
  return Math.min(24, Math.max(0.25, n));
}

async function callOpenAI(text: string, locale: string) {
  const userPrompt = `Locale: ${locale || "ru"}
OCR TEXT:
${text}

Return JSON exactly:
{
  "cleanedText": "normalized readable version of OCR (preserve meaning, fix obvious OCR artifacts)",
  "tasks": [
    {
      "title": "task title (no leading time)",
      "description": "",
      "startTime": "HH:MM or empty string",
      "hours": 1,
      "lifeBlock": "general",
      "importance": 1,
      "emotion": ""
    }
  ]
}`;

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
      // Просим строгий JSON-объект
      text: { format: { type: "json_object" } },
    }),
  });

  if (!r.ok) {
    const err = await r.text();
    throw new Error(`OpenAI error: ${err}`);
  }

  const data = await r.json();
  const outputText =
    data?.output?.[0]?.content?.[0]?.text ??
    data?.output_text ??
    null;

  if (!outputText) throw new Error("Bad OpenAI response shape");
  return JSON.parse(outputText);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return jsonResponse({}, 200);

  try {
    if (!OPENAI_API_KEY) return errorResponse("Missing OPENAI_API_KEY", 500);

    const payload = await req.json().catch(() => ({}));
    const text = String(payload?.text ?? "").trim();
    const locale = String(payload?.locale ?? "ru").trim();

    if (!text) return jsonResponse({ cleanedText: "", tasks: [] }, 200);

    const result = await callOpenAI(text, locale);

    const cleanedText =
      typeof result?.cleanedText === "string" && result.cleanedText.trim().length > 0
        ? result.cleanedText
        : text;

    const tasksRaw = Array.isArray(result?.tasks) ? result.tasks : [];

    // Санитайз, чтобы Flutter не падал
    const tasks = tasksRaw
      .filter((t: any) => t && typeof t.title === "string")
      .map((t: any) => {
        const title = String(t.title ?? "").trim();
        return {
          title,
          description: String(t.description ?? ""),
          startTime: normalizeTime(t.startTime),
          hours: toHours(t.hours),
          lifeBlock: "general" as const,
          importance: toImportance(t.importance),
          emotion: "",
        };
      })
      .filter((t: any) => t.title.length > 0);

    return jsonResponse({ cleanedText, tasks }, 200);
  } catch (e) {
    return errorResponse("Unhandled error", 500, String(e));
  }
});
