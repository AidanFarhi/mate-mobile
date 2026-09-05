# Mate: Minimal Chess — Software Design Doc

# Overview

A simple, low-latency, friend-based chess app built primarily for iOS. The product should feel fast, private, and intentionally minimal: users play only with accepted friends, can have only one active game at a time, and keep a complete history of games and moves for future analysis.

# Goals

* Fast, responsive chess gameplay with near-real-time move updates.  
* Simple onboarding and friend-based play with no public matchmaking.  
* Clean, modern UI with very few settings or distractions.  
* Durable game and move history suitable for future replay, statistics, and ML analysis.  
* Small architecture that is easy to understand and maintain.

# Non-Goals for V1

* Public matchmaking or rankings.  
* Multiple simultaneous games against other people.  
* Timed games or chess clocks.  
* User-uploaded profile images.  
* Board themes, piece themes, or extensive customization.  
* Full text chat.  
* Engine analysis or gameplay coaching.  
* Playing against a computer opponent. Deliberately deferred, but the V1 schema is shaped to accept it without a migration — see Game Kinds below.

# Core Product Rules

1\. A user may only start or accept a game against another person if that person is an accepted friend.  
2\. A user may have only one active game *against another person* at a time.  
3\. Games are untimed in V1, but interactions should feel immediate rather than correspondence-style.  
4\. A game whose player-to-move has been idle for 12 hours may be ended by the player who is waiting, who chooses whether to void it or claim the win.  
5\. The server is authoritative for legal moves and canonical game state.  
6\. Completed games and every move are retained permanently unless required to be removed with account deletion.

# V1 Features

## Authentication and Accounts

* Sign in with Apple as the primary authentication mechanism.  
* First login asks the user to choose a unique username and one icon from a fixed set of pre-made profile icons.  
* Settings include sign out and account deletion.

## Friends

* Add friends using a simple friend code or exact username.  
* Friend requests can be accepted or declined.  
* Only accepted friends can challenge one another.  
* Optional later enhancement: contact-based invites or shareable invite links. Avoid requiring contact access in the first release unless it clearly improves onboarding.  
* Users can remove or block another user.

## Games

* Start a game by selecting an accepted friend.  
* A challenge can be accepted or declined.  
* A player cannot create or accept another game while either player already has an active game against a person.  
* Randomly assign or allow simple selection of White/Black.  
* No time limit or chess clock in V1.  
* Support resign, draw, and stalled-game outcomes.  
* Validate all moves on the backend before committing them.  
* Persist the current FEN/state plus the full ordered move history.

## Stalled Games

Untimed games plus one game against a person at a time means a friend who stops responding locks the other player's only game slot indefinitely. Resigning is not an acceptable escape: it costs a loss on the one record the product actually keeps. So a stalled game gets an explicit exit.

* The clock runs on **whoever is to move**. Exactly one player is idle at any moment, and the other is waiting.
* After the player to move has been idle for **12 hours**, the waiting player may end the game. The idle player may not — their only exits stay *move* or *resign*.
* The waiting player picks the outcome: **end it** (nothing recorded) or **claim the win** (recorded normally). Ending is the primary action; claiming exists so that going quiet is not a free escape from a losing position.
* Nothing happens automatically. The threshold only unlocks an action; a game nobody acts on stays active forever, which is correct — the idle player can always resume it by moving.
* The server computes eligibility and sends `abandonable_at` on the game payload. The client compares it to the current time; it does not reimplement the rule, and does not depend on device clock accuracy.
* An ended game gets `status = abandoned` and no result. It is excluded from win/loss/draw records and from head-to-head, and appears in history as unfinished.
* Twelve hours is a server-side constant, chosen so a dead game clears within a day rather than a week. It is safe to keep short precisely because crossing it triggers nothing on its own.

## Low-Latency Interaction

* Use a persistent WebSocket connection while a game is open.  
* The client may optimistically render a locally legal move, but the server remains authoritative.  
* The backend validates and commits the move in a transaction, then broadcasts the accepted move to both clients immediately.  
* Each game should maintain a version or move sequence number to reject stale or duplicate updates.  
* On reconnect, the client fetches the canonical game state and resumes from the latest committed move.

## Profiles and Stats

* Profile shows username, selected icon, and basic global record: wins, losses, and draws.  
* When viewing a friend's profile, show head-to-head record against that person.  
* Show match history with that friend, including result and date.  
* Completed games remain accessible from a user's own game history.

# Game Kinds

Bots are not in V1 (see Non-Goals). What *is* in V1 is a schema that can accept them, because the alternatives are all migrations on a table that is retained permanently and read by every statistic in the app.

Every game carries a `kind`: `friend` or `bot`. V1 writes only `friend`. Three rules follow from it, and they are what the column is for:

* **Bot games never affect availability.** A player in a bot game is not busy: friends see no "Playing" chip and can still challenge them. Practice is invisible to everyone else.
* **Bot games never affect a record.** Every statistic filters `kind = 'friend'`. Without the column there is no way to separate them after the fact, since a bot game and a friend game are otherwise identical rows.
* **The two kinds coexist.** A player may hold one active friend game *and* one active bot game. This is the point of having bots at all: the answer to a slow opponent is a practice game, not a second friend game. They are not peers — the friend game is the game, the bot game is a scratchpad.

Because they coexist, `GET /games/active` returns two named slots rather than a list:

```json
{ "game": { … } | null, "practice": { … } | null }
```

Two fixed, singular slots — not the multi-game inbox this product is explicitly not building. V1 ships this shape with `practice` always `null`, so adding bots later is additive rather than a breaking change to the home screen and the challenge flow.

