# Mate

Play chess with your friends. Flutter client, targeting iOS first.

See [docs/software_design.md](docs/design/software_design.md) for the product and
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

See [docs/contributing.md](docs/contributing.md) for how a feature goes from an
open issue to merged code, plus the house style those checks assume.

## Project layout

```
lib/
  main.dart
  app/
    routing/    # router, route table, auth redirect
    theme/      # design tokens: palette, typography, spacing, board
  core/         # config, errors, result types, extensions
  data/         # api client, models, repositories
  features/     # auth, friends, game, profile, settings
  ui/
    components/ # shared widgets
    gallery/    # debug-only component gallery
assets/
  fonts/        # Instrument Sans + JetBrains Mono, both OFL
```

## Architecture

- **State management:** [Riverpod](https://riverpod.dev) (`flutter_riverpod`,
  no code generation).
- **Routing:** [go_router](https://pub.dev/packages/go_router), with one
  `ShellRoute` for the three tab destinations and everything else pushed over
  it.
- **Theme:** dark only. `docs/design/ui_design.md` specifies a single dark theme and
  defines no light palette. Tokens live in `lib/app/theme/` and reach screens as
  three `ThemeExtension`s — `AppPalette`, `AppTypography`, `BoardPalette`. No
  screen defines its own colors; a test fails the build on a color literal
  outside `lib/app/theme/`.

### Component gallery

Debug builds carry a gallery of every shared component and token at `/gallery`,
with a control for previewing the page at up to 200% text scale. Reach it from
the debug bar at the bottom of any placeholder screen. It is not registered in
release builds.

See [docs/adr/0001-state-management-and-routing.md](docs/adr/0001-state-management-and-routing.md)
for the reasoning and the full route table, and
[docs/adr/0002-game-kinds-and-abandonment.md](docs/adr/0002-game-kinds-and-abandonment.md)
for the game-kind model, the two-slot active-game shape, and the stalled-game
rule, and
[docs/adr/0003-design-tokens-and-theme-extensions.md](docs/adr/0003-design-tokens-and-theme-extensions.md)
for how design tokens are structured and enforced.

Android is not generated: V1 is iOS only. Keep platform-specific code minimal so
Android can be added later.
