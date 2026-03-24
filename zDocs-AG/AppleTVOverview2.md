# LeoTV_Companion — tvOS App Build Summary

## Project Structure

```
AppleTV/
├── README.md                    ← Setup instructions
├── Package.swift                ← Swift package manifest
└── LeoTV_Companion/
    ├── LeoTV_Companion.swift           ← App entry point
    ├── ContentView.swift        ← Root navigation
    ├── PlayerView.swift         ← ⭐ AVQueuePlayer (gapless playback core)
    ├── PlaylistBrowserView.swift ← Playlist UI for Siri Remote
    ├── PlaylistService.swift    ← Google Sheets fetcher
    ├── Localizable.xcstrings    ← Localization
    └── Assets.xcassets/         ← App icon catalog
```

## What Each File Does

| File | Purpose |
|------|---------|
| `LeoTV_Companion.swift` | SwiftUI `@main` app entry point |
| `ContentView.swift` | Root view — switches between playlist browser and player |
| `PlayerView.swift` | **Core** — `AVQueuePlayer` with gapless transitions, now-playing overlay, Siri Remote support |
| `PlaylistBrowserView.swift` | tvOS-native playlist UI with focus states, Play All button, refresh |
| `PlaylistService.swift` | Fetches playlist from Google Sheets JSON endpoint; falls back to 3 demo videos |

## Features
- **Zero-gap transitions** via `AVQueuePlayer` (pre-buffers next item internally)
- **Now-playing overlay** with title, creator, track number (auto-hides after 4s)
- **Siri Remote**: Play/Pause, Menu to exit, standard tvOS scrubbing
- **Google Sheets as CMS** — no database needed
- **Demo mode** — 3 sample videos (Big Buck Bunny, Elephants Dream, Sintel) work out of the box

## Next Steps to Build

1. **Xcode → File → New → Project → tvOS → App** (SwiftUI, name: `LeoTV_Companion`)
2. Replace generated files with the ones in `AppleTV/LeoTV_Companion/`
3. Build & Run on Apple TV (or tvOS Simulator first)
4. To connect to your playlists: edit `PlaylistService.swift` line 39 with your Google Sheets endpoint

## Controls (Siri Remote)
- **Click/Tap** video → starts playback from that item
- **Play/Pause** → toggles playback
- **Menu** → back to playlist browser
- **Swipe** → standard tvOS scrubbing
