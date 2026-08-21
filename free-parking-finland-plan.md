# Free Parking Finder — Finland (Project Plan v1)

## The idea in one paragraph
A community app where anyone can photograph a parking sign; AI reads and interprets the rules; the spot appears on a shared map as free parking, tagged with how long the report should be trusted before it needs re-confirming. Users tap a pin to see the rules, then get handed off to Google Maps for turn-by-turn directions.

---

## Core user flows

### Reporting a spot
1. User taps "Add spot" and photographs the parking sign (camera opens in-app).
2. App captures the user's current GPS location at the same time.
3. Photo is sent to the AI, which reads the sign and returns a structured schedule (which days, which hours it's free) plus a plain-language summary written directly in the viewer's chosen app language — e.g. *"Free parking, max 2 hours, Mon–Fri 8–18, residents exempt"* becomes something the app's clock can check automatically, and reads naturally whether the app is set to English, Finnish, or Swedish.
4. The app shows this interpretation back to the user, who can confirm it as-is or edit any part of it (hours, days, exceptions) before submitting.
5. Once confirmed, **the photo is deleted** — only the location, the interpreted rules, and a timestamp are kept.
6. The spot appears on the map, color-coded **green** (reported free) or **red** (reported full) based on the latest user input. After **30 minutes** with no new confirmation, the live status fades back to "unconfirmed" — but the location itself is saved permanently as a known free-parking place; only the live status resets, not the whole entry.

### Two kinds of "free"
- **Rule-based** (straight from the sign): e.g. "free after 18:00 weekdays, all day Sunday." The app checks this against the phone's clock automatically — no permission needed, nobody has to report anything, it just applies whenever that window is active.
- **Crowd-confirmed** (from people nearby): green/red, live, expires after 30 minutes. This is what tells you whether a rule-based-free spot is actually *occupied* right now despite being free-by-rule.
- Both show together: a spot can be free-by-rule and still show red if someone just reported it full.

### Finding a spot
1. On first launch, the app asks for GPS permission (required to use the app), then opens to a map view with a toggle to switch to a list view and back — whichever the user prefers.
2. The map shows nearby free spots as pins: **green** (free right now, by rule or crowd-confirmation), **red** (reported full), **grey** (outside its free hours, or unconfirmed). The list view shows the same spots as a sorted list instead of pins.
3. A list view shows the same spots sorted nearest-to-furthest, within a 1km radius of either your current location or a pin you drop somewhere else (e.g. near a friend's address).
4. Tapping a pin or list entry shows the rules and how old the report is.
5. Tapping "Navigate" gives a quick choice of Google Maps or Apple Maps, whichever's installed, for turn-by-turn directions.

### Accounts & ads
- **Guests**: full-screen ad on launch, again after every 5 taps, and every time the app is opened — with a prompt to register to remove it.
- **Registered users**: only banner ads (top/bottom strip), plus an occasional full-screen ad (roughly weekly to monthly, tuned to ad revenue).

### Keeping data fresh
- If a spot you're navigating to gets reported "full" by someone else before you arrive, you get a notification.
- When your GPS shows you've arrived at a known spot, the app asks "Is this space free or full?" — keeps the data accurate for the next driver.
- The list/map updates through the day on its own — a spot that's only free after 18:00 or on Sundays simply won't show as free outside those hours, no report needed.
- A "Report" button on every spot lets people flag one that's marked free but isn't — with the option to attach a photo as evidence.

### Privacy
- Faces/plates are auto-blurred during processing — before the photo is discarded anyway.
- Submission photos are deleted immediately after the AI reads them. Report/dispute photos (the evidence photos above) are the exception — kept briefly for review, then removed too.

### Language
- App interface (menus, buttons, onboarding, privacy policy) in **English, Finnish, and Swedish** at launch — Russian to follow shortly after, since it's just another translation file, not new engineering work.
- The AI already has to read Finnish/Swedish signage regardless; it now also writes the plain-language rule summary directly in whichever language the viewing user has selected — cheap, since it's a small amount of extra text per report.
- Since a mistranslated parking rule could genuinely cost someone a fine, each language's rule-summary wording is worth a check by a fluent speaker before wide release — app-menu wording matters less if it's slightly off.

---

## The technical build (this part's on me to guide you through)

| Piece | Choice | Why |
|---|---|---|
| App framework | **Flutter** | One codebase for iOS + Android — your call, and a good one |
| Backend/database | **Firebase** (Firestore + Auth + Cloud Functions) | Generous free tier, built for exactly this kind of realtime mobile app, huge amount of beginner-friendly documentation |
| AI photo reading | **Google Gemini**, called directly from the app via **Firebase AI Logic** (no backend server to build or deploy) | Cheaper than Claude for this image-heavy workload, strong at reading signage, works in Finnish/Swedish. Firebase AI Logic protects the API key via Firebase App Check instead of a server-side proxy, so it's safe to call directly from the app -- and it runs free on the Spark plan (no billing/payment method needed) until usage outgrows the free tier |
| In-app map | **OpenStreetMap** (via a free Flutter map package) | Free with no usage billing — fits "keep costs low," and fits the community-data spirit of the app |
| App language support | Flutter's built-in localization (`intl` + ARB translation files) | Standard, well-supported, free — English/Finnish/Swedish at launch, Russian is just one more file later |
| Navigation handoff | A quick choice between Google Maps and Apple Maps, whichever's installed | Free — just deep links, no paid API needed |
| Ads | **Google AdMob** | Standard, free to integrate, supports both banner and full-screen formats |
| Push notifications & background location *(phase 2)* | Firebase Cloud Messaging + platform location APIs | Free tier covers this comfortably; needed for en-route alerts and arrival prompts |
| iOS builds without a Mac | **Codemagic** (cloud build service) | Compiles the iOS app in the cloud — your Windows laptop never needs Xcode. Not needed until the App Store phase. |

## Unavoidable costs
- **Google Play: $25 one-time** — needed for the initial Android launch.
- **Apple Developer Program: $99/year** — not needed yet. This only comes into play once the Android version is validated and refined, so there's no reason to spend it now.
- Everything else above has a free tier that should comfortably cover early testing. Costs only start scaling with real usage — by then, ad revenue should help offset it.

---

## A few realities worth knowing up front
- **"Currently available" is always an estimate.** No app can know for certain a spot is empty without a physical sensor. The 30–60 min auto-expiry is the standard way community apps handle this (similar to how Waze ages out traffic reports) — we just need honest copy in the app ("reported 12 min ago," not "guaranteed free").
- **The AI will misread signs sometimes.** Keeping the confirmation step, plus a disclaimer that people should double-check signage themselves, matters for accuracy and for liability.
- **The en-route alert and arrival prompt are the most technically demanding part of this app.** Both need location access even when the app isn't open ("Always Allow," not just "while using") plus push notifications — a bigger ask of users, more battery drain, and stricter App Store review than the rest of the app. My suggestion: get the core report/find/navigate loop working first, then layer these on once that's solid and tested. Say the word if you'd rather build it all together from the start instead.
- **Privacy/legal:** Finland is in the EU, so GDPR applies. We'll need a short privacy policy even in v1 — what data is kept, that photos aren't stored, how to request account deletion. This is usually a one-page document, and it's a much easier document to write given photos aren't retained.
- **Your iPhone 7 Plus** tops out around iOS 15 — fine for testing, we'll just make sure the app's minimum supported iOS version covers it.

---

## Rough build order (once we start coding)
1. Set up your dev environment — Flutter SDK + tools installed on your **D: drive**, Android phone connected via USB.
2. Basic app skeleton — empty map screen, GPS permission prompt, language files wired in from the start (English/Finnish/Swedish).
3. Firebase connected — accounts (sign-up/guest), database.
4. Reporting flow — camera, AI interpretation (multi-language summaries), confirm screen.
5. Map + pins + list view + navigate handoff (Google Maps for now — Apple Maps option comes with the iOS build).
6. Ads (guest vs. registered logic).
7. Auto-blur + photo deletion, report button, privacy policy (translated into all launch languages).
8. Test on both your phones, fix rough edges.
9. Google Play listing + submit — launch, market it, and collect real feedback.
10. Once refined based on that feedback: Apple Developer account + App Store submission.
11. *(Phase 2, once v1 is working)* Push notifications + background location for en-route alerts and arrival prompts.
