# Handoff: Mate — Minimal Chess (V1 mobile app)

## Overview

Mate: Minimal Chess is a friends-only, untimed iOS chess app. One active game at a time,
no matchmaking, no ratings, no themes — the board dominates the screen and everything else
gets out of the way.

This bundle contains the **visual design and interaction spec** for V1: nine screens, one
fixed board/piece style, and a single dark theme. Pair it with
`Mate - Minimal Chess - Software Design Doc.md` in this folder, which is the original
engineering doc **with the agreed visual direction folded into it** (see its "UI Direction"
section — that section is now normative, not suggestive).

## About the Design Files

The `.dc.html` files in this bundle are **design references authored in HTML**. They are
prototypes that demonstrate intended look, layout, and behavior. They are **not production
code and should not be ported or copied**.

The target client is **Flutter / Dart, iOS first** (per the design doc). The task is to
**recreate these designs in Flutter** using idiomatic widgets and the app's own structure —
`Container`/`Column`/`Row`/`GridView` etc., a real `ChangeNotifier`/Riverpod/Bloc state
layer, and a maintained chess package for rules. The HTML prototype fakes the server
(random-move opponent, simulated socket latency); the real client talks to the Go API and
WebSocket described in the design doc.

Where the prototype and the design doc disagree on *engineering* (move validation, state
authority, persistence), **the design doc wins**. Where they disagree on *visuals*, the
prototype and the token table below win.

## Fidelity

**High-fidelity.** Colors, typography, spacing, and layout are final for V1 and should be
matched closely. Two deliberate exceptions:

1. **Piece artwork is a placeholder.** The prototype draws pieces with Unicode chess glyphs
   in a serif face. V1 should ship a proper vector piece set (SVG assets, one per
   piece/color). Keep the two-tone silhouette read: solid ink black pieces, bone-white
   pieces with a thin dark outline. Do not use a licensed set from another chess product.
2. **Profile icons** are Unicode glyphs standing in for a fixed set of ~8 designed icons.

## Screens / Views

Nine screens. All are 402 × 874 logical px (iPhone 16 / 15 / 14 Pro class), dark theme only.
Safe-area top inset ≈ 59px, bottom home-indicator inset ≈ 34px.

### 1. Sign In

- **Purpose:** authenticate with Apple.
- **Layout:** full-bleed `#1C201A`. Padding 62/28/48. Vertically centered logo block, CTA
  pinned to the bottom.
- **Logo:** two 60px circles overlapping by 16px — left `#EDEEE7` bg with `#1B221C` knight
  glyph, right `#3A4235` bg with `#EDEEE7` knight glyph, both 34px serif.
- **Wordmark:** "Mate" — 27px/1.15, weight 600, `#EDEEE7`, letter-spacing −0.02em.
  Subhead "MINIMAL CHESS" — 11px mono, weight 500, `rgba(237,238,231,.4)`,
  letter-spacing 0.16em.
- **Tagline:** "Chess with the people you actually know. Nothing else." — 15px/1.45,
  `rgba(237,238,231,.5)`, centered, max 24ch.
- **CTA:** "Sign in with Apple" — 52px tall, radius 14, bg `#EDEEE7`, text `#14170F`
  16px/500. Below it: "Untimed games · one at a time · friends only" — 11px mono,
  `rgba(237,238,231,.35)`, centered.
- **Behavior:** on success → Profile Setup for a new account, Home for a returning one.

### 2. Initial Profile Setup

- **Purpose:** pick a unique username and one icon from a fixed set. Both immutable.
- **Layout:** padding 64/24/18, gap 20, column. Title block, username field, icon grid,
  spacer, CTA. Content must not scroll; the software keyboard is shown only while the
  username field has focus.
- **Title:** "Set up your profile" 22px/600. Sub: "Pick a username and an icon. Both can't
  be changed later." 13px/1.45 `rgba(237,238,231,.45)`.
