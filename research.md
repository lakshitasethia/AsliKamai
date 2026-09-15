# AsliKamai: Research

> **AsliKamai** (असली कमाई, "real earnings"): an app that belongs to the worker. It shows India's delivery and ride-hailing gig workers what they **actually** earn after costs and platform cuts. It also keeps a record of every pay change and ID block, so they have evidence when they need to fight one.

- **Date:** 14 Sep 2026
- **Status:** research done, validation not started. No code yet.

**How much to trust each figure** (the mark is next to it):
- ✅ I opened the source myself during the final check.
- ◐ A research agent opened the source; I did not re-open it.
- ⚠ Seen only in a news snippet or search result, or not verified. Check before quoting it publicly.

---

## 1. The decision

**Build AsliKamai.** I looked at 15 candidate ideas from 5 research areas: health, money and fraud, students and jobs, city life, and informal work. AsliKamai scored highest (§2) for five reasons:

1. **The pain is proven and measured.**
   - Workers are already checking their pay by hand: a union study read 1,500 worker screenshots and found the real platform cut is **41–45%, against 20% "on paper"** ✅.
   - About **40% of India's 1.2 crore gig workers earn under ₹15,000 a month** ✅.
2. **People would use it every day.** Riders work a shift daily, so the app fits into a daily routine and keeps its users.
3. **No one is doing this for India.**
   - Three Play Store searches found only the platforms' own partner apps, general expense trackers, and two small, generic "gig tracker" apps ✅.
   - The worker-side earnings apps that do exist (Solo, Gridwise) are US-only ◐.
4. **The law now gives workers something to point to.** Karnataka's Gig Workers Act says:
   - deductions on payment statements must be **"clearly explained"**;
   - an ID can only be blocked with **14 days' notice and written reasons**;
   - platforms must publish a way for workers to ask about their "fees, earnings and customer feedback" ✅.

   A grievance system for gig workers went live on **1 May 2026** ✅. Workers have rights on paper but no tool to collect evidence.
5. **The users can adopt it and the idea can spread.**
   - **95% of delivery workers owned a smartphone before joining a platform** ✅.
   - They wait together at dark stores (quick-commerce warehouses) and restaurant pickup points, organise through WhatsApp and unions, and went on a large strike on 25 Dec 2025 ◐.

**The honest downsides:**
- **Weak revenue.** This grows users and impact first, and money later (§3.9).
- **You have to do field work.** You are not a rider, so you have to interview riders before writing code (§3.7).

---

## 2. Shortlist scoring

**Weights:**
- 20% each: pain, how often people would use it, how open the competition is.
- 15% each: how easily it spreads, how buildable it is.
- 10%: market size.

**Where the scores come from:** the research agents' 1–10 scores, changed where my own checking disagreed with them. Changes are marked †.

| # | Idea | Pain | Freq | Open | Viral | Build | Market | **Score** |
|---|---|---|---|---|---|---|---|---|
| 1 | **AsliKamai**: earnings audit and deactivation evidence for gig workers | 8 | 9 | 8 | 8 | 7 | 7 | **7.95** |
| 2 | Hisaab Diary: wage record kept by daily-wage and construction workers | 9 | 7 | 7 | 5 | 8 | 8 | 7.35 |
| 3 | Utility Pulse: crowd-reported power and water outages (Bengaluru) | 7 | 5 | 8 | 9 | 8 | 7 | 7.25 |
| 4 | ParentPulse: medicine reminder calls to parents, dashboard for the adult child | 7 | 9 | 6 | 6 | 7 | 8 | 7.15 |
| 5 | Tracker for freshers waiting on IT joining dates | 8 | 5 | 8 | 8 | 8 | 5 | 7.10 |
| 6 | Proof-of-Fix: independent check that civic complaints were fixed | 8 | 4 | 7 | 8 | 8 | 7 | 6.90 |
| 7 | Decoder and complaint drafter for rejected health insurance claims | 9 | 3 | 7 | 7 | 8 | 7 | 6.75 |
| 8 | Ledger for household help (maid/cook pay, leave, advances) | 5 | 8 | 6 | 6 | 9 | 7 | 6.75 |
| 9 | Ayushman Bharat / Vay Vandana hospital navigator | 8 | 4 | 8 | 6 | 6 | 9 | 6.70 |
| 10 | Checker for fake job and internship offers | 8 | 4 | **4†** | 8 | 9 | 8 | 6.55 |
| 11 | Deposit protection and verified PG reviews | 8 | 3 | 7 | 6 | 8 | 8 | 6.50 |
| 12 | Scam second opinion with family loop | 9 | 5 | **3†** | 7 | 7 | 9 | 6.40 |
| 13 | Checker for fake trading apps and investment groups | 9 | 3 | 7 | 5 | 7 | 7 | 6.30 |
| 14 | Farmer sale slip, dues tracking and mandi price comparison | 7 | 4 | 4 | 5 | 7 | 9 | 5.70 |

