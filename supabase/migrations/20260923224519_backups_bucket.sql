-- Private per-rider cloud backups (build_execution.md Phase 9).
-- Layout: backups/<auth uid>/manifest.json + backups/<auth uid>/files/<sha256>.<ext>
-- Each rider can only touch objects under their own uid folder.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'backups',
  'backups',
  false,
  10485760, -- 10 MB per object; screenshots are ~60-100 KB, letters < 1 MB
  array['application/json', 'application/pdf', 'image/png', 'image/jpeg', 'image/webp']
)
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- Upsert (manifest.json is rewritten every backup) needs INSERT + SELECT + UPDATE.
create policy "backups: owner can read"
on storage.objects for select
to authenticated
using (
  bucket_id = 'backups'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "backups: owner can upload"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'backups'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "backups: owner can overwrite"
on storage.objects for update
to authenticated
using (
  bucket_id = 'backups'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
)
with check (
  bucket_id = 'backups'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);

create policy "backups: owner can delete"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'backups'
  and (storage.foldername(name))[1] = (select auth.uid()::text)
);