- **Field:** label "USERNAME" 11px mono/500 `rgba(237,238,231,.4)` letter-spacing 0.06em.
  Input 50px tall, radius 13, bg `rgba(237,238,231,.055)`, border 1px
  `rgba(237,238,231,.14)`, text 16px `#EDEEE7`, padding-x 15. Placeholder "e.g. mira.k".
- **Validation hint** (11px mono, below field): empty → "Lowercase, 3–16 characters"
  `rgba(237,238,231,.35)`; <3 chars → "A bit short"; taken → "Taken"; otherwise
  "Available" in `#B4C4A8`. Whitespace is stripped on input. Server-side uniqueness check
  replaces the prototype's hardcoded "mira.k is taken".
- **Icon grid:** 4 columns, gap 11, square circular cells. Unselected: bg
  `rgba(237,238,231,.07)`, glyph `rgba(237,238,231,.75)`. Selected: bg `#EDEEE7`, glyph
  `#14170F`, plus a 2px `#B4C4A8` outer ring.
- **CTA:** "Continue" 52px, radius 14. Enabled `#B4C4A8` bg / `#14170F` text; disabled
  `rgba(237,238,231,.09)` bg / `rgba(237,238,231,.35)` text. Enabled at ≥3 chars.

### 3. Home / Active Game

- **Purpose:** resume the one active game; challenge a friend if there is none.
- **Layout:** padding 66/20/12, gap 20. Header row, active-game card, friends list.
  Bottom tab bar.
- **Header:** "MATE" 11px mono/500 letter-spacing 0.1em `rgba(237,238,231,.4)` left; own
  username right, same style.
- **Active game card:** bg `rgba(237,238,231,.055)`, border 1px `rgba(237,238,231,.09)`,
  radius 18, padding 15, row, gap 14. Left: 106×106 board thumbnail, radius 4, 8×8 grid of
  equal cells rendering the live position at 10px glyphs. Right column: opponent avatar
  (26px circle, bg `rgba(237,238,231,.1)`) + name 15px/500; turn line 13px/500 in `#B4C4A8`
  ("Your move") or `rgba(237,238,231,.5)` ("<name> is thinking…"); meta line
  "move N · untimed" 11px mono `rgba(237,238,231,.35)`. Whole card taps to the Board.
- **Empty state** (no active game): dashed 1px `rgba(237,238,231,.14)` border, radius 18,
  padding 26/18, bg `rgba(237,238,231,.04)`. "No active game" 15px/500 + "Challenge a
  friend below. One game at a time." 13px/1.4 centered.
- **Friends list:** section label "FRIENDS" 11px mono. Rows 12px vertical padding, 1px
  `rgba(237,238,231,.08)` bottom divider, gap 12: 34px avatar circle, name 14px/500,
  head-to-head "W–L–D vs you" 10px mono `rgba(237,238,231,.35)`, trailing action chip.
- **Action chip:** no active game → "Challenge", bg `rgba(180,196,168,.16)`, text `#B4C4A8`,
  radius 16, padding 7/13. With an active game → "Playing" (that opponent) or "Busy",
  transparent bg, `rgba(237,238,231,.3)` text, non-functional. Tapping a busy chip raises
  the toast "You already have an active game. Finish it first."

### 4. Game Board  ← the primary screen

- **Purpose:** play. The board dominates; chrome is two player strips.
- **Layout:** padding 66/0/40 (board is full-bleed edge to edge). "‹ Home" back link
  (14px `rgba(237,238,231,.55)`, 20px inset) at top. Then a vertically centered column,
  gap 14: opponent strip → board → coordinate row (optional) → own strip.
