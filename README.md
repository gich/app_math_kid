# Multiplication Trainer

A simple Flutter app that helps kids practice the multiplication table. Two modes: a relaxed training session and a timed test. Runs on Android, iOS, and the web from a single codebase.

## Features

- **Training mode** — pick one table (×2 … ×9), answer 10 questions at your own pace. A wrong answer shows a visual hint (e.g. `7 × 3 = 7 + 7 + 7 = 21`) and waits for "Continue".
- **Time Test mode** — pick one or more tables and a countdown duration (1 min / 45 s / 30 s / 20 s / 15 s), then race to finish 10 questions before the timer runs out. Wrong answers flash briefly and auto-advance to keep the pace up. Finishing in time saves the result; if the timer expires the attempt is discarded and not saved.
- **Custom on-screen keypad** — kid-friendly, no system keyboard or answer guessing.
- **Star rating** — 0–3 stars per session based on accuracy, with a confetti burst for a perfect score.
- **Local history** — the last 5 successful results are persisted on the device; a reset button clears them.
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

`GameMode` is just a parameter. Training and Time Test share the same quiz screen, keypad, and 10-question count, differing only in:
- whether multiple digits can be picked (decided one screen earlier)
- whether a countdown timer runs
- how a wrong answer is handled (training waits for "Continue"; time test flashes and auto-advances)
- how the quiz can end (training ends after question 10; time test ends on question 10 OR on timeout)

Duplicating the screen would have meant two places to fix any bug.

### Time Test: 10 questions within a countdown, not "as many as you can"

We considered the alternative "answer as many as you can in X seconds", but settled on "answer all 10 before the timer runs out". It keeps the scoring (10 questions, N correct) identical to training — the same `QuizResult` shape, the same star logic, the same history entry. The only extra variable is the countdown.

### Timed-out attempts are not saved

If the timer reaches 0 before the user finishes all 10 questions, we show a "Time's up!" screen and discard the attempt — it does not land in history. This way history represents genuine completed sessions and star averages stay meaningful. The user can retry with the same duration or pick a longer one.

### No per-question feedback animation (yet)

Right now, a correct answer advances immediately; a wrong answer shows the hint (training) or a red flash (time test). A green pulse on correct answers would be a nice polish item but isn't required for the core experience.

### Theme

Pink scaffold background, blue buttons with light-pink labels. Chosen for a playful, kid-friendly look. Defined once in `main.dart` via `scaffoldBackgroundColor`, `ColorScheme.fromSeed`, and `FilledButtonThemeData` / `ElevatedButtonThemeData` — every button in the app picks up the colors automatically. The only per-widget override is the green "submit" key on the number keypad (explicit white icon for contrast).

## Build a release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`. Install on a device via `adb install` or copy the file to the phone.

## License

Personal project; no license specified.
