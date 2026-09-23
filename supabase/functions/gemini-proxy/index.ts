// Forwards the app's screenshot-reading requests to Gemini so the Gemini
// API key lives only in this function's secrets, never inside the APK.
//
// POST /functions/v1/gemini-proxy?model=<model>
// Body: a Gemini generateContent request, passed through unchanged.
// Auth: the app's publishable key in the `apikey` header. Deployed with
// verify_jwt = false (the platform check only understands legacy JWT keys),
// so the key is checked here instead.
// Response: Gemini's status code and body, passed through unchanged, so the
// app's model-fallback logic (429 / 404 / 5xx → next model) still works.

// Same chain as GeminiVisionService.models; anything else is refused so the
// key can't be spent on arbitrary (or pricier) models.
const ALLOWED_MODELS = new Set([
  "gemini-3.6-flash",
  "gemini-3.5-flash-lite",
  "gemini-3.1-flash-lite",
]);

// A phone screenshot is a few MB at most; base64 adds a third.
const MAX_BODY_BYTES = 12 * 1024 * 1024;

const json = (status: number, message: string) =>
  new Response(JSON.stringify({ error: message }), {
    status,
    headers: { "Content-Type": "application/json" },
  });

const publishableKeys = new Set(
  Object.values(
    JSON.parse(Deno.env.get("SUPABASE_PUBLISHABLE_KEYS") ?? "{}") as Record<string, string>,
  ),
);

Deno.serve(async (req) => {
  if (req.method !== "POST") return json(405, "POST only");
  if (!publishableKeys.has(req.headers.get("apikey") ?? "")) {
    return json(401, "Missing or unknown apikey");
  }

  const model = new URL(req.url).searchParams.get("model") ?? "";
  if (!ALLOWED_MODELS.has(model)) return json(400, `Model not allowed: ${model}`);

  const length = Number(req.headers.get("content-length") ?? "0");
  if (length > MAX_BODY_BYTES) return json(413, "Request too large");

  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) return json(500, "GEMINI_API_KEY secret is not set");

  const body = await req.text();
  if (body.length > MAX_BODY_BYTES) return json(413, "Request too large");

  const upstream = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json", "x-goog-api-key": apiKey },
      body,
    },
  );

  return new Response(await upstream.text(), {
    status: upstream.status,
    headers: { "Content-Type": "application/json" },
  });
});
