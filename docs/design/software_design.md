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
* Multiple simultaneous active games.  
* Timed games or chess clocks.  
* User-uploaded profile images.  
* Board themes, piece themes, or extensive customization.  
* Full text chat.  
* Engine analysis or gameplay coaching.

# Core Product Rules

1\. A user may only start or accept a game with an accepted friend.  
2\. A user may have only one active game at a time.  
3\. Games are untimed in V1, but interactions should feel immediate rather than correspondence-style.  
4\. The server is authoritative for legal moves and canonical game state.  
5\. Completed games and every move are retained permanently unless required to be removed with account deletion.

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
* A player cannot create or accept another game while either player already has an active game.  
* Randomly assign or allow simple selection of White/Black.  
* No time limit or chess clock in V1.  
* Support resign and draw outcomes.  
* Validate all moves on the backend before committing them.  
* Persist the current FEN/state plus the full ordered move history.

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
* white\_player\_id  
* black\_player\_id  
* status  
* result  
* current\_fen  
* move\_sequence  
* started\_at  
* completed\_at

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
* GET /games/active  
* GET /games/history  
* GET /games/{id}  
* POST /games/{id}/moves  
* POST /games/{id}/resign  
* POST /games/{id}/draw  
* GET /games/{id}/ws

# Important Backend Invariants

* A friendship must be accepted before a game can begin.  
* Neither player may already have another active game.  
* Only the player whose turn it is may submit a move.  
* The submitted move must be legal from the server's canonical position.  
* Move insertion and game-state update occur in one database transaction.  
* A move sequence/version check prevents stale or duplicate writes.  
* Stats should be derived from completed games rather than treated as the sole source of truth.

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

# Future Add-Ons

* Replay completed games move by move.  
* Play against bots at several Elo ranges, likely using Stockfish through UCI.  
* Minimal emoji-only reactions or chat.  
* ML/statistical gameplay analysis and personalized critique.  
* More detailed player statistics and trends.  
* Android release.

# V1 Success Criteria

Two friends can install the app, authenticate, add each other, start exactly one active game, exchange moves with low perceived latency, finish the game, and later see the result and full move history. The system should recover cleanly from temporary disconnects without losing or duplicating moves.  
