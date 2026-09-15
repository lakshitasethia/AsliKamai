# AsliKamai: Build Execution Plan

> Companion to `research.md`. This is the phase-by-phase build plan for the Android MVP.
> Each phase ends with a **testing checkpoint** before the next phase starts. Every phase's
> code is committed and pushed to `https://github.com/lakshitasethia/AsliKamai.git` once its
> testing checkpoint passes.

## Decisions locked for this build (2026-09-15)

| Decision | Choice | Why |
|---|---|---|
| Framework | Flutter | Single codebase, best fit for a first-time mobile builder, matches research.md |
| Platform | Android only (MVP) | Target users (delivery riders) are overwhelmingly Android; iOS is phase 2+ |
| Local data | SQLite via `drift` | Local-first, offline-first, no backend needed until Phase 9 |
| Screenshot parsing | Gemini 3.5 Flash-Lite (vision API) | Reads screenshots accurately; switched from the full Flash model in Phase 2 after hitting its free tier's 20-requests/day cap — Flash-Lite's free quota is far higher |
| Voice cost entry | Android native speech-to-text | Free, no key, no account, works immediately |
| Backend | Supabase, deferred to Phase 9 | Local-first first; sync/pay-index are additive, not required for MVP value |
| Design system | Exact match to provided mockup | User requirement: pixel-fidelity, no overflow/hidden content on any screen size |

**Design tokens** (from the mockup, used everywhere from Phase 1 onward):
- Primary green `#10684F` (earnings, CTAs)
- Warm yellow `#F6C945` (incentives/highlights)
- Cream background `#FFF8EC`
- Charcoal `#1F2937` (text/headers)
- Muted grey `#6B7280` (secondary text)
- Red alert `#EF4444` (warnings/rate-cut alerts)
- Headings: Inter/Poppins Bold. Body: Inter/Noto Sans Regular. Numbers: Inter Bold, large.
- Large tap targets, high contrast, minimal text, warm non-corporate look (not SaaS-dashboard-like).

