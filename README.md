03.17.26
# VideoApp - v1 - vers-U
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

ADDS vers-C/D:
  - Adding Option: 1.5: Of BLK Between Video Playback
  - All Works and Looks Good

ADDS vers-E
  - Removed Player Controls/Loader While Auto-Playing
  - SEXY AF NOW!

ADDS vers-F
  - Added Full-Screen Toggle To Video Player
  - Can't Remove YouTube Meta Data (Share/Watch Later)

ADDS vers-G
  - Attribution Text To Video Player
  - Added Platofrm Tgs: Youtube, Vimeo, OtherP
  - ALL WORKING AWESOME!!!

ADDS vers-H
  - Support For Google Drive & Dropbox NOT WORKING!

ADDS vers-I
  - REMOVE Support For Google Drive & Dropbox
  - Maybe Add Back Dropbox Support In Future 
  - Refined External Video Site Support
  - WORKS GREAT!!!

ADDS vers-J
  - SHIFT + F = Full Screen Mode
  - SHIFT + M = Mute/Unmute
  - L = Play Forward w/Speed Increase Ability
  - SHIFT L = 1x Playback Speed
  - J = Play Reverse
  - K = Pause
  - , & .  = Frame Advance
  - H = Seek Back 10s
  - ; = Seek Forward 10s
  - Seek Visual Display Added To FWD/REVERSE Skip
  - RIGHT Arrow Key = Next Video
  - LEFT Arrow = Previous Video
  - REMOVED 1.25X Variable Speed Option

ADDS vers-K
  - Smoothed YTube Frame Advances (, & . Keys)
  - Updated Tags To Show Domain Name Instead Of "OTHER"
  - Reducing Double TITLE Displays & Smoothed Out Fades For Cleaner Fade-Ins
  - Updared PLAYLIST Delete X Icons to Really Red!
  - Brightened PLAYLIST Drag Icons 
  - Adding Short Video Previews To Intro Video & Playlist Items
  - Incresaed Size Of Tab Icons
  - Set DEFAULT playback speed to 1x After Selecting "PREVIEW"
  - Repositioned "Copied to Clipboard" To Top Center

ADDS vers-L
  - Renamed PREVIEW button to > PLAY button and Keybinded to UP ARROW
  - Removed Text: "Paste URL then TAB to Autofill TITLE"
  - Removed Text: "Supports YouTube, Vimeo, or direct .mp4/.webm URLs"
  - Updated Text: "Add Video" to "Add Videos To PLAYLIST"
  - Updated Text: "Plays first, before your playlist." To Purple Color
  - Added   Text: "Plays after INTRO VIDEO" To Purple Color
  - Added   Text: ">>> INTRO VIDEO <<<"
  - Added   Text: ">>> Add Videos To PLAYLIST <<<"
  - WORKS AWESOME!!!

  ADDS vers-M
  - Cleaned Up INTRO VIDEO Section
  - ALSO WORKS AWESOME!!!

  ADDS vers-N
  - Upgrading INTRO VIDEO To INTRO PLAYLIST & Adding OUTRO PLAYLIST
  - Updated HOME Icon to WATCH TV Icon
  - Updated PLAYLIST NAMES To "CREATE: INTRO PLAYLIST", "CREATE: MAIN PLAYLIST", "CREATE: OUTRO PLAYLIST"
  - Capitalized Tab Text
  - WORKS AWESOME!!! 

  ADDS vers-O
  - Cleaned Up CREATE UI! Drastically Minimized - VERTICALLY STACKED.
  - WORKS AWESOME!!! 

  ADDS vers-P
  - Cleaned Up CREATE UI! Drastically Minimized - HORIZONTALLY STACKED.
  - Added Step Numbers To CREATE & Cleaned Up Misc UI Text/Tags/Buttons
  - Added Scroll Bars To Playlist Sections  
  - LOOKS & WORKS AWESOME BUT SMALL!!! 

  ADDS vers-Q
   - REAL Q - SMALL BUT AWESOME! 
  
  ADDS vers-R 
   - Everything is AWESOME But VIDEO PLAYLISTS Are Too Small
   - Make Playlist Items Larger
   - LOOKS & WORKS AWESOME - GREAT SIZE (ONLY IN ZEN FIREFOX)!!! 
 
 ADDS vers-S 
   - Added Airplay Support Via Safari But Nasty Unavoidable       Playback Flashing Issues - WILL NEVER WORK SEAMLESSY WITH AIRPLAY SO CREATING NATIVE APP FOR APPLE TV TO SMOOTH PLAYBACK!!!
   - Added Apple TVOS Companion LeoTV_Companion App Using AVQueuePlayer Via Xcode
   - Updated Web App Name To LeoTV And TVos App Name To LeoTV_Companion
   - NOW COMPLETE! AND WORKING!!
   
 ADDS vers-T
  - Building Xcode App - LeoTV_Companion Using SwiftUI - First Xcode/Swift App Ever! 'Grats to Me (2K26)
  - AppleTV Companion App - Now Working Without NASTY FLASHES!!!
  - COMING SOON/NEXT UP:
  - Updated LeoTV And LeoTV_Companion App To Use Google Sheets API For Playlist To Eliminate Flash Issues Caused By Safari When Using Airplay
  - Renamed AppleTV Companion App To LeoTV Player
  - Added Apple TV Icon   
  - LOOKS AND WORKS AWESOME!!! 

 ADDS vers-U (COMING NEXT)
  - Add Google Sheets API Integration For Playlist
  - Add Additional UI Polish & Features
  

   




===================================================

A production-ready, single-file mobile video player PWA. No build tools, no dependencies — open the HTML file in any browser and go.

---

## Features:

### Playback
- Supports major video sites**YouTube**, **Vimeo**, as well as, direct video files via URLs (`.mp4`, `.webm`)
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
