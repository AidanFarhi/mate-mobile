# Working in this repo

How a feature goes from an open issue to merged code. The loop below is the
process; everything after it is the house style that the loop assumes.

Most of this is descriptive rather than aspirational — it is what
[PR #26](https://github.com/AidanFarhi/mate-mobile/pull/26) and the code in
`lib/` already do. Where a rule below is not obvious from the code, it says why
it exists.

## The loop

### 1. Branch

```sh
git switch main && git pull --ff-only
git switch -c feat/<issue-number>-<slug>
```

The slug is the issue title, kebab-cased and trimmed to something readable:
`feat/2-app-architecture-foundations`. The issue number is in the branch name so
that a stale branch is always traceable to its work item.

Branch first, before reading deeply into the issue. It costs nothing and it
means exploratory commits never land on `main`.

### 2. Ask, if the issue is genuinely ambiguous

Read the issue, the parts of `docs/design/software_design.md` and `docs/design/ui_design.md`
it cites, and any ADR it references. Then decide whether you actually need
input.

**Ask when two readings of the issue would produce materially different work** —
a different data shape, a different screen, a different set of API calls.
Ask *before* implementing, not after; a question raised at review time has
already cost the work it should have prevented.

**Do not ask about anything the docs or the code already answer**, or about
choices with an obvious default. Routine judgment calls are yours to make. Make
them, and record the reasoning in the PR body — that is what the "Decisions"
section is for.

If a decision will outlive the issue — anyone touching this area later has to
know it — it belongs in an ADR instead. See below.

### 3. Implement

Small, separable commits. If part of the change is mechanical or bulky (asset
imports, generated files, a doc dump), commit it on its own so the reviewable
part of the diff stays reviewable — PR #26 split the design prototype files out
for exactly this reason.

Commit messages are imperative and sentence case, no type prefix:

```
Wire app architecture foundations: Riverpod, go_router, config, errors
Add debug-only auth switcher to placeholder screens
```

Run the three CI checks locally before you think you are done. They are cheap
and they fail in the order that costs you the least time:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
```

`dart format .` fixes formatting in place. `--fatal-infos` is what makes the
stricter lints in `analysis_options.yaml` block a merge instead of being
advisory, so an info-level complaint is a real failure.

### 4. Summarize what you built

Before asking anyone to look at it, write the summary: what changed, what
decisions you made and why, and anything you deliberately did not do. This is
the raw material for the PR body, and writing it early surfaces the parts you
cannot justify.

### 5. Write a validation plan

Separate from the automated tests, which are part of the implementation. This is
**how a human confirms the feature actually works** — concrete steps, expected
results, and an explicit list of what the steps do not cover.

```
1. flutter run
2. Sign in → land on Profile Setup (new account) or Home (returning).
3. Enter "ab" → hint reads "A bit short", Continue stays disabled.
4. Enter "mira.k" → hint reads "Taken" in the muted color.
...

Not covered: physical-device behavior, VoiceOver, 200% text scaling.
```

The "not covered" line is not optional. An honest gap someone can decide about
beats a validation plan that implies more coverage than it has.

### 6. Stop. Wait for validation.

**This is a hard gate.** Post the summary and the validation plan, and do not
open a PR until the person running it says it passed. If validation turns up a
problem, fix it on the same branch and re-run the plan.

Once validated:

```sh
gh pr create --title "<issue title>" --body-file <path>
gh pr merge --merge --delete-branch
```

The PR body **must** open with `Closes #<n>.` so the merge closes the issue.
Merge commits, not squash — the per-commit history is deliberate.

### 7. Clean up

```sh
git switch main
git pull --ff-only
git branch -d feat/<issue-number>-<slug>
```

`--delete-branch` removes the remote branch, and usually the local one too;
run the above regardless so `main` is current and no stale branch is left
behind. Confirm the issue actually closed — if `Closes #<n>` was missing or
malformed, close it by hand and note why in a comment.

## The PR body

[PR #26](https://github.com/AidanFarhi/mate-mobile/pull/26) is the template.
The shape:

- **`Closes #<n>.`** and a sentence on what the change is for.
- **Decisions** — every non-obvious choice, each with the alternative it beat
  and why. A decision without its rejected alternative is not documented, it is
  asserted.
- **The parts that outlive this issue.** Most of a PR is only interesting until
  it merges; name the pieces that later work has to build on, because those are
  what a reviewer should spend their attention on.
- **Verification** — the commands you ran and their results, verbatim:

  ```
  dart format --output=none --set-exit-if-changed .   ✓
  flutter analyze --fatal-infos                       ✓  No issues found
  flutter test                                        ✓  14/14
  flutter build ios --simulator --debug               ✓  Built Runner.app
  ```

- **What you did not verify.** Same rule as the validation plan.

## Coding standards

**Explicit types on declarations**, including locals and collection literals:
`final List<String> locations = <String>[...]`, not `final locations = [...]`.
Unusual for Dart, deliberate here: it makes a diff readable without the
analyzer, and it makes an accidental `dynamic` visible.

**Comments explain why, not what.** The code already says what it does. Every
comment in `lib/` justifies a decision, names the issue that will replace a
stub, or warns about a trap — `AuthStatus`'s four values, `routerProvider`'s
refusal to `watch`, `AppConfig`'s note that `String.fromEnvironment` silently
yields the default outside a const context. Write that kind, or none.

**Pull pure logic out of widgets.** `resolveAuthRedirect` lives apart from the
`GoRouter` that calls it so its whole matrix is unit-testable without pumping a
widget tree. Anything with real branching deserves the same treatment.

**Sealed hierarchies over loose types** where exhaustiveness matters, so a
missed `switch` case is an analyzer error rather than a silent fallthrough. See
`AppFailure`.

**No feature screen defines its own colors or text styles.** Everything resolves
through the theme (#3). The app ships one dark theme; there is no light palette
to write.

**Stubs name their successor.** A placeholder carries the issue number that
replaces it, so nothing untracked survives to release.

Lints enforced by `analysis_options.yaml`, on top of `flutter_lints`:
`always_declare_return_types`, `prefer_const_constructors`,
`require_trailing_commas`.

## Tests

`test/` mirrors `lib/` — `lib/app/routing/auth_redirect.dart` is tested by
`test/app/routing/auth_redirect_test.dart`.

Prefer testing a **property** over an example where one exists. The redirect
tests do not just check a handful of pairs; one asserts that whatever the
redirect returns is itself allowed on the next pass, which makes redirect loops
impossible rather than merely untested. That test keeps working when someone
adds a route.

Every issue's acceptance criteria should be checkable against something in the
suite. If it cannot be, say so in the PR rather than quietly leaving it manual.

## When to write an ADR

Write one when a decision **outlives the issue that forced it** — anyone working
in that area later needs to know the reasoning, and a PR body is not where they
will look.

`docs/adr/000N-kebab-title.md`, numbered sequentially, following the shape of
the existing two: Status / Date / Issue, then Context, Decision, Alternatives
considered, Consequences. Alternatives considered is the section that earns the
document; without it you have a changelog entry.

Reference the ADR from the PR and from `README.md`.

## Docs that must stay in sync

Changing behavior described in one of these means updating it in the same PR:

| Doc | Owns |
|---|---|
| `docs/design/software_design.md` | product rules, data model, API surface, backend invariants |
| `docs/design/ui_design.md` | screens, tokens, interaction spec |
| `docs/adr/` | decisions and their rejected alternatives |
| `README.md` | setup, environment, project layout, architecture pointers |

If a change makes an open issue wrong — not merely incomplete — update the issue
too. A stale acceptance criterion is worse than a missing one, because someone
will implement against it.