- **Board:** exactly **402 × 402**, square corners, no radius, no shadow. 8 columns × 8 rows
  of equal cells (50.25px). Cells clip overflow so a glyph can never stretch a rank.
  - Light square `#D9DED0`, dark square `#6E7F63`.
  - Last-move highlight: light `#CFDABB`, dark `#68805B`.
  - Selected piece: 3px inset ring `#B4C4A8`.
  - Legal destination with an enemy piece: 3px inset ring `rgba(27,34,28,.45)`.
  - Legal empty destination: centered 14px dot `rgba(27,34,28,.3)`.
  - Pieces: 41px, black `#1B221C`, white `#F9FAF5` with a 0.9px `rgba(27,34,28,.6)`
    outline, 0 1px 2px drop shadow. Replace with SVG assets sized to ~80% of the cell.
- **Player strips** (20px side inset, gap 11): 36px avatar circle — opponent
  `rgba(237,238,231,.1)` bg / `#EDEEE7` glyph, self `#EDEEE7` bg / `#14170F` glyph — then a
  column: name row 15px/500 `#EDEEE7` followed by a 6px turn dot (`#B4C4A8` when it is that
  player's move, transparent otherwise), and under it the captured-pieces line: the pieces
  that player has taken, 13px serif glyphs, letter-spacing 1px,
  `rgba(237,238,231,.5)`, reserved min-height 14px so the row never reflows.
- **Own strip** also carries the trailing "Resign" chip: 12px text
  `rgba(237,238,231,.62)`, bg `rgba(237,238,231,.09)`, radius 20, padding 9/15.
- **Removed on purpose:** no LIVE/SYNCING pill, no "Your move" text row, no
  "last: e5" line, no move counter on this screen. Turn state is the dot alone.
- **Coordinates row** (behind a flag, off by default): 8-column row under the board,
  a–h, 9px mono `rgba(237,238,231,.35)`.

### 5. Friends

- **Purpose:** add friends, answer requests, browse the list.
- **Layout:** padding 66/20/12, gap 22. Title "Friends" 22px/600. Then: code/add card,
  requests section, friends list. Bottom tab bar.
- **Add card:** bg `rgba(237,238,231,.055)`, radius 16, padding 14, gap 12. Row 1: "YOUR
  CODE" 11px mono `rgba(237,238,231,.4)` / code value 13px mono/500 `#B4C4A8`
  letter-spacing 0.1em (e.g. `SL-4KQ2` — regenerate the prefix for the new name).
  Row 2: input (42px, radius 11, placeholder "Username or code") + "Add" button
  (`#B4C4A8` bg, `#14170F` text, 13px/500, radius 11, padding-x 16).
- **Requests:** label "REQUESTS". Row per request: 34px avatar, name 14px/500, direction
  line 10px mono ("wants to be friends" / "request sent"), then an action. Incoming:
  "Accept" chip (`#B4C4A8` bg, `#14170F`) + "Decline" text link. Outgoing: "Pending" chip
  (`rgba(237,238,231,.07)` bg, `rgba(237,238,231,.4)` text, inert) + "Cancel".
  Accepting moves the person into the friends list and raises the toast
  "<name> is now a friend."
- **Friends list:** label "N FRIENDS", rows identical to Home's.

### 6. Friend Profile / Head-to-Head

- **Purpose:** the shared record with one friend, and their match history.
- **Layout:** padding 66/20/12, gap 22. "‹ Friends" back link, identity row, stat cards,
  head-to-head panel, match list, footer actions.
- **Identity:** 62px avatar circle, name 20px/600, "Friends since <Mon YYYY>" 11px mono
  `rgba(237,238,231,.35)`.
- **Stat cards:** three equal cards, bg `rgba(237,238,231,.055)`, radius 14, padding 13.
  Value 20px/600, label 10px mono `rgba(237,238,231,.35)` letter-spacing 0.06em.
  GAMES / THEIR WINS (`#EDEEE7`) / YOUR WINS (`#B4C4A8`).
- **Head-to-head panel:** bg `rgba(180,196,168,.1)`, border 1px `rgba(180,196,168,.2)`,
  radius 14, padding 14. Label "HEAD TO HEAD" 11px mono `#B4C4A8`. Value 17px/600
  "W – L – D in your favour | in their favour | dead even" — the qualifier must follow the
  actual numbers. Then a 6px bar: your-win share in `#B4C4A8`, remainder
  `rgba(237,238,231,.12)`.
- **Match history:** label, then rows — 26px result chip (radius 8; W:
  `rgba(180,196,168,.22)`/`#B4C4A8`, L: `rgba(201,155,139,.18)`/`#C99B8B`, D:
  `rgba(237,238,231,.1)`/`rgba(237,238,231,.6)`), summary "Won · Checkmate" 13px, date
  10px mono. Row taps into Game Detail.
- **Footer:** primary CTA "Challenge <name>" 48px radius 13 `#B4C4A8`/`#14170F`; when the
  user has an active game it reads "You have an active game", bg `rgba(237,238,231,.08)`,
  text `rgba(237,238,231,.35)`, disabled. Trailing "Remove" text link
  `rgba(237,238,231,.4)`.

### 7. You (own profile)

- Same construction as Friend Profile, minus head-to-head. Identity row uses the inverted
  avatar (`#EDEEE7` bg), record line "3W · 1L · 2D" 11px mono, and a "Settings" text link
  on the right. Stat cards: WINS (`#B4C4A8`) / LOSSES / DRAWS. Then "GAME HISTORY" rows:
  result chip, opponent "vs <name>" 14px, summary "Won · Checkmate · 21 moves" 10px mono,
  date. Bottom tab bar.

### 8. Game Detail

- **Purpose:** read a completed game's notation. Replay is post-V1.
- **Layout:** padding 66/20/12, gap 20. "‹ Back", title "Won vs mira.k" 20px/600, meta
  "Checkmate · 9 moves · 24 Aug 2026" 11px mono, then a scrollable panel: bg
  `rgba(237,238,231,.055)`, radius 14, padding 14, label "MOVES", then rows on a
  `30px 1fr 1fr` grid — number `rgba(237,238,231,.3)`, White SAN, Black SAN, all 13px mono
  `#EDEEE7`. Footer note 11px mono `rgba(237,238,231,.3)`: "Every move is stored with its
  resulting position. Move-by-move replay and analysis land post-V1."
- Move count in the header is derived from the move list — never stored separately.

### 9. Settings

- **Layout:** padding 66/20/12, gap 22. "‹ You", title "Settings" 22px/600, then rows
  (15px vertical padding, 1px `rgba(237,238,231,.08)` divider): "Username" with the value
  right-aligned in 14px mono `rgba(237,238,231,.4)`; "Sign out" with a `›`; "Delete
  account" in `#C99B8B` with a `›`. Note below: "Deleting removes your account, friendships
  and games permanently." 11px mono `rgba(237,238,231,.3)`. Version stamp bottom-centered
  10px mono `rgba(237,238,231,.25)`.
- Both destructive rows need a confirmation sheet in the real app (the prototype skips it).

### Bottom tab bar (Home, Friends, You only)

Top border 1px `rgba(237,238,231,.09)`, bg `#1C201A`, padding 10 top / 30 bottom, three
equal items. Label 12px/500 — active `#EDEEE7`, inactive `rgba(237,238,231,.42)` — with a
5px dot under the active one in `#B4C4A8`. Labels: Play, Friends, You.

### Overlays

- **Resign confirm** — bottom sheet. Scrim `rgba(8,10,7,.66)`, sheet bg `#262B24`,
  radius 22, padding 22, margin 20. Title "Resign this game?" 17px/600; body "<opponent>
  takes the win. The game moves to your history." 13px/1.45 `rgba(237,238,231,.5)`. Two
  48px buttons, radius 13, gap 10: "Keep playing" (`rgba(237,238,231,.09)`/`#EDEEE7`),
  "Resign" (`#C99B8B`/`#20140F`).
- **Result modal** — centered. Scrim `rgba(8,10,7,.72)`, card `#262B24`, radius 22,
  padding 26. 40px serif glyph (♔ win / ♟ draw / ♚ loss), title "You won | Draw | You lost"
  20px/600, sub "<reason> · N moves recorded against <opponent>" 13px/1.45 centered.
  Full-width 48px CTA "Back to home" `#B4C4A8`/`#14170F`. Dismissing clears the active game.
- **Toast** — 20px side inset, 110px from the bottom, bg `#3A4235`, radius 14,
  padding 13/15, text 13px/1.4 `#EDEEE7`, auto-dismiss 2.2s.

## Interactions & Behavior

**Move input (prototype behavior — keep the feel, re-source the truth):**
1. Tap own piece → it gets the `#B4C4A8` ring and every legal destination is marked
   (dot on empty squares, ring on capturable pieces).
2. Tap a marked square → the piece moves, both squares take the last-move highlight, any
   captured piece appends to the mover's captured line, the turn dot flips.
3. Tap a different own piece → selection moves. Tap anywhere else → selection clears.
4. Taps are ignored when it is not your turn or the game is over.

In the real client: render the move optimistically, send it over the WebSocket, and
reconcile against the server's committed move + sequence number. On rejection, roll back to
the canonical position. On reconnect, fetch canonical state and resume from the latest
committed move. The prototype's `latency` tweak (0–1200ms) exists to sanity-check how the
board feels while a move is in flight — target well under 300ms perceived.

**Navigation:** tab bar between Play / Friends / You. Board, Friend Profile, Game Detail,
and Settings are pushed views with a back link; back returns to the pusher, defaulting to
Home. No animations are specified for V1 — use platform-default push/sheet transitions.

**Rules coverage in the prototype:** pseudo-legal movement for all six piece types plus
auto-promotion to queen. It does **not** implement check, checkmate detection, castling,
en passant, stalemate, or draw offers — the real game gets all of that from the server's
chess library. Do not treat the prototype's move generator as a spec.

**Validation:** username stripped of whitespace, 3–16 chars, lowercase, unique
(server-checked). Friend add accepts an exact username or friend code.

**States to design for that the prototype only sketches:** loading (initial fetch,
reconnecting), offline, error toasts on failed move submission, empty friends list, empty
game history.

## State Management

Client state the prototype models, and its real-world source:

| State | Prototype | Real client |
|---|---|---|
| `screen`, `prev`, `tab` | local | router |
| `username`, `icon` | local | `GET /profile` |
| `board` (64 cells), `turn`, `sel`, `legal`, `last` | local | derived from server FEN + local chess lib for highlighting |
| `moves` (SAN list) | local | `GET /games/{id}` + WS appends |
| `capW`, `capB` | local | derived from the move list |
| `active` game | local | `GET /games/active` |
| `syncing`, `thinking` | faked timers | WS connection + turn state |
| `friends`, `requests` | local seed | `GET /friends`, requests endpoints |
| `history` | local seed | `GET /games/history` |
| `result`, `resignOpen`, `toast` | local | local UI + server result |

**Derive, don't store.** Head-to-head records, win/loss/draw counts, and per-game move
counts are all computed from the completed-games list in the prototype, and should be
computed from `games`/`moves` server-side (the design doc says the same: stats derive from
completed games).

## Design Tokens

**Colors**

| Token | Hex | Use |
|---|---|---|
| ground | `#1C201A` | app background, tab bar |
| surface | `rgba(237,238,231,.055)` | cards, stat tiles, inputs |
| surface-raised | `#262B24` | sheets, modals |
| surface-toast | `#3A4235` | toast |
| hairline | `rgba(237,238,231,.08–.09)` | dividers, card borders |
| text-primary | `#EDEEE7` | names, titles, values |
| text-secondary | `rgba(237,238,231,.5)` | body, captured pieces |
| text-tertiary | `rgba(237,238,231,.35)` | mono meta lines |
| text-quaternary | `rgba(237,238,231,.25–.3)` | footnotes, version |
| accent | `#B4C4A8` | turn dot, CTAs, positive stats, active tab dot |
| accent-wash | `rgba(180,196,168,.10–.22)` | challenge chip, h2h panel, W chip |
| danger | `#C99B8B` | resign, delete, loss chip |
| on-accent / on-light | `#14170F` | text on `#B4C4A8` or `#EDEEE7` |
| board-light | `#D9DED0` | light squares |
| board-dark | `#6E7F63` | dark squares |
| board-light-active | `#CFDABB` | last move, light |
| board-dark-active | `#68805B` | last move, dark |
| piece-black | `#1B221C` | black pieces |
| piece-white | `#F9FAF5` | white pieces (0.9px `rgba(27,34,28,.6)` outline) |
| scrim | `rgba(8,10,7,.66)` / `.72` | sheet / modal |

**Typography** — Instrument Sans (UI) and JetBrains Mono (meta, codes, notation).
Substitute the closest faces available in the app if these aren't licensed; keep the
sans/mono split.

| Role | Spec |
|---|---|
| Wordmark | 27px / 600 / −0.02em |
| Screen title | 22px / 600 / −0.01em |
| Section title | 20px / 600 / −0.01em |
| Stat value | 20px / 600 |
| Body | 15px / 1.45 / 400 |
| Row primary | 14–15px / 500 |
| Row secondary | 13px / 400 |
| Button | 15–16px / 500 |
| Meta (mono) | 10–11px / 400 |
| Label (mono) | 11px / 500 / +0.06em, uppercase |
| Notation (mono) | 13px / 400 |
| Board glyph | 41px (board), 13px (captured), 10px (thumbnail) |

**Spacing** — 2 / 3 / 6 / 8 / 10 / 11 / 12 / 14 / 18 / 20 / 22 / 26 px. Screen side
inset 20px (24px on Setup, 28px on Sign In); board is full-bleed.

**Radius** — 0 board · 8 result chip · 11 small input/button · 13 CTA · 14 card/toast ·
16 add card · 18 active-game card · 20 pill · 22 sheet/modal · 50% avatars.

**Shadows** — the board has none (it is full-bleed). Pieces carry
`0 1px 2px rgba(27,34,28,.35)`. No other elevation shadows.

**Hit targets** — every tappable row/chip is ≥44px tall; board squares are 50.25px.

## Assets

Nothing licensed or proprietary is used. To be produced for V1:

- **Piece set** — 12 SVGs (6 pieces × 2 colors), two-tone silhouette style. The prototype's
  Unicode glyphs are placeholders. Do not copy another chess product's artwork.
- **Profile icons** — a fixed set of ~8 designed icons; the prototype uses
  ♞ ♜ ♝ ♛ ♚ ♟ ◆ ● as stand-ins.
- **App icon / wordmark** — the overlapping two-knight lockup on Sign In is a starting
  point, not a final mark.
- Fonts: Instrument Sans + JetBrains Mono (both open-licensed) or the app's own equivalents.

## Files

| File | What it is |
|---|---|
| `Mate - Minimal Chess - Software Design Doc.md` | the engineering doc, with the agreed visual direction merged into its "UI Direction" section |
| `Mate - Prototype.dc.html` | the interactive nine-screen prototype in an iPhone frame — the primary visual reference |
| `Mate - Themes.dc.html` | the theme exploration that led here (turns 1–4); turn 4 option `4b` is the chosen direction |
| `ios-frame.jsx` | the iPhone bezel/status-bar wrapper used by the prototype — presentation scaffolding only, not part of the design |
| `support.js` | runtime for the `.dc.html` files; open either HTML file directly in a browser |

Open `Mate - Prototype.dc.html` in a browser and use the chips above the phone to jump
between screens; the board is playable against a random-move opponent.
