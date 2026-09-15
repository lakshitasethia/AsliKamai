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
