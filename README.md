# Multiplication Trainer

A simple Flutter app that helps kids practice the multiplication table. Two modes: a relaxed training session and a timed test. Runs on Android, iOS, and the web from a single codebase.

## Features

- **Training mode** — pick one table (×2 … ×9), answer 10 questions at your own pace. A wrong answer shows a visual hint (e.g. `7 × 3 = 7 + 7 + 7 = 21`).
- **Time Test mode** — pick one or more tables, answer 10 questions; total time is measured.
- **Custom on-screen keypad** — kid-friendly, no system keyboard or answer guessing.
- **Star rating** — 0–3 stars per session based on accuracy, with a confetti burst for a perfect score.
- **Local history** — the last 5 results are persisted on the device; a reset button clears them.
- **No accounts, no network** — everything is stored locally.

## Requirements

- Flutter SDK `3.11+` on the stable channel
- For Android builds: Android Studio with SDK + command-line tools installed, USB debugging enabled on the device
- For iOS builds: macOS with Xcode (not supported on Windows)

Run `flutter doctor` to verify the toolchain.

## Getting started

```bash
flutter pub get
```

Then pick a target:

```bash
# Run in Chrome (fastest iteration)
flutter run -d chrome

# Run on a connected Android device
flutter devices            # find the device ID
flutter run -d <device-id>
```

While `flutter run` is active:

- `r` — hot reload (Dart changes, state is kept)
- `R` — hot restart (state reset; use after adding/removing files)
- `q` — quit

After adding a new package to `pubspec.yaml`, do a full `q` + `flutter run` — hot restart does not register new native plugins.

## Project structure

```
lib/
├── main.dart                 App entry point and theme
├── models/                   Plain data classes (no UI)
│   ├── game_mode.dart        enum: training vs timeTest
│   ├── question.dart         One multiplication question (a × b)
│   └── quiz_result.dart      A finished session (with JSON serialization)
├── logic/                    Pure logic, no UI
│   ├── quiz_generator.dart   Generates question sequences
│   └── results_storage.dart  Loads/saves history via shared_preferences
├── screens/                  One file per full-screen page
│   ├── home_screen.dart
│   ├── digit_picker_screen.dart
│   ├── quiz_screen.dart
│   ├── result_screen.dart
│   └── history_screen.dart
└── widgets/                  Reusable UI pieces
    ├── number_keypad.dart    Calculator-style 0–9 keypad
    └── star_rating.dart      Row of filled/empty stars
```

The folders split code by **responsibility**, not by feature: widgets don't know about storage, models don't know about UI, etc. A new screen should only pull from `models/`, `logic/`, and `widgets/`.

## Dependencies

| Package | Purpose |
| --- | --- |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Local key-value store for the history (localStorage on web, SharedPreferences on Android, NSUserDefaults on iOS) |
| [`confetti`](https://pub.dev/packages/confetti) | Particle animation on the result screen for a 3-star result |

## Design decisions

A short log of choices we made, so we don't have to rediscover the reasoning later.

### State management: plain `setState`

No `Provider`, `Riverpod`, `Bloc`, or similar. Each screen owns its own state and passes data through constructor parameters; the navigation stack holds the rest. Nothing in this app is shared between screens, so a global state library would only add ceremony.

### Persistence: `shared_preferences`, not SQLite

We store only 5 results max. A relational database would be overkill. JSON-encoded list in a single key is readable, trivial to serialize, and requires zero schema migrations.

### Questions: generate up front, not lazily

`QuizGenerator.generate` returns a ready list of 10 questions on quiz start. Simpler than lazy generation, and it guarantees "no two identical questions in a row" by checking against the previous question during generation.

### Custom keypad, not system keyboard or multiple-choice

- The system keyboard is clumsy on mobile for short numeric answers.
- Multiple-choice lets kids guess without actually computing.
- A calculator-style keypad is familiar and forces real input.

### One `QuizScreen` for both modes

`GameMode` is just a parameter. Training and Time Test differ only in:
- whether multiple digits can be picked (decided one screen earlier)
- whether elapsed time is shown at the end

Duplicating the screen would have meant two places to fix any bug.

### No per-question feedback animation (yet)

Right now, a correct answer advances immediately; a wrong answer shows the hint. Adding a green/red flash would be a nice polish item but isn't required for the core experience.

## Build a release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`. Install on a device via `adb install` or copy the file to the phone.

## License

Personal project; no license specified.
