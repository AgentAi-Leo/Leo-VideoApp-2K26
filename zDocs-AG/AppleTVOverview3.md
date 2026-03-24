# Xcode Setup & Deployment Guide

## Setting Up the Xcode Project

The simplest approach: **create the Xcode project first**, then drag just the 5 `.swift` files into the project navigator.

When you create a new tvOS project in Xcode (File → New → Project → tvOS → App, name it `LeoTVCompanion`), Xcode auto-generates its own `ContentView.swift` and `LeoTVCompanionApp.swift`. You'd:

1. **Delete** Xcode's auto-generated `ContentView.swift` and `LeoTVCompanionApp.swift`
2. **Drag these 5 files** from Finder into the Xcode project navigator:
   - `LeoTVCompanion.swift`
   - `ContentView.swift`
   - `PlayerView.swift`
   - `PlaylistBrowserView.swift`
   - `PlaylistService.swift`

You **don't** need to drag the whole `LeoTVCompanion/` folder because Xcode creates its own `Assets.xcassets`, `Info.plist`, and project structure. Dragging the whole folder would create conflicts with Xcode's auto-generated assets.

**TL;DR:** Create Xcode project first → delete its 2 boilerplate `.swift` files → drag in our 5 `.swift` files. That's it.

---

## Step-by-step in Xcode

### 1. Build Settings (automatic)
- Xcode should auto-detect everything — no manual config needed since our files use standard SwiftUI + AVKit

### 2. Set your Team
- Xcode → Project → Signing & Capabilities → Team → select your Apple ID
- A free Apple ID works for sideloading (no $99 dev account needed)

### 3. Test on Simulator first
- Top toolbar → select **"Apple TV 4K (tvOS 17)"** simulator as destination
- Hit **⌘R** → the app should launch with the 3 demo videos
- Click "Play All" → verify gapless transitions between Big Buck Bunny → Elephants Dream → Sintel

### 4. Deploy to your real Apple TV
- Apple TV → **Settings → Remotes and Devices → Remote App and Devices** (enables pairing)
- Xcode → **Window → Devices and Simulators** → your Apple TV should appear → Pair it
- Top toolbar → select your Apple TV as destination
- Hit **⌘R** → app installs and launches on your TV

### 5. Connect your real playlists (later)
- Edit `PlaylistService.swift` line 39 — replace `"YOUR_GOOGLE_SHEET_JSON_ENDPOINT_HERE"` with your Google Sheets endpoint
- Re-build and run

That's it! Steps 1-3 should take about 5 minutes. The demo videos will confirm seamless playback works before you connect your real playlist data.
