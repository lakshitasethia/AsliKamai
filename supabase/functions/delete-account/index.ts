// "Delete everything", honoured in the cloud: removes the calling rider's
// backup files and then their auth account. Riders can delete their own
// files with the publishable key, but deleting an auth user needs the
// service role, so that part has to happen here.
//
// POST /functions/v1/delete-account
// Auth: the rider's session JWT in `Authorization: Bearer <jwt>`. Deployed
// with verify_jwt = false (the platform check only understands legacy JWT
// keys); the token is verified here with auth.getUser instead.
// Response: 200 {"deletedFiles": n} | 401 | 500 {"error": ...}

import { createClient } from "npm:@supabase/supabase-js@2.57.4";

const BUCKET = "backups";

const json = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  Object.values(
    JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS") ?? "{}") as Record<string, string>,
  )[0];

const admin = createClient(Deno.env.get("SUPABASE_URL")!, serviceKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

// Every object path under `prefix`, walking sub-folders (list() returns
// folders as entries with a null id) and paging past the 1000-item cap.
async function listAll(prefix: string): Promise<string[]> {
  const paths: string[] = [];
  const pageSize = 1000;
  for (let offset = 0;; offset += pageSize) {
    const { data, error } = await admin.storage.from(BUCKET).list(prefix, {
      limit: pageSize,
      offset,
    });
    if (error) throw error;
    for (const entry of data) {
      const path = `${prefix}/${entry.name}`;
      if (entry.id === null) paths.push(...await listAll(path));
      else paths.push(path);
    }
    if (data.length < pageSize) return paths;
  }
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json(405, { error: "POST only" });

  const token = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
  if (!token) return json(401, { error: "Missing session token" });
  const { data: userData, error: userError } = await admin.auth.getUser(token);
  if (userError || !userData.user) return json(401, { error: "Invalid session" });
  const uid = userData.user.id;

  try {
    const paths = await listAll(uid);
    for (let i = 0; i < paths.length; i += 1000) {
      const { error } = await admin.storage.from(BUCKET).remove(paths.slice(i, i + 1000));
      if (error) throw error;
    }
    const { error: deleteError } = await admin.auth.admin.deleteUser(uid);
    if (deleteError) throw deleteError;
    return json(200, { deletedFiles: paths.length });
  } catch (e) {
    console.error("delete-account failed", uid, e);
    return json(500, { error: e instanceof Error ? e.message : String(e) });
  }
});
