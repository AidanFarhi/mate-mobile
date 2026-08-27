# Shadow & Light

Play chess with your friends. Flutter client, targeting iOS first.

See [docs/software_design.md](docs/software_design.md) for the product and
architecture overview.

## Prerequisites

- **Flutter 3.47.1** (Dart 3.13.1). The version is pinned in
  [`.fvmrc`](.fvmrc); [FVM](https://fvm.app) will pick it up automatically, and
  CI reads the same file.
- **Xcode** with the iOS simulator installed, plus CocoaPods (`sudo gem install
  cocoapods`).

Verify your setup with `flutter doctor`.

## Running on iOS

```sh
flutter pub get
open -a Simulator     # or pick a device with `flutter devices`
flutter run
```

## Tests and checks

These are the same three checks CI runs on every pull request:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
```

`dart format .` fixes formatting in place.

## Project layout

```
lib/
  main.dart
  app/          # app widget, router, theme wiring
  core/         # config, errors, result types, extensions
  data/         # api client, models, repositories
  features/     # auth, friends, game, profile, settings
  ui/           # shared widgets
```

Android is not generated: V1 is iOS only. Keep platform-specific code minimal so
Android can be added later.
