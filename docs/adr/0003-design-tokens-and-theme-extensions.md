# 3. Design tokens and theme extensions

- **Status:** Accepted
- **Date:** 2026-09-05
- **Issue:** [#3](https://github.com/AidanFarhi/mate-mobile/issues/3)

## Context

`docs/design/ui_design.md` fixes the visual language for all nine screens and
declares it final for V1: a token table of 20-odd colors, a sans/mono type
scale of 18 roles, an irregular spacing set, and nine corner radii. Every
feature issue from #5 to #21 renders against it.

The issue's acceptance criterion is the constraint that matters: *no feature
screen defines its own colors or text styles*. That is not a style preference.
The app ships one dark theme, so a screen that hardcodes `#EDEEE7` at 50%
because the token it wanted was not exported is how a single theme becomes
several near-identical ones, and nobody notices until a designer opens the
build.

Flutter's `ThemeData` cannot hold this token set on its own. `ColorScheme` has
one `onSurface`, and the design has four text tiers, five translucent fills, two
scrims and a board palette. `TextTheme` has thirteen slots, none of which means
"mono", and mono carries every meta line, label, friend code and SAN move in the
app.

## Decision

**Tokens live in `lib/app/theme/`, exposed as three `ThemeExtension`s.**

| Extension | Holds |
|---|---|
| `AppPalette` | every chrome color: text tiers, fills, hairlines, washes, scrims |
| `AppTypography` | all 18 type roles, including the mono half of the scale |
| `BoardPalette` | squares, last-move highlights, piece fills and outlines |

Screens read them with `AppPalette.of(context)`, not from constants. The
`ColorScheme` and `TextTheme` are populated from the same values so framework
widgets — dialogs, snackbars, text fields — are styled without a screen
restating anything.

Spacing and radii are plain constants in `AppSpacing`/`AppRadii`. They do not
vary with anything, and threading a `BuildContext` to read a value that cannot
change buys nothing.

**A test enforces the criterion.** `test/app/theme/color_tokens_guard_test.dart`
scans `lib/` and fails on any color literal outside `lib/app/theme/`. When a
screen needs a shade that is not a token, the fix is a token.

**Both faces are bundled, not fetched.** Instrument Sans and JetBrains Mono ship
as variable fonts under the OFL, with their licenses registered into
`showLicensePage`.

**One shared enum for the type scale's weights is not attempted.** Because the
faces are variable, every role sets `fontVariations` alongside `fontWeight`;
`fontWeight` alone asks for a static instance the bundled files do not contain,
and the platform answers with a synthesized or simply wrong weight. A test
asserts the two agree for every role.

## Alternatives considered

**Static constants (`AppColors.accent`) instead of extensions.** Simpler, and
with one fixed theme it would work. Rejected because it makes the guard test the
*only* thing standing between the app and ad-hoc color: nothing distinguishes
`AppColors.accent` from `Color(0xFFB4C4A8)` at the call site, both are just
values in scope. Going through `Theme.of(context)` also keeps golden tests and
any future high-contrast variant possible by substituting one extension, rather
than by editing every widget.

**Bending the tokens onto `ColorScheme`.** Mapping `text-tertiary` to
`onSurfaceVariant`, `surface-toast` to `inverseSurface`, and so on. Rejected:
the mapping is arbitrary, so every screen has to memorize it, and the next
person to read `colorScheme.inverseSurface` has no way to know it means "toast
background". The slots that *do* mean what we need are still populated.

**`google_fonts` (runtime fetch).** Smaller repo. Rejected: it makes first paint
depend on the network for an app whose whole point is that it is quiet and fast,
and it fails on exactly the flaky connection where a chess move is already at
risk. ~380KB of bundled font is the cheaper trade.

**Substituting the platform faces** (SF Pro / SF Mono), as the design doc allows
if the named ones are not licensed. Rejected because both *are* openly licensed,
so the fidelity is free, and the substitution clause exists for the case where it
is not.

**A `widgetbook` dependency for the gallery.** Rejected: a package, its codegen,
and its own navigation model to render a single scrolling page. `GalleryScreen`
is ~350 lines with no dependency, and it is driven by a widget test that fails CI
on an overflow at 200% text — which is the part that actually catches
regressions.

## Consequences

- Adding a color means adding a token and a gallery swatch. That is deliberate
  friction: it puts every new value in front of a reviewer.
- The three extensions implement `copyWith`/`lerp` as no-ops. With one theme
  there is nothing to copy from or interpolate toward, and doing it properly
  would bury the token table under ~80 lines of parameter list. If a second
  theme is ever introduced, these have to be written out first.
- `AppPalette.of` asserts rather than falling back silently, so a widget pumped
  in a test without the app theme fails loudly instead of rendering in Material
  defaults.
- The gallery route is registered only in debug builds, and `resolveAuthRedirect`
  exempts it from the auth gate so it can be opened before there is a session.
  Both are compiled out of release.