Bot games are still stored in full. The retention goals below — replay, PGN, analysis — apply at least as much to practice games as to friend games; only the record excludes them.

# Game History and Data Retention

Retain enough structured data to reconstruct every game exactly. At minimum store players, colors, result, timestamps, initial position, ordered moves, notation, and the resulting board state or FEN after each move. Prefer immutable move records rather than overwriting history.

This data should be suitable later for:

* Replaying games move by move.  
* Generating PGN.  
* Computing richer player statistics.  
* Running batch ML or statistical analysis over player behavior.  
* Providing automated gameplay critique or recommendations.

# Technical Architecture

## Client

Flutter / Dart, targeting iOS first. Keep platform-specific code minimal so Android can be added later.

## Backend

Go HTTP API hosted on Fly.io. Use a lightweight router or net/http-based structure rather than a large framework. Use WebSockets for active game updates.

## Database

Postgres hosted on Neon. Use normal SQL migrations and a Go Postgres driver such as pgx. Prefer straightforward SQL over a heavy ORM initially.

## Chess Rules

Use a maintained Go chess library for legal move validation, FEN/PGN handling, check/checkmate, castling, en passant, promotion, draw states, and notation.

## Authentication

Flutter obtains a Sign in with Apple identity token and sends it to the Go API. The backend verifies the Apple token, maps it to an internal user, and issues its own short-lived access token plus refresh/session token.

# Suggested Data Model

## users

* id  
* apple\_subject  
* kind — `human` or `bot`; V1 writes only `human`. Bots get real user rows so the game player columns stay non-null and every join, profile lookup, and stat query keeps one shape.  
* username  
* profile\_icon  
* created\_at

## friendships

* requester\_id  
* addressee\_id  
* status  
* created\_at

## sessions

* id  
* user\_id  
* refresh\_token\_hash  
* expires\_at

## games

* id  
* kind — `friend` or `bot`; V1 writes only `friend`  
* white\_player\_id  
* black\_player\_id  
* bot\_level — null for friend games  
* status — `active`, `completed`, or `abandoned`  
* result — null for abandoned games  
* current\_fen  
* move\_sequence  
* last\_move\_at — set at creation and on every committed move; `abandonable_at` derives from it  
* started\_at  
* completed\_at

## active\_games

One row per user per kind, so "one active game of each kind" is a database guarantee rather than application code. A player sits in either `white_player_id` or `black_player_id`, so no single partial unique index on `games` can express the rule.

* user\_id  
* kind  
* game\_id

Primary key `(user_id, kind)`.

## moves

* id  
* game\_id  
* sequence  
* player\_id  
* from\_square  
* to\_square  
* promotion  
* san  
* fen\_after  
* created\_at

# Key API Surface

* POST /auth/apple  
* POST /auth/refresh  
* DELETE /account  
* GET /profile  
* GET /users/{username}  
* POST /friends/requests  
* POST /friends/requests/{id}/accept  
* POST /friends/requests/{id}/decline  
* GET /friends  
* POST /games  
* GET /games/active — returns `{ game, practice }`  
* GET /games/history  
* GET /games/{id}  
* POST /games/{id}/moves  
* POST /games/{id}/resign  
* POST /games/{id}/draw  
* POST /games/{id}/abandon — end a stalled game, no result recorded  
* POST /games/{id}/claim — end a stalled game as a win for the caller  
* GET /games/{id}/ws

# Important Backend Invariants

* A friendship must be accepted before a game against another person can begin. Bot games have no friendship precondition.  
* Neither player may already have another active game of the same kind. A bot game never blocks a friend game, and never makes a player appear busy.  
* Only the player whose turn it is may submit a move.  
* The submitted move must be legal from the server's canonical position.  
* Move insertion and game-state update occur in one database transaction.  
* A move sequence/version check prevents stale or duplicate writes.  
* Only the waiting player may abandon or claim a stalled game, and only once `abandonable_at` has passed. The idle player can move or resign, nothing else — otherwise going quiet becomes a way to void a losing game.  
* Abandoning records no result and leaves `result` null; claiming records a normal win.  
* Stats should be derived from completed games rather than treated as the sole source of truth, and must filter `kind = 'friend'`. Abandoned games are excluded by the `completed` status alone.

# UI Direction

Keep the app visually quiet and fast. The chessboard should dominate the game screen. Use one fixed board and piece style for V1. Avoid dense navigation, advertising, feeds, ratings, and configuration screens.

Suggested primary screens:

* Sign In  
* Initial Profile Setup  
* Home / Active Game  
* Friends  
* Friend Profile / Head-to-Head History  
* Game Board  
* Game History  
* Settings

Two states the visual spec does not yet cover, both consequences of the stalled-game rule: a fourth, neutral result chip for an unfinished game alongside win/loss/draw, and the affordance that offers *end* and *claim win* to the waiting player once a game is stale. The latter belongs in the existing resign confirmation sheet rather than as new chrome on the board.

# Future Add-Ons

* Replay completed games move by move.  
* Play against bots at several Elo ranges, likely using Stockfish through UCI, run server-side. The bot's reply arrives over the same WebSocket as a human's, so client move handling and sequence reconciliation cannot tell the difference. See Game Kinds above and `docs/adr/0002-game-kinds-and-abandonment.md`.  
* Minimal emoji-only reactions or chat.  
* ML/statistical gameplay analysis and personalized critique.  
* More detailed player statistics and trends.  
* Android release.

# V1 Success Criteria

Two friends can install the app, authenticate, add each other, start exactly one active game, exchange moves with low perceived latency, finish the game, and later see the result and full move history. The system should recover cleanly from temporary disconnects without losing or duplicating moves.  
