# 2. Game kinds, availability, and abandonment

- **Status:** Accepted
- **Date:** 2026-09-05

## Context

Bots are a post-V1 feature (`docs/design/software_design.md`, Future Add-Ons). But two
of the decisions they force are cheap to make now and expensive to make later,
because `games` is retained permanently and is the source of every statistic in
the app. A `kind` column added after launch has no correct backfill: a bot game
and a friend game are otherwise identical rows.

Reviewing the V1 design for this found that it hardcodes "the opponent is a
human friend" in four places — the non-null player foreign keys, the global
one-active-game rule, the unconditional friendship precondition, and the
unfiltered stat derivation.

The same review surfaced a hole that exists in V1 with no bots involved.
Untimed games plus one game at a time means a friend who stops responding locks
the other player's only game slot indefinitely, and the only escape is Resign —
which costs a loss on the one record this product keeps. Head-to-head against a
friend is the entire competitive surface here; making players buy their way out
of a dead game with it is the wrong trade.

## Decision

### One active game per kind, and bots do not affect availability

Every game carries `kind`: `friend` or `bot`. A player may hold **one active
friend game and one active bot game simultaneously**. Availability — the
"Playing"/"Busy" chip, and the check that gates challenge creation — reads
friend games only. Bot games have no friendship precondition, and no statistic
counts them.

Coexistence is the whole point rather than a compromise. The reason
one-friend-game-at-a-time survives contact with reality is that the answer to a
slow opponent is a practice game; if a live friend game blocked bot games, the
feature would not solve the problem it exists to solve.

An earlier draft of this had a friend game preempt and auto-end any active bot
game, to keep "one board" literally true. That was wrong for exactly the reason
above, and it also destroyed user work to enforce a rule nobody had asked for.

Because the two coexist, `GET /games/active` returns **two named slots**, not a
list:

```json
{ "game": { … } | null, "practice": { … } | null }
```

This is the line between this design and the multi-game inbox the product
explicitly rejects. Two fixed singular slots keep Home's single active-game card
and the router's one-game-one-URL premise intact; a list would turn Home into a
sorted feed with badge counts. V1 ships the shape with `practice` always null,
so bots land additively instead of breaking #12, #13 and #17.

The invariant lives in an `active_games` table keyed `(user_id, kind)`. A player
occupies either `white_player_id` or `black_player_id`, so no single partial
unique index on `games` can express the rule, and a rule this load-bearing
should be a database guarantee rather than application code.

### Stalled games can be ended after 12 hours, by the waiting player only

The clock runs on whoever is to move. After **12 hours** of idleness, the
*waiting* player may end the game, and chooses the outcome: **end it** (nothing
recorded) or **claim the win** (recorded normally).

Three properties matter, in order:

**Only the waiting player may act.** If the idle player could void the game,
stalling becomes a button that erases a loss. Their exits stay *move* or
*resign*. Nobody gets to escape a losing position by going quiet.

**Claim-win exists to close the same hole from the other side.** With voiding as
the only option, a player could still stall out of a loss and rely on their
opponent having no alternative. Giving the wronged party the choice puts the
decision in the only fair place, and means quietness is not a reliable strategy.
Ending is the primary action: usually a phone died, and the app's temperature
should reflect that.

**Nothing fires automatically.** Crossing the threshold unlocks an action; it
does not end anything. No cron job, no game vanishing out from under a player,
and a game nobody acts on stays active and resumable forever. This is what makes
12 hours safe when a correspondence app would need days — a threshold that only
grants an option can be short.

The server sends `abandonable_at` on the game payload and the client compares it
to the current time, so the rule is not reimplemented client-side and does not
depend on device clock accuracy.

An ended game is `status = abandoned` with a null result. Because stats were
already specified as deriving from *completed* games, they fall out of every
record for free; the only added filter anywhere is `kind = 'friend'`.

## Alternatives considered

**Multiple concurrent friend games.** The standard answer, and it buys exactly
one thing: a slow opponent stops blocking you. Bots buy that instead, at far
lower cost. Going concurrent would turn Home's single card into a sorted feed,
make `/games/active` plural across #12/#13/#17, force N sockets or a multiplexed
one in #16, and delete the Playing/Busy chip logic — and untimed plus many games
*is* correspondence chess, which `docs/design/software_design.md` rules out by name.

**One active game total, of any kind.** Simplest rule, and it fails quietly: mid
practice game, a friend opens Friends, sees "Busy", and does not challenge. A
fake game costs a real one and neither player ever learns it happened.

**Timeout awards the win automatically**, as correspondence chess does. Correct
for integrity, wrong here — a friend whose phone broke hands you a win you did
not play for, and the app has no ratings for that result to even mean anything.

**Timeout voids for both, with no claim option.** Kinder and one less UI branch.
Rejected because it leaves stalling as a free escape from a losing game, and
head-to-head is the only competitive thing in the product. Defensible in a
friends-only app where social cost does real enforcement work — but the branch
is small and the hole is real.

**No `kind` column; a separate `bot_games` table.** Duplicates the move
pipeline, the WebSocket handling, and the history queries, to avoid one enum.

## Consequences

- V1 writes `kind = 'friend'` and `users.kind = 'human'` everywhere and is
  otherwise unaffected. The cost today is two enum columns, `bot_level`,
  `last_move_at`, and an API shape.
- Bot moves arrive over the game's existing WebSocket. #15 and #17 need no
  awareness of bots at all: a bot game is a game whose opponent happens to be a
  process, and the sequence-reconciliation logic cannot tell.
- #14's `ChessBoard` is already FEN-in/widget-out, so it is reusable unchanged.
  The coupling risk is #18: if the board screen reads the active-game provider
  and opens the socket itself, a bot game forks the app's primary screen. #18
  should consume a session object — position, status, submit callback — with the
  socket owned by the controller above it.
- `docs/design/ui_design.md` needs a designer pass for two states it does not cover: a
  neutral "unfinished" result chip alongside W/L/D, and the end/claim options in
  the resign sheet once a game is stale. Home should also surface eligibility
  ("mira.k hasn't moved in 12 hours") — with no push notifications in V1 scope,
  Home is the only place a waiting player would discover it.
- Twelve hours is a server-side constant. Changing it is a deploy, not a
  release.
