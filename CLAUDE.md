# Mate

Minimal chess with your friends. Flutter client, iOS first. The Go backend and
Postgres schema described in the design doc do not exist yet.

## Process

**`docs/contributing.md` is the workflow — follow it.** The short version:

branch → clarify only if genuinely ambiguous → implement → summarize →
validation plan → **stop and wait for the user to validate** → PR
(`Closes #<n>`) → merge → back to `main`, delete the branch.

The stop before opening a PR is a hard gate, not a formality.

## Checks

CI runs these on every PR. Run them before claiming work is done:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
```

Flutter 3.47.1, pinned in `.fvmrc`. `--fatal-infos` means an info-level lint is
a real failure, not advice.

## Docs

| Path | Owns |
|---|---|
| `docs/design/software_design.md` | product rules, data model, API surface, backend invariants |
| `docs/design/ui_design.md` | screens, design tokens, interaction spec |
| `docs/adr/` | decisions and the alternatives they beat |
| `docs/contributing.md` | workflow and house style |

Work is tracked in GitHub issues #3–#27. Changing behavior one of these docs
describes means updating that doc in the same PR — and updating any issue the
change makes *wrong* rather than merely incomplete.

## Style

Full detail in `docs/contributing.md`. The two most easily violated:

- **Explicit types on declarations**, including locals and collection literals:
  `final List<String> x = <String>[...]`, not `final x = [...]`.
- **Comments explain why, not what.** Justify a decision, name the issue that
  replaces a stub, or warn about a trap. Otherwise write none.

Dark theme only — there is no light palette. Feature screens never define their
own colors or text styles; everything resolves through the theme.
