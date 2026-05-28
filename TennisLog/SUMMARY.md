# TennisLog — What We Built

## Overview
A personal tennis companion app for iPhone and Apple Watch, designed and built from scratch. Tracks sessions, scores matches via voice, and monitors racket/shoe gear health.

---

## Design decisions made

| Topic | Decision |
|---|---|
| Data storage | On-device only (SwiftData, encrypted at rest). No cloud, no accounts. |
| Session start | Manual primary + auto-detect fallback |
| Match format | Standard sets (tiebreak at 6-6) + super tiebreak replaces 3rd set |
| Singles/doubles | Both supported |
| Voice scoring | Two modes — switchable in Settings |
| Shot tracking | FH / BH / Vol–OH winners; FH / BH / Vol–OH errors (net vs out) |
| Serve tracking | First serve %, aces, double faults |
| Restring alert | Hours played **or** time elapsed — whichever comes first |
| Shoe alert | 60-hour replacement threshold |
| Streak | Weekly goal with daily dot tracker |
| Court surface | Hard / Clay per session |
| Indoor/outdoor | Set per season |
| Weather | Auto-pulled from GPS at session time (Phase 2) |
| Opponents | Tracked by name with win/loss record |

---

## App structure

### iPhone — 4 tabs

**Home**
- Greeting with active season context
- Streak card: current streak, best ever, weekly dot grid
- Gear alerts: rackets needing restring, shoes needing replacement
- Last session card: score, opponent, HR, calories, quality rating
- Floating "Start Session" button

**Sessions**
- Filterable list: All / Matches / Practice
- Session detail: health stats, match score, shot breakdown, star rating
- Post-session rating sheet (1–5 stars + notes)

**Gear**
- Rackets: health bar (hours since restring + months elapsed), restring logging
- Shoes: wear bar (hours worn toward 60h limit)
- Add / edit flows for both

**Stats**
- Hours played, session count, win rate
- Win / loss split
- Per-opponent record (W–L)
- Unforced error breakdown: Forehand vs Backhand (net % vs out %)
- First serve %, aces, double faults

### Start Session flow
- Practice or Match toggle
- Opponent picker (create new or select existing)
- Singles / Doubles
- Surface: Hard / Clay
- Racket + shoe selection
- "Start on Watch" or "Start on iPhone"

---

## Apple Watch app

### Score display
- Sets / Games / Point — all visible in one glance
- Your score highlighted in Ace Yellow, opponent in white
- Listening indicator (pulsing dot)

### Voice scoring — Mode A (Full Voice)
Compound commands, hands-free:

| Say | Effect |
|---|---|
| `"point me, ace"` | Your point, ace logged |
| `"point me, forehand winner"` | Your point, FH winner |
| `"point me, backhand winner"` | Your point, BH winner |
| `"point me, volley"` / `"overhead"` | Your point, net play winner |
| `"point me, their error"` | Your point, opponent error |
| `"point them, forehand net"` | Their point, your FH into net |
| `"point them, backhand out"` | Their point, your BH long/wide |
| `"point them, volley error"` | Their point, your net play error |
| `"fault"` | First serve fault → 2nd serve |
| `"double fault"` | Their point, double fault |
| `"undo"` | Revert last point |

### Voice scoring — Mode B (Voice + Tap)
Say the score, then tap the shot type from a grid that appears for 8 seconds:

**You won → 2×2 grid:**
Ace / FH Winner / BH Winner / Vol–OH

**They won → 2×2 + 1 wide:**
FH Net / FH Out / BH Net / BH Out / Vol–OH
(Crown scroll = their winner, voice = double fault)

### Other Watch screens
- **Fault screen** — shows FAULT + "2nd serve", auto-dismisses in 3s
- **Game won** — celebration ring with haptic, shows updated game score
- **Set won** — haptic + set score summary
- **Match over** — final score, syncs to iPhone

---

## Data models (SwiftData)

| Model | Key fields |
|---|---|
| `Season` | Name, start/end date, indoor/outdoor |
| `Session` | Date, type, surface, duration, HR, calories, quality rating, weather |
| `Match` | Format, sets (JSON), win/loss, opponent, points |
| `MatchPoint` | Winner, shot type, error type, serve fault flag, set/game index |
| `Opponent` | Name, win/loss record |
| `Racket` | String, tension, restring date, hour + month limits |
| `Shoe` | Surface, date added, hour limit, hours worn |

---

## Tech stack

- **SwiftUI** — all UI (iOS 17+ / watchOS 10+)
- **SwiftData** — local persistence with data protection encryption
- **SFSpeechRecognizer** — continuous voice recognition on Watch
- **WatchConnectivity** — sends completed match data from Watch → iPhone
- **UserNotifications** — local push alerts for gear thresholds
- **HealthKit** — workout data integration (Phase 2)
- **WeatherKit** — auto weather at session time (Phase 2)
- **XcodeGen** — project file generation from `project.yml`

---

## Design system

| Token | Value | Use |
|---|---|---|
| Ace Yellow | `#C8F731` | Primary accent, your score, CTAs |
| Court Night | `#070B13` | App background |
| Card | `#1C2638` | List rows, info cards |
| Alert Orange | `#FF6835` | Gear warnings |
| Win Green | `#4ADE80` | Wins, good status |
| Loss Red | `#F87171` | Losses |
| Practice Blue | `#60A5FA` | Practice session type |

---

## Still to build (Phase 2)

- HealthKit integration — auto-pull duration / HR / calories from workout
- WeatherKit — auto-fetch conditions at session time
- WatchConnectivity receive side — iPhone saves incoming match data to SwiftData
- Season management UI — create / close / switch seasons
- Settings screen — toggle scoring mode, adjust gear thresholds
- App icon + launch screen
- Name the app (TennisLog is a working title)