**Responsiveness rule (every phase):** test on a small phone (~5.0", e.g. Pixel 4a) and a large
phone (~6.7", e.g. Pixel 8 Pro) emulator profile. Nothing may overflow, clip, or be hidden behind
system bars/nav. Use `SafeArea`, scrollable layouts, and relative sizing — never fixed pixel
widths that assume one screen size.

---

## Phase 0 — Environment & Scaffold

**Goal:** a blank Flutter app running on an Android emulator, project pushed to GitHub.

- Install Flutter SDK (via Homebrew) and Android command-line SDK tools + platform + build-tools.
- Accept Android SDK licenses, create one Android emulator (Pixel 8 Pro profile).
- Run `flutter create` for the `asli_kamai` app, Android-only config.
- Set up `.gitignore` for Flutter/Android/Dart build artifacts.
- Initialize git, connect to `https://github.com/lakshitasethia/AsliKamai.git`, first commit.
- Verify `flutter doctor` is clean for Android.

**Testing checkpoint:** default Flutter counter app builds and runs on the emulator without
errors. Screenshot confirms the app boots. User does not need to test anything yet.

---

## Phase 1 — Design system + navigation shell

**Goal:** the app's visual skeleton exists and matches the mockup's look on any screen size.

- `lib/theme/` : color tokens, text styles, spacing constants, `ThemeData`.
- Bottom navigation bar: Home, Import, Costs, Evidence, More (matches mockup icons/labels).
- Route/page shells for all 5 tabs, each with a proper **empty state** (icon + message + primary
  action) matching the mockup's empty-state pattern.
- App bar per screen: title, back button where needed, status/settings icon on Home.
- Reusable widgets: primary button, card container, section header, empty-state widget,
  error-state widget (all screens in the mockup define these three states consistently).

**Testing checkpoint:** navigate every tab on both emulator sizes. No overflow warnings in
debug console (Flutter prints red/yellow overflow banners — checked explicitly). Empty states
render correctly. APK sideload walkthrough #1 happens here so you can hold the real shell.

---

## Phase 2 — Screenshot Import + OCR review

**Goal:** Screens 1 & 2 from the mockup — import this week's screenshots, review/correct, save.

- Android Photo Picker integration (`image_picker` / `photo_manager` with the modern picker,
  not full storage permission).
- `drift` schema: `Order` table (platform, ts, base_pay, incentive, tip, distance_km,
  duration_min, zone, source_screenshot_hash).
- Gemini vision call: send each screenshot, get back structured JSON per the `Order` fields.
  Screenshot bytes are not persisted server-side beyond the parse call.
- Review screen: per-order card (platform icon, distance, time, pay, checkmark), tap to edit
  any field, "Confirm & Save (N orders)" button.
- Last-import summary shown on the Import tab home.
- Error state: "Couldn't read screenshots — try again or pick clearer images."

**Setup needed from you:** a free Gemini API key from Google AI Studio (I'll walk you through
this when we reach this phase).

**Testing checkpoint:** import a handful of real Swiggy/Zomato/Blinkit/Zepto screenshots,
verify extracted fields are correct or easily correctable, confirm saved orders appear in the
local database.

---

## Phase 3 — Weekly Dashboard

**Goal:** Screen 3 — the "3-second glance" home screen.

- Weekly aggregation: gross, costs, net; net ₹/hour, net ₹/km.
- Best hour / worst hour, best/worst zones (grouped from `Order.zone`).
- Incentive worth-it comparison (with-incentive vs without-incentive net).
- Week navigation (prev/next arrows), date range header.
- Offline indicator dot in the app bar.

**Testing checkpoint:** with Phase 2's imported test data, manually verify every number on the
dashboard against a hand calculation. Confirm layout holds with 1 order and with 50+ orders.

---

## Phase 4 — Voice Cost Entry + Costs tab

**Goal:** Screen 4 — tap-to-speak expense logging.

- `speech_to_text` package wired to the mic button with listening animation + waveform/pulse.
- Simple phrase parser: `"<category word> <amount>"` → `Expense{category, amount, ts}`
  (e.g. "petrol 300", "puncture 50"), with a manual text-entry fallback if parsing fails.
- Recent expenses chip list.
- Costs tab: full expense history, add/edit/delete.
- Expenses flow into the Dashboard's cost total from Phase 3.

**Testing checkpoint:** speak 5–10 real expense phrases, confirm correct parsing or graceful
fallback to manual entry; confirm dashboard net updates accordingly.

---

## Phase 5 — Rate-Cut Alert

**Goal:** Screen 3's alert card — detect and evidence a pay-rate drop.

- On each import, compute median ₹/km for the current week vs. the prior week, per platform.
- If drop ≥ 10%, generate an alert: before/after comparison, evidence list (last 5 orders used
  in the comparison), local push notification.
- Alert card UI (red, dismissible), "View Full Details" screen matching the mockup.
- Empty/good state: green checkmark, "All good! No rate cut detected this week."

**Testing checkpoint:** seed test data with a deliberate rate drop, confirm the alert fires with
correct evidence; seed clean data, confirm the "all good" state shows instead.

---

## Phase 6 — Evidence Locker

**Goal:** Screen 5 — tamper-evident document storage.

- Add documents (photos) from gallery, stored locally with SHA-256 hash + captured-at timestamp.
- Categories: Notices, Tickets, Payouts (tabs matching the mockup), "All" view.
- Document detail: view/download, hash shown as proof of integrity.
- Export selected/all evidence to a single PDF.

**Testing checkpoint:** add a document, confirm hash + timestamp are recorded and stable across
app restarts (i.e., the file hasn't silently changed); export and open the PDF.

---

## Phase 7 — Letter Generator

**Goal:** Screen 6 — templated letters citing Karnataka Gig Workers Act clauses.

- Templates (EN/HI/KN) for: deduction explanation request, ID-block written-reasons request,
  Karnataka grievance system filing.
- Auto-fill from user profile + relevant Order/Evidence data, preview before generating.
- PDF generation with a clear **"This is not legal advice"** disclaimer on every letter.
- `TODO` marker in-code and in this doc: templates need a lawyer/union review before public
  launch (per research.md §3.8) — not a build blocker, but must happen before real users rely
  on these letters in a dispute.

**Testing checkpoint:** generate each of the 3 templates in all 3 languages, confirm auto-fill
correctness and that the PDF renders legibly.

---

## Phase 8 — Share Card + full polish pass

**Goal:** Screen 7, plus an app-wide responsive/consistency pass.

- "Meri Asli Kamai" share card: rider-facing stat image (₹/hour, total net, distance), WhatsApp
  share intent.
- Language toggle (EN/HI/KN) applied app-wide, not just letters.
- Full pass over every screen from Phases 1–7 on both emulator sizes: no overflow, no clipped
  text, no hidden buttons, consistent spacing/typography per the design system.
- Settings/profile: name, platform(s), data export/delete-everything option (per research.md's
  trust requirements).

**Testing checkpoint:** full end-to-end walkthrough on your real Android phone, screen by
screen, both portrait orientations of your phone's actual size — this is the "does it really
work for me" pass.

---

## Phase 9 — Backend (Supabase), deferred

**Goal:** optional cloud backup and the anonymous pooled pay-index.

- Supabase project setup (you create the free account; I wire up the client).
- Opt-in sync of Evidence + settings (never Orders/Expenses by default, per the privacy stance
  in research.md — sync scope is a decision point when we reach this phase).
- Anonymous city pay-index: median ₹/order, ₹/km per platform per area, only shown once an area
  has ≥20 contributing workers (per research.md §3.9).
- Data export / delete-everything, honored against Supabase too.

**Testing checkpoint:** sync round-trip on two devices (or reinstall + restore), confirm
opt-out truly stops sync, confirm delete-everything removes cloud data too.

---

## Phase 10 — Release prep

**Goal:** a signed, installable release build, ready for real riders.

- App icon, splash screen, final app name/branding check.
- Privacy policy page (required for Play Store, especially given sensitive gallery access).
- Play Console account ($25 one-time, you'll need to create this), app signing, release build.
- Internal testing track first (not public) — a private way to get it on a handful of real
  riders' phones before any public listing.

**Testing checkpoint:** install the signed release build (not debug) on your phone via the
internal testing track, confirm it behaves identically to the debug builds you tested throughout.

---

## How you'll test on your phone (every phase, explained once)

Two options, either works:
1. **Emulator (I drive it):** I run the app on an Android emulator myself and describe/screenshot
   the result for you.
2. **Your real phone (you drive it):** I build a debug APK; you enable "Install unknown apps"
   for Files (one-time setting), I hand you the APK file, you tap it to install, then use the
   app normally. I'll give exact tap-by-tap steps when we get there — no prior Android knowledge
   assumed.

We'll use the emulator for my own verification every phase, and your real phone at key
checkpoints (end of Phase 1, Phase 4, Phase 8, and the Phase 10 release build) so you're actually
using the thing we're building.
