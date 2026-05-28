# TennisLog — iOS & Apple Watch App

Track tennis sessions, score matches via voice, monitor racket restringing and shoe wear.

## Requirements

- Xcode 15+
- iOS 17+ deployment target
- watchOS 10+ deployment target
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the `.xcodeproj`

## Setup

```bash
# Install XcodeGen if needed
brew install xcodegen

# Generate the Xcode project
cd TennisLog
xcodegen generate

# Open in Xcode
open TennisLog.xcodeproj
```

Then in Xcode:
1. Set your **Team** in both target Signing & Capabilities tabs
2. Replace `com.yourname` in `project.yml` with your actual bundle ID prefix
3. Run on a real device (HealthKit + Speech don't work in Simulator)

## Project structure

```
TennisLog/
├── Shared/                   # Code shared by iOS + watchOS
│   ├── Models/Enums.swift    # All shared enums (SessionType, ShotType, etc.)
│   └── Extensions/           # Color theme, Date helpers
│
├── TennisLog/                # iOS app
│   ├── App/                  # Entry point, tab navigation
│   ├── Models/               # SwiftData models
│   ├── Views/
│   │   ├── Home/             # Dashboard, streak, alerts
│   │   ├── Sessions/         # Session list, start flow, post-match rating
│   │   ├── Gear/             # Racket + shoe tracking
│   │   └── Stats/            # Season stats, error breakdown, opponents
│   └── Services/             # Notifications
│
└── TennisLogWatch/           # Apple Watch app
    ├── App/                  # Watch entry point + root view
    ├── Views/                # Score display, shot-type selector, fault, game-end
    └── Services/             # MatchStateManager, VoiceScoringEngine, WatchConnectivity
```

## Voice commands (Watch)

| Command | Effect |
|---|---|
| `"point me"` | Your point (tap mode: shot grid appears) |
| `"point them"` | Their point (tap mode: error grid appears) |
| `"point me, forehand winner"` | Full-voice mode: records FH winner |
| `"point them, backhand net"` | Full-voice mode: records your BH net error |
| `"fault"` | First serve fault → 2nd serve |
| `"double fault"` | Their point, double fault |
| `"undo"` | Revert last point |

Switch between modes in iPhone Settings tab.