**† Why I cut the competition score for the scam and job checkers.** The research agents said nobody offered an India-specific "paste a message and check it" tool. When I checked, that was **wrong**:
- **[Savdhaan](https://savdhaan.in/)** does it on the web, through a WhatsApp bot and through a developer API, and covers 12 scam types including fake jobs ✅.
- **[ScamDekho](https://scamdekho.in/)** is free, in Hindi, and checks screenshots, UPI/QR codes and **job offer letters** ✅.
- **[Scamy](https://www.scamy.in/)** has Play Store and App Store apps with a focus on India ✅.
- **Truecaller Family Protection** is free and live in India, although it covers **calls only** ✅.

None of these tools shows any user numbers. That suggests people don't go looking for a scam checker on their own.

---

## 3. AsliKamai in detail

### 3.1 Problem
A delivery rider can see money arriving but can't answer three questions:
- **What do I really earn** per hour and per km, after fuel, repairs, phone costs and fines?
- **Did my pay get cut this week,** and was chasing that incentive worth it?
- **Why was my ID blocked,** and where is my proof when I appeal?

The platforms hold all the data. The worker holds screenshots scattered across their gallery.

### 3.2 Who it is for
**The main user:** a male delivery rider aged about 28, full-time, in a metro city (Bengaluru first), working on one or two platforms and paying off a bike or phone loan.

| Fact | Value | Source |
|---|---|---|
| Average age / share of women | 28 years / under 1% | IDinsight, 2,547 riders ✅ |
| Migrants | 51% (24% within the state, 26% from other states) | IDR ✅ |
| Owned a smartphone before joining / has a bank account | **95% / 99%** | IDR ✅ |
| Also studying | 23% | IDinsight ✅ |
| Full-time riders: gross pay → net pay | ₹27,814 → **₹18,761 a month**; **32%** goes on costs; 62 hours a week | IDinsight ✅ |
| Net hourly earnings | about **₹75.3/hour**, against ₹62.3/hour for casual urban labour | IDR ✅ |
| Also work on other platforms | 14% | IDinsight ✅ |

**Secondary users:**
- **Cab and bike-taxi drivers:** phase 2.
- **Unions and researchers:** they use the pooled, anonymous pay data.

### 3.3 Scale
| Fact | Source |
|---|---|
| **1.2 crore gig workers (FY25)**, up 55% from 77 lakh in FY21; **about 40% earn under ₹15,000 a month** | Economic Survey 2025-26, reported by Moneycontrol, Deccan Herald and Business Line ✅ |
| Projected 2.35 crore by 2029-30 | NITI Aayog 2022 ◐ |
| E-commerce 37 lakh workers, logistics 15 lakh | Economic Survey coverage ✅ |

**Starting market:** about **2–3 lakh delivery workers in Bengaluru** (⚠ my estimate, not sourced; check against Karnataka board registration figures). The target is 1,000 weekly active workers within 90 days, which needs well under 1% of that market.

### 3.4 Evidence of pain (all quotes checked against the source)
- **Survey of 5,302 cab drivers and 5,028 delivery workers in 8 cities** (PAIGAM and IFAT, Apr 2025). Aakriti Bhatia, PAIGAM's research director: "Actual commission ranges from 41% to 45% … based on the analysis of 1,500 screenshots collated by workers. On paper, it's only 20%. In practice, it is much worse." ✅ [ETV Bharat](https://www.etvbharat.com/en/!bharat/gig-workers-digital-economy-food-delivery-apps-travel-car-riding-enn25041904505)
  → **Workers already audit their pay by hand. AsliKamai automates what they're doing.**
- **Saif, a Delhi rider** (May 2026):
  - "for the same delivery distance, we could get as low as ₹35. There is no logic or fixed calculation to this. It is a way to make a fool of us."
  - On incentives: "as you start working, the incentive amount will soon start decreasing."
  - "There is no redressal system for riders…"
  - ✅ [The Locavore](https://thelocavore.in/2026/05/24/a-gig-worker-on-unionising-for-basic-labour-rights/)
- **A researcher who worked as a rider** (Jul 2025):
  - First order: "Rs. 20 for 3.2 km delivery".
  - Rider Vishal's month: ₹14,000 gross, minus ₹7,920 in costs (fuel ₹5,100, phone EMI ₹1,200, and more), leaves **₹6,080 net**.
  - "Earning calculations remain deliberately opaque."
  - "Rejecting more than three orders during a shift triggers penalties."
  - ✅ [The India Forum](https://www.theindiaforum.in/tiffin/twenty-rupees-twenty-minutes-what-i-learned-working-indias-gig-economy)
- **25 Dec 2025 strike:** about 40,000 workers, led by IFAT, protested "arbitrary ID blocking" and opaque decisions by the algorithm that affect earnings ◐ [The Week](https://www.theweek.in/news/biz-tech/2025/12/25/why-are-gig-workers-going-on-strike-swiggy-zomato-blinkit-delivery-drivers-offer-details.html)
- **Fairwork India 2024:** no platform scored above 6/10 on fair labour standards ◐ [Fairwork](https://fair.work/en/fw/publications/fairwork-india-ratings-2024-labour-standards-in-the-platform-economy/)

### 3.5 Why now
| What changed | What it means for AsliKamai | Source |
|---|---|---|
| **Karnataka Gig Workers Act** (notified 12 Sep 2025) and **Rules** (19 Nov 2025): deductions "clearly explained", pay at least weekly, **14 days' notice with written reasons** before an ID is blocked, contract changes need 14 days' notice, an internal dispute committee with appeal to the Board, platforms must publish how workers can ask about fees and earnings | Gives exact clauses for the letters and appeals the app drafts | ✅ [Khaitan & Co](https://www.khaitanco.com/sites/default/files/2025-11/ERGO%20-%20Karnataka%20Gig%20workers%20-%2027%20Nov%202025.pdf) |
| **Grievance system for gig workers live since 1 May 2026** | There is now somewhere to send the evidence | ✅ The Hindu, 7 May 2026 (headline and summary) |
| **Swiggy, Eternal and Zepto challenged the Act in the Karnataka High Court** (29 Jun 2026) | Shows the Act matters; the legal risk to it is ongoing | ⚠ Mint / New Indian Express snippets |
| **The High Court ordered platforms to deposit the welfare fee** instead of pausing the law; platforms deposited on 23 Jul | Shows the law is being enforced | ⚠ Business Today snippet |
| **Uber, Eternal and Porter left the welfare board** (about Aug–Sep 2026) | Platforms won't cooperate, so workers need their own records | ⚠ MediaNama snippet |
| **National Code on Social Security** in force 21 Nov 2025; platforms had to register workers on e-Shram (the national database of informal workers) by 21 Jun 2026 | Formalisation is happening nationwide | ◐ [DLA Piper](https://knowledge.dlapiper.com/dlapiperknowledge/globalemploymentlatestdevelopments/2026/india-mandates-aggregator-onboarding-to-eshram-portal-to-expand-social-security-coverage) |
| **Telangana passed its gig worker Act in 2026**, the 5th state after Rajasthan, Karnataka, Jharkhand and Bihar | More states to expand into | ◐ [Vision IAS](https://visionias.in/current-affairs/news-today/2026-04-01/polity-and-governance/telangana-legislative-assembly-passed-the-telangana-platform-based-gig-workers-registration-social-security-and-welfare-bill-2026) |
| **Platforms dropped "10-minute delivery" deadlines after government pressure** (Jan 2026) | The government is already stepping in on platform practices | ✅ India TV / Moneycontrol / Financial Express (news search) |
| **Cheap AI that can read screenshots and cheap Indian-language speech recognition** | Can read partner-app screens without fixed templates that break when the app changes; riders can log costs by voice | ◐ [Sarvam pricing](https://docs.sarvam.ai/api-reference-docs/pricing) |

### 3.6 Competition and the gap
| Player | What it does | Why it doesn't solve this |
|---|---|---|
| Swiggy / Zomato / Zepto / Blinkit partner apps | Show that platform's own payouts | Show one platform only, no costs, no history you can export, and they are the other side of any dispute |
| General expense apps (Cash Book, Money Manager and others) | Manual ledgers | Know nothing about orders, per-km pay or incentives; no evidence features |
| "ShiftTracker: Gig Worker Pay", "Gig Worker Expense Tracker" | Small generic trackers | No sign of support for Indian platforms, Indian languages or Indian law ⚠ (listing details weren't visible) |
| Solo, Gridwise (US) | Multi-platform income and expense tracking | US-only (Uber, DoorDash) ◐ |
| FareShare (US research) | Calculates wages lost after a deactivation | A research tool; 178 sign-ups in its pilot ◐ [arXiv](https://arxiv.org/abs/2505.08904) |
| Unions (IFAT, TGPWU, AIGWU) and PAIGAM | Collect screenshots by hand and run surveys | No tools, and the work doesn't scale. **These are partners, not competitors.** |

**The gap:** no app for India that (a) turns partner-app screenshots into a per-order earnings record, (b) calculates real net ₹/hour and ₹/km after costs, (c) spots pay-rate cuts over time, and (d) keeps tamper-evident evidence for appeals under the new state laws.

### 3.7 Test these before writing code (weeks 0–2)
Each test has a pass mark. **If the first two fail, drop the idea and move to runner-up #2 or #3.**

| # | Test | Method | Pass if |
|---|---|---|---|
| 1 | Do partner apps show enough per-order data (pay, distance, incentive, time)? | Install or borrow Swiggy, Zomato, Blinkit and Zepto partner apps; collect **100 real screenshots from 10 riders** | At least 2 major platforms show per-order pay and distance on screen |
| 2 | Will riders share screenshots every week? | **20 in-person interviews** at 3 rider waiting points (e.g. Koramangala, HSR, Indiranagar dark stores / restaurant clusters) | At least 12 of 20 say they'd import screenshots weekly for a "real earnings" report |
| 3 | Can the app read the screenshots? | Run on-device text recognition plus a small AI model on the 100 screenshots | At least 90% of fields extracted correctly after one correction pass |
| 4 | Do riders share the result card? | Hand-make "Meri Asli Kamai" cards for 10 riders from their screenshots | At least 4 of 10 forward it to a WhatsApp group without being asked |
| 5 | Will a union help distribute it? | Contact IFAT / AIGWU / Karnataka union organisers | At least 1 union agrees to pilot with its members |

**What to ask in interviews:**
- "How much did you make last week after petrol?"
- "When did your per-order rate last change?"
- "Has your ID ever been blocked? What proof did you have?"
- "Where do you keep screenshots?"
- "Would you show your weekly real earnings to other riders?"

### 3.8 MVP (6–8 weeks, 1–2 developers)
**Stack:**
- **App:** Flutter, since you and your friend already use it, local-first on an SQLite database on the phone.
- **Backend:** Supabase, only for opt-in sync and pooled pay data.
- **Reading screenshots:** Google's on-device ML Kit text recognition first (it supports Latin and Devanagari). A small vision AI model turns that text into structured data and handles Kannada and Telugu screens.
- **Voice:** Sarvam or Bhashini speech-to-text.

**Build:**
1. **Weekly screenshot import:** pick all of this week's partner-app screenshots at once with Android's Photo Picker.
   - This avoids asking for full photo-library access.
   - Screenshots become order records: platform, time, base pay, incentive, tip, distance, duration.
   - The user checks a confirmation screen and corrects anything wrong.
2. **Costs by voice:** "petrol 300", "puncture 50", "challan 500", in Hindi, Kannada or English.
3. **Weekly dashboard:**
   - gross → costs → **net**;
   - **net ₹/hour and ₹/km**;
   - best and worst hours and areas;
   - "incentive worth it?", comparing extra orders against extra time and fuel.
4. **Rate-cut detector:** alerts when median ₹/km for similar orders drops by ≥10% week-on-week, and saves the before and after screenshots automatically.
5. **Evidence locker:** block or suspension notices, support ticket IDs, payout statements.
   - Each saved with a capture time and SHA-256 hash (a digital fingerprint that shows the file hasn't changed).
   - Export to a single PDF.
6. **Letter generator:** templates in Kannada, Hindi and English for:
   - asking for an explanation of deductions;
   - asking for written reasons for an ID block;
   - filing to the platform's dispute committee or the Karnataka grievance system.

   The clauses cited come from the Act. **Have a labour lawyer or union review the templates.**
7. **Share card:** "Meri asli kamai this week: ₹X/hour after petrol." Stays anonymous unless the rider chooses to show more.

**Don't build yet:**
- **Take-rate calculation.** Working out the platform's cut needs the customer's bill as well; that's phase 2.
- **Cab drivers.**
- **Anything that pulls data from the platforms' servers.**
- **Android AccessibilityService or screen recording.** Play Store policy restricts these.
- **Reading notifications.** Check the Play Store's sensitive-permission policy first.

**Data model (core):**
- `Order{platform, ts, base_pay, incentive, tip, distance_km, duration_min, zone, source_screenshot_hash}`
- `Expense{category, amount, ts, voice_note?}`
- `Shift{start, end}`
- `Evidence{type, file_hash, captured_at, notes}`
- `Letter{template_id, lang, generated_at}`

### 3.9 Growth and money
**Growth loop:**
1. A rider shares their weekly card in a rider WhatsApp group.
2. Riders waiting at the same dark store compare numbers.
3. They install the app.
4. More installs feed the **anonymous city pay index**: median ₹/order and ₹/km per platform per area. Areas only appear once they have data from at least 20 workers.

**Channels:**
- **Unions:** IFAT, AIGWU, TGPWU.
- **Dark-store waiting points:** go in person, the way the IDinsight and PAIGAM surveyors did.
- **Journalists and researchers:** the pay index gives them fresh data, and they cite it. PAIGAM's screenshot study got national coverage.

**Early targets:** 1,000 weekly active workers in Bengaluru within 90 days of launch. **Main metric:** workers who import at least one week of screenshots.

**Money** (most realistic first; **free for workers, always**):
1. **Grants and fellowships** for labour rights and digital public goods.
2. **Paid, consented, pooled data** for researchers, think tanks and welfare boards. Groups already pay for surveys of this size; PAIGAM and IDinsight each surveyed thousands of workers.
3. **Tax filing help** (ITR-4, simplified presumptive tax scheme), ₹99–199. ⚠ Small upside: according to [TaxBuddy](https://www.taxbuddy.com/blog/side-hustles-zomato-swiggy-partners), platforms generally don't deduct TDS (tax at source) below ₹30,000 a year, so there are few refunds to claim.
4. **Vetted referrals** for accident insurance and EV rentals. Only with full disclosure to users; trust is the product.

### 3.10 Risks
| Risk | How to handle it |
|---|---|
| A platform objects or retaliates against riders | Process only the user's own screenshots, never scrape platform servers, keep data on the phone by default, and keep app branding worker-first but non-confrontational |
| A partner-app redesign breaks screenshot reading | The AI model reads structure rather than fixed positions; a correction screen lets riders fix errors, and corrections become training examples |
| Workers don't trust a student's app | Launch with a union, publish the privacy design, no ads, give riders an "export everything / delete everything" option |
| The pay index is attacked as misleading | Publish only medians with at least 20 workers per area and show the methodology openly |
| Letters are treated as legal advice | Frame them as information requests; lawyer-reviewed templates; clear disclaimer |
| Data protection law (DPDP Act): Rules notified 13 Nov 2025, consent requirements apply from 13 May 2027 ◐ | Build consent screens and data minimisation from day 1 |
| The Karnataka Act is weakened in the High Court | The earnings audit still has value without the Act; only the letters depend on it; other states (Telangana, Rajasthan) and the national Code still apply |
| You are not a rider | Tests 2 and 5 in §3.7 are required. Hire 1–2 riders as paid advisers (a few thousand ₹ a month) |

### 3.11 Roadmap
- **Phase 1 (weeks 0–10):** tests, then MVP, then a Bengaluru pilot with one union.
- **Phase 2:**
  - take-rate estimates: customers who choose to can upload their bill, matched to a rider's payout;
  - cab and bike-taxi drivers;
  - Hyderabad (Telangana Act).
- **Phase 3:** extend the same "worker-owned record" core to **daily-wage and construction workers** (runner-up #2).

---

## 4. Runner-ups worth keeping
**Hisaab Diary (7.35): a wage record kept by daily-wage workers themselves.**
- **Scale:**
  - 7.1 crore construction workers ◐;
  - India Labourline: 3,600+ cases worth ₹8 crore in 9 months, with ₹2.1 crore recovered ◐;
  - a CAG audit (Madhya Pradesh) found **1 of 223** site workers registered with the welfare board ◐.
- **Pain:** a mason said "That person owes me Rs 8,000. I do not have his number" ◐.
- **Competition:** existing apps (HajriBook, PagarBook) keep the *contractor's* records.
- **Why not #1:** smartphone ownership in this group is unmeasured, and distribution depends on NGOs.
- **Best as AsliKamai phase 3.**

**Utility Pulse (7.25): live power and water outage status in Bengaluru.**
- **Evidence:** Bengaluru residents reported 9–10-hour outages and got vague BESCOM (the city's electricity utility) replies (Apr–May 2026) ◐. Tanker water went from ₹1,200 to ₹3,000 in the 2024 crisis ⚠.
- **Why it's attractive:** the strongest built-in sharing of any idea, because an outage hits a whole neighbourhood at once.
- **Why not #1:** usage is seasonal, and it needs many users in one area before it's useful.

**ParentPulse (7.15): medicine reminder calls to parents, a dashboard for the adult child.**
- **Why parents need calls, not an app:** only 41% of elders own a smartphone and 5% use online services such as health apps ◐.
- **Scale:** 32.1% of people over 60 have two or more chronic diseases ◐.
- **People already pay for elder care:** Emoha's revenue went from ₹9.3 crore to ₹68 crore ⚠.
- **Why not #1:** each call costs money, so there can be no free tier, and it overlaps with funded players (August AI, Emoha).

**Fresher joining tracker (7.10).**
- **Evidence:** 10,000+ freshers were waiting on joining dates from Wipro, Infosys, TCS and others (2024) ◐; Wipro still had 250+ waiting in 2026 ◐.
- **Why not #1:** a small, cyclical market.

---

## 5. Rejected ideas
| Idea | Why |
|---|---|
| Scam checker (general, job-offer, or elderly-focused) | Savdhaan, ScamDekho and Scamy already offer it; Truecaller Family Protection covers calls ✅ |
| Checker for fake trading apps and investment groups | High value (investment fraud was 76% of the ₹22,495 crore lost to cybercrime in 2025 ✅) but used once in a while; SEBI Check already verifies UPI IDs and bank accounts ◐. Best as a feature, not a product |
| Decoder for rejected health insurance claims | Real pain (₹26,000 crore in claims disallowed or repudiated in FY24 ◐) but people need it rarely, and it's close to legal advice. Worth a web tool that grows through search, not a mobile app |
| Proof-of-Fix for civic complaints | Can't force anything to get fixed, so users leave; no revenue |
| Ayushman hospital navigator | Hard to build up enough crowd reports, and a defamation risk from "hospital refused" reports; no revenue |
| Deposit and PG review app | Deposit disputes happen roughly every 1–2 years; the Karnataka deposit cap is unconfirmed ⚠ |
| Household help ledger | Pain not measured; MaidCircle already exists |
| Farmer sale slip and price comparison | Price apps are a crowded commodity (Agmarknet, DeHaat, many "mandi bhav" clones); seasonal |
| Khata or bookkeeping in voice | Khatabook, OkCredit and Vyapar dominate |
| Crop disease detection | Plantix has a data advantage a new app can't match ◐ |
| AI lab report explainer | August AI, PharmEasy, Eka Care and others already do it ◐ |
| Student mental health app | Tele-MANAS is free and in 20 languages ◐; high responsibility in a crisis |
| Subscription / autopay tracker | NPCI now requires UPI apps to show autopay mandates ◐ |
| Consumer complaint drafter | Used rarely; many AI drafters already exist |
| Loan-app harassment helper | Too close to crisis response, and RBI's Sachet portal exists |
| Food adulteration checker | A phone can't test food; defamation risk |
| Transit or AQI app | Where Is My Train, Chalo and Google Maps already cover it |
| Placement prep, flat marketplace | Unstop, Internshala, NoBroker already cover it |
| Welfare scheme discovery | **You already have Haqdaar** |
| SOS / crisis response | **Your friend's Sahay** |

---

## 6. Errors found and fixed during checking
- **"No Indian scam-checker exists"**: false. Savdhaan, ScamDekho and Scamy exist ✅.
- **LocalCircles UPI survey, "20% shared their OTP"**: not in the source. The source says **50% said their UPI PIN was hacked** and 40% clicked a payment link; 51% of victims never complained (32,000+ responses, Mar–Jun 2025) ✅.
- **IDinsight "riders average 1.69 income sources"**: not in either article. The source says **14% also work on other platforms** ✅.
- **Indeed survey, "46% of Gen Z lost money"**: the article lists 46% for both "lost trust" and "lost money", so it's ambiguous. Not used. Safe figures: 93% saw suspicious job offers, 51% can't tell real recruiters from scammers, 75% ignore postings for fear of fraud ✅.
- **Tax-refund filing as the main revenue**: weakened, since platforms generally don't deduct TDS below ₹30,000 a year.
- **Karnataka implementation status**: in Nov 2025 no Board or portal existed (Khaitan) ✅. By May 2026 the grievance system was live ✅. Fixed so the document doesn't describe the old status.
- **An agent's figure "12% of urban households face water disruptions"**: LocalCircles actually says 12% have *no piped water connection* (the research agent caught this).

## 7. How this was researched, and the limits
- **Research:** 5 agents searched in parallel (health, fintech and fraud, students and jobs, civic life, informal work). Each proposed 3 ideas with evidence, rejected others, and scored them.
- **Checking:** I re-opened the sources behind the top pick and behind every claim that the competition was open.
- **Reddit and Play Store reviews couldn't be fetched automatically.** Worker quotes come from news and field reports instead. **Before building, read r/india, r/bangalore and r/developersIndia threads about delivery partner pay, and the 1-star reviews on Swiggy's and Zomato's partner apps.**
- **The web-search budget ran out during final checking.** Items that are only ⚠ should be checked by hand before any pitch.

## 8. Key sources
- Economic Survey 2025-26 gig figures: [Moneycontrol](https://www.moneycontrol.com/), [Deccan Herald](https://www.deccanherald.com/), [Business Line](https://www.thehindubusinessline.com/) (news coverage, Jan 2026)
- IDinsight delivery workforce study: https://www.idinsight.org/article/the-changing-landscape-of-work-insights-into-indias-delivery-platform-gig-workforce/
- IDR, "What the data reveals about India's gig workers": https://idronline.org/article/livelihoods/what-the-data-reveals-about-indias-gig-workers/
- PAIGAM/IFAT survey (ETV Bharat): https://www.etvbharat.com/en/!bharat/gig-workers-digital-economy-food-delivery-apps-travel-car-riding-enn25041904505
- Karnataka Act and Rules (Khaitan & Co): https://www.khaitanco.com/sites/default/files/2025-11/ERGO%20-%20Karnataka%20Gig%20workers%20-%2027%20Nov%202025.pdf
- The India Forum rider account: https://www.theindiaforum.in/tiffin/twenty-rupees-twenty-minutes-what-i-learned-working-indias-gig-economy
- The Locavore rider interview: https://thelocavore.in/2026/05/24/a-gig-worker-on-unionising-for-basic-labour-rights/
- Gig worker strike, 25 Dec 2025 (The Week): https://www.theweek.in/news/biz-tech/2025/12/25/why-are-gig-workers-going-on-strike-swiggy-zomato-blinkit-delivery-drivers-offer-details.html
- Fairwork India 2024: https://fair.work/en/fw/publications/fairwork-india-ratings-2024-labour-standards-in-the-platform-economy/
- FareShare (US deactivation wage calculator): https://arxiv.org/abs/2505.08904
- MHA cybercrime 2025 figures (ThePrint): https://theprint.in/india/cybercrime-saw-24-spike-in-2025-indians-lost-rs-22495-crore-mainly-in-investment-scams/2859930/
- LocalCircles UPI fraud survey: https://www.localcircles.com/a/press/page/upi-fraud-complaint
- Truecaller Family Protection (TechCrunch): https://techcrunch.com/2026/03/12/truecallers-now-lets-you-hang-up-on-scammers-on-behalf-of-your-family/
- Google scam protection in India (TechCrunch): https://techcrunch.com/2025/11/20/google-steps-up-ai-scam-protection-in-india-but-gaps-remain
- Indeed job-scam survey (Business Today): https://www.businesstoday.in/jobs/story/more-than-9-in-10-job-seekers-encounter-fake-job-offers-542006-2026-07-09
- Existing scam checkers: https://savdhaan.in/ · https://scamdekho.in/ · https://www.scamy.in/
