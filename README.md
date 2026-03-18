03.17.26
# VideoApp - v1 - vers-B

ADDS vers-B:
  - Persistent Playlist & About Text
  - Player Cyan 
  - Audio Slide&, Mute & Speed Controller Adjustments
  - Added CLEAR ALL button 
  - Added Loopable Keybinding to Playlist
  - Added Toggle to LOOP PLAYLIST
  - Move Menu to TOP od Screen
  - Video Playback Buttons Larger & Darker Color Cyan
  - NO 13s
  - Remove YouTube TITLE Overlay (Still Broken)
  - Adding 1 second 

A production-ready, single-file mobile video player PWA. No build tools, no dependencies — open the HTML file in any browser and go.

---

## Features:

### Playback
- Supports **YouTube**, **Vimeo**, and direct video files (`.mp4`, `.webm`)
- Autoplay with audio on load (muted-then-unmute trick for browser policy compliance)
- Unified player controls across all three video types
- Playback speed control, seek bar, volume slider, mute toggle
- Double-tap to seek ±10s, swipe left/right for next/prev

### Playlist
- Add an optional **Intro Video** that plays first before the playlist
- Add unlimited videos to the playlist queue
- Drag-and-drop (desktop) and touch-drag (mobile) reordering
- **Auto-fetch titles** from YouTube and Vimeo via oEmbed API — no API key required
  - Paste URL → TAB → title fills in automatically
- Playlist items truncate long titles with ellipsis

### Create Tab
- **PLAYLIST sub-tab** — manage intro video and playlist
- **ABOUT TEXT sub-tab** — write and save About page content
- PREVIEW button launches playback from the top
- About text persists across page reloads via localStorage

### About Tab
- Displays saved About text in a clean, centered read-only view
- Placeholder shown when no text has been saved

### PWA
- Installable to home screen (Add to Home Screen)
- Service worker for offline support
- Inline manifest — no separate files needed
- Custom `+` icon

---

## Usage

1. Open `video-app.html` in a browser (or serve from any static host)
2. Tap **Create** → **PLAYLIST** to add videos
3. Paste a YouTube, Vimeo, or direct URL — TAB to auto-fill the title
4. Hit **PREVIEW** to start playback
5. Tap the player to show/hide controls

---

## Structure

Single self-contained file:

```
video-app.html
├── CSS (design tokens, layout, animations)
├── HTML (app shell, panels, controls)
└── JS (player abstraction, YouTube IFrame API, Vimeo postMessage, drag-and-drop, PWA)
```

---

## Browser Support

Modern browsers (Chrome, Safari, Firefox, Edge). Designed mobile-first; works on desktop.
