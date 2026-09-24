# AsliKamai (असली कमाई)

An app that shows India's delivery and ride-hailing gig workers what they **actually** earn
after costs and platform cuts, and keeps tamper-evident evidence of pay changes and ID blocks
for when they need to fight one.

- **Research:** [`research.md`](research.md) — why this app, who it's for, the evidence base.
- **Build plan:** [`build_execution.md`](build_execution.md) — phase-by-phase build plan with
  testing checkpoints.

## Stack

- Flutter (Android-only MVP)
- Local-first: SQLite via `drift`, no account required to use the app
- Gemini 2.5 Flash for screenshot → structured order data parsing
- Android native speech-to-text for voice cost entry

## Running locally

```
flutter pub get
flutter run
```

See `build_execution.md` for the full phase plan and how each phase is tested.

## Testing

```
flutter analyze
flutter test                                   # unit + widget tests (host)

# On a connected Android phone (`flutter devices` for the id):
flutter test integration_test/screen_walkthrough_test.dart -d <id> --no-uninstall
flutter test integration_test/ocr_proxy_test.dart -d <id> --no-uninstall
flutter test integration_test/backup_e2e_test.dart -d emulator-5554 --no-uninstall --dart-define=E2E_PASSWORD=...
```

- `screen_walkthrough_test` opens every screen in English, Hindi and Kannada,
  at normal and 1.3× text size, and fails on any render error (overflows etc).
  It uses an in-memory database, so the data already on the phone is untouched —
  but keep `--no-uninstall`: without it `flutter test` uninstalls the app
  afterwards, deleting everything saved in it.
- `ocr_proxy_test` sends two synthetic screenshots through the live
  `gemini-proxy` Edge Function (2 Gemini calls per run).
- `backup_e2e_test` runs cloud backup end to end against the real Supabase
  project (sign-in, restore, access rules, delete-account). Emulator only — it
  wipes the app's local data — and needs two throwaway email accounts; see the
  file's header and `docs/superpowers/specs/2026-09-24-cloud-backup-design.md`.
