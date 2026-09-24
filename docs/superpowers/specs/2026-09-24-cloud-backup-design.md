# Cloud backup (Phase 9, part 1) — design

_2026-09-24. Pay-index (Phase 9, part 2) is a separate, later design._

## Goal

A rider whose phone is lost, stolen or reset gets their evidence, letters and profile back by
signing in on the new phone. Opt-in; earnings stay on the phone unless the rider switches them
on (research.md's privacy stance).

## Decisions (agreed 2026-09-24)

| Question | Decision | Why |
|---|---|---|
| Sign-in | Google (native, `google_sign_in` → Supabase `signInWithIdToken`) | Free, no SMS/DLT paperwork, one tap on Android. Phone OTP can be added later. |
| Scope | Evidence + letters + profile always; orders & expenses + their screenshots behind an off-by-default switch | Earnings never leave the phone unless the rider chooses. |
| Protection | Server-side: private bucket, per-rider access rules, encrypted at rest (Mumbai) | Restore is just "sign in"; no PIN to forget. |
| Approach | Snapshot: `manifest.json` + content-addressed files | Riders have one phone; far less code than row-level sync. |

## Cloud layout

Bucket `backups` (private, 10 MB/object, image/pdf/json/octet-stream only):

```
backups/<auth uid>/manifest.json          rows + profile, rewritten each backup
backups/<auth uid>/files/<sha256>.<ext>   every referenced photo/screenshot/PDF
```

Storage policies (`supabase/migrations/20260923224519_backups_bucket.sql`) allow
select/insert/update/delete only where the first path segment is the caller's `auth.uid()`.
`delete-account` Edge Function (service role) removes the rider's folder, then their auth user.

## App pieces (`lib/services/backup/`)

- `backup_manifest.dart` — manifest model + strict parsing. The manifest comes from the
  network, so file refs are validated: dir ∈ {screenshots, letters}, safe basename, known
  extension, 64-hex SHA-256. Newer versions → `UnsupportedBackupVersion`.
- `backup_remote.dart` — `BackupRemote` interface + Supabase implementation (paged listing).
- `backup_service.dart` — stateless backup / peek / restore / deleteCloudCopy.
- `backup_controller.dart` — sign-in, settings (SharedPreferences), auto-backup (30 s after
  the last DB change; on app open), problem classification for the UI.
- `screens/backup_screen.dart` — More → Cloud backup.

## Behaviour and edge cases

- **Backup order:** upload missing files → upload manifest → delete files no longer
  referenced. A crash at any point leaves a consistent cloud copy (the old manifest's files
  are never deleted before the new manifest is up).
- **Incremental:** only files the cloud doesn't have are uploaded (content-addressed).
- **Linking (the key safety rule):** a phone auto-backs-up only once linked to the signed-in
  account. Sign-in with an empty cloud links at once; otherwise the rider must choose
  *Restore* or *Replace*. So an empty new phone can never overwrite the real backup.
- **Restore merges, never replaces:** dedupes evidence by hash, orders by screenshot hash (or
  by fields when there's none), letters and expenses by fields; idempotent, so an interrupted
  restore is simply re-run. Local profile fields win; empty ones are filled.
- **Restore carries the earnings switch over** from the backup — otherwise the new phone's
  first backup would drop the rider's orders & expenses from the cloud.
- **Every restored file is SHA-256-verified.** Tampered/missing files are skipped and counted;
  evidence/letters without their file are skipped, orders keep their pay data.
- **Never overwrites a different local file** with the same name — restores alongside.
- **Missing local files** at backup time are skipped, not fatal.
- **Real content type** is sniffed from bytes (screenshots are all saved as `.jpg`).
- **Turning backup off** stops sync at once; the rider chooses whether to delete the cloud copy.
- **Delete everything** deletes the cloud backup + account first; if offline, the rider can
  retry or delete from the phone only, which detaches the phone from the cloud first so the
  wipe can't be auto-backed-up over the kept copy.
- **Signing in with a different account** on a linked phone → unlinked → restore/replace choice.

## Testing

- `test/backup_service_test.dart` — 26 host tests over an in-memory fake remote: scope,
  incremental, dedup, GC, earnings on/off, missing files, network failure mid-backup and
  mid-restore, tampering, path traversal, newer versions, malformed JSON, name clashes,
  idempotent restore, merge rules.
- `integration_test/backup_e2e_test.dart` — 12 scenarios against the real Supabase project on
  an emulator, with two throwaway email accounts (Google sign-in can't be automated): first
  sign-in, earnings switch, auto-backup + GC, **rider B blocked from rider A's backup**
  (read/list/overwrite/delete/path tricks/no session), new-phone no-overwrite + byte-exact
  restore, repeat restore, replace, off/on/delete-cloud, network failure, Backup screen in 3
  languages × 2 text sizes, delete-account for both riders.

## Setup still needed for Google sign-in (one-time, by the project owner)

1. Google Cloud Console → APIs & Services → **OAuth consent screen**: External; app name
   AsliKamai; support email; scopes `openid`, `email`, `profile` only (non-sensitive, so no
   Google verification needed). Publish to production.
2. **Credentials → Create OAuth client ID → Web application** ("AsliKamai Supabase").
   Authorized redirect URI: `https://wwsggroioiptyhyrylnm.supabase.co/auth/v1/callback`.
   Keep the client ID and secret.
3. **Credentials → Create OAuth client ID → Android**, package `com.asalikamai.asli_kamai`,
   once per signing key:
   - debug key SHA-1 `80:DC:61:0A:2B:6C:79:34:16:7E:F2:E5:07:9C:D2:F2:7F:8B:3C:05`
   - upload key SHA-1: `keytool -list -v -keystore <upload keystore> -alias <alias>`
   - later, the Play App Signing key SHA-1 from Play Console → App integrity.
4. Supabase dashboard → Authentication → Sign In / Providers → **Google**: enable, paste the Web
   client ID + secret, and add the Android client ID(s) under *Client IDs*.
5. Add `GOOGLE_WEB_CLIENT_ID=<web client id>` to `.env` (a public value) and rebuild. Until
   then the Backup screen says backup isn't set up, and nothing else changes.
