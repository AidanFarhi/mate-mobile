# 1. State management and routing

- **Status:** Accepted
- **Date:** 2026-09-02
- **Issue:** [#2](https://github.com/AidanFarhi/mate-mobile/issues/2)

## Context

Every feature issue (#5–#21) needs to read shared state and move between
screens. Without a decision made once, up front, each feature invents its own
pattern and the app ends up with three ways to do everything.

`docs/software_design.md` calls for a client that is "easy to understand and
maintain"; `docs/ui_design.md` specifies nine screens, a three-tab bottom bar,
and a set of pushed views.

## Decision

**State management: Riverpod** (`flutter_riverpod`, no code generation).

Providers are declared as plain `NotifierProvider`/`Provider` values. We skip
`riverpod_generator` deliberately: codegen would add `build_runner` to CI and a
generated-file review burden, to save a few lines of boilerplate per provider.
For an app this size that trade is not worth it.

**Routing: go_router**, with a single `ShellRoute` for the tab destinations.

**Auth state is a four-value enum**, not a boolean:

```
unknown → signedOut → needsProfileSetup → signedIn
```

`unknown` is the launch state. A cold start cannot answer "is this user signed
in" synchronously — #6 has to read the Keychain and exchange a refresh token
first. Without an explicit unknown state the router treats launch as signed-out
and flashes the Sign In screen at every returning user.

`needsProfileSetup` is what registration amounts to here: Sign in with Apple
creates the account, and the user is authenticated but has no username or icon
until #7 completes.

**The redirect is a pure function.** `resolveAuthRedirect(status, location)`
lives apart from the `GoRouter` that calls it, so the full matrix is unit
tested without pumping a widget tree, including the property that no
status/location pair can produce a redirect loop.

## Route table

| Path | Screen | In tab shell |
|---|---|---|
| `/splash` | bootstrap | no |
| `/sign-in` | Sign In | no |
| `/profile-setup` | Initial Profile Setup | no |
| `/` | Home / Active Game | **yes** (Play) |
| `/friends` | Friends | **yes** (Friends) |
| `/you` | You — profile + history | **yes** (You) |
| `/friends/:username` | Friend Profile | no |
| `/game/:id` | Game Board *or* Game Detail | no |
| `/settings` | Settings | no |

Two departures from the route list originally written in #2:

- **No `/history`.** The UI spec folds game history into the "You" screen, so
  `/you` is that screen and history is a section inside it.
- **`/game/:id` serves both a live board and a finished game's notation.** One
  game has one URL; the screen branches on the game's status. Adding
  `/games/:id` would mean two paths for one noun, and a game that ends while a
  link is being opened would resolve to the wrong one.

## Alternatives considered

**`StatefulShellRoute` instead of `ShellRoute`.** It gives each tab its own
back stack. The UI spec says back "returns to the pusher, defaulting to Home" —
plain pop semantics — so the nested navigators would buy nothing for V1.

**Bloc.** More ceremony per feature than this app needs, and no benefit over
Riverpod for state this simple.

**Tab bar as a plain widget on three screens.** Fewer router concepts, but the
bar gets defined in three places and drifts.

## Consequences

- Feature issues get providers and routes to plug into, and no per-feature
  navigation decisions.
- #6 replaces the body of `AuthController` — Keychain reads, token refresh —
  without the router or its tests changing shape.
- The router is built once and never rebuilt: `routerProvider` bridges auth
  state to a `ValueNotifier` rather than watching it, because watching would
  discard the navigation stack on every sign-in.
- If per-tab back stacks are wanted later, moving to `StatefulShellRoute` is a
  change to one file.
