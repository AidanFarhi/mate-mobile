# Mate

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

### Environment

The backend host is a compile-time value, so a build is pinned to exactly one
API. Defaults point at a local Go server, which is what running the API on your
own machine gets you for free:

| Define | Default (dev) | Production |
|---|---|---|
| `API_BASE_URL` | `http://localhost:8080` | `https://<app>.fly.dev` |
| `WS_BASE_URL` | `ws://localhost:8080` | `wss://<app>.fly.dev` |

```sh
flutter run \
  --dart-define=API_BASE_URL=https://<app>.fly.dev \
  --dart-define=WS_BASE_URL=wss://<app>.fly.dev
```

The production host is a placeholder until the Go service is deployed. No
secrets go through `--dart-define` — it is not a secure channel, and anything
passed this way is readable in the built binary.

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

## Architecture

- **State management:** [Riverpod](https://riverpod.dev) (`flutter_riverpod`,
  no code generation).
- **Routing:** [go_router](https://pub.dev/packages/go_router), with one
  `ShellRoute` for the three tab destinations and everything else pushed over
  it.
- **Theme:** dark only. `docs/ui_design.md` specifies a single dark theme and
  defines no light palette.

See [docs/adr/0001-state-management-and-routing.md](docs/adr/0001-state-management-and-routing.md)
for the reasoning and the full route table.

Android is not generated: V1 is iOS only. Keep platform-specific code minimal so
Android can be added later.
