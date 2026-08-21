# Free Parking Finder — Finland

A community-driven Flutter app for finding free parking in Finland. Anyone can
photograph a parking sign; AI reads and interprets the rules; the spot appears
on a shared map as free parking, tagged with how long the report should be
trusted before it needs re-confirming.

## Features

- **Photo-based reporting** — snap a photo of a parking sign, Google Gemini
  (via Firebase AI Logic) reads and structures the rules, no photo is ever
  stored.
- **Map & list views** — nearby spots shown on an OpenStreetMap-based map or
  as a sorted list, color-coded by current status (free / reported full /
  outside free hours).
- **Rule-based + crowd-confirmed status** — a spot can be free by the sign's
  own schedule (e.g. "free after 18:00, weekdays") and/or by a recent
  crowd report, whichever is more current.
- **One-tap navigation** — hands off to Google Maps for turn-by-turn
  directions.
- **Accounts** — start instantly as a guest (anonymous session), or create an
  account to remove ads.
- **Self-moderated corrections** — anyone can flag a spot's rules as wrong;
  once enough independent reporters agree on the same correction, it's
  applied automatically. No manual review queue, no stored evidence photos.
- **Localized** — English, Finnish, and Swedish.

See [free-parking-finland-plan.md](free-parking-finland-plan.md) for the full
product spec and build order.

## Tech stack

- **Flutter** (Dart), Android target
- **Firebase**: Authentication (anonymous + email/password), Firestore,
  App Check, AI Logic (Gemini) for on-device photo interpretation
- **OpenStreetMap** via [flutter_map](https://pub.dev/packages/flutter_map)
  (no Google Maps API billing)
- **Google Mobile Ads (AdMob)** — full-screen ads for guests, banner ads for
  registered users

## Project status

Currently in active development, Android-first. Ads, reporting, the map/list
views, and the crowd-correction flow are implemented and tested on an
emulator. Physical-device testing, a privacy policy, and Google Play
submission are still in progress — see the plan doc for the full build order.

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android SDK / Android Studio
- A Firebase project (Spark/free plan is sufficient) with:
  - Authentication → Anonymous and Email/Password providers enabled
  - Firestore Database created
  - App Check registered for the app (debug provider for local development)
  - AI Logic (Gemini API) enabled

### Setup

```bash
git clone https://github.com/yomalfdo/free_parking_finland.git
cd free_parking_finland
flutter pub get
flutter gen-l10n
```

#### Firebase config

`android/app/google-services.json` is intentionally **excluded** from this
repository (Firestore rules are still in their initial test-mode/open
window, so the config file isn't published alongside them). To run the app
yourself:

1. Create a Firebase project and add an Android app with package name
   `com.freeparkingfinland.free_parking_finland`.
2. Download the generated `google-services.json` and place it at
   `android/app/google-services.json`.
3. On first run, App Check (debug provider) will print a debug token to
   logcat — register it in the Firebase console under App Check → Apps.

### Run

```bash
flutter run
```

### Test

```bash
flutter analyze
flutter test
```

## License

All rights reserved — see [LICENSE](LICENSE). This code is public for
portfolio/reference purposes only; it is not licensed for reuse.
