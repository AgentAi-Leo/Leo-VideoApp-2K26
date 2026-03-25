03.17.26
# VideoApp - v1 - vers-X
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

 ### NOTE: MASSIVE DISCOVERY - NEW WORKAROUND STRATEGY NEEDED FOR TV COMPANION APP!
 
### MAJOR ISSUE/FLAW: SADLY JUST LEARNED APPLE TV COMPANION APP HAS CHALLENGES OF PLAYBACKING URL PLAYLISTS APPRENTLY - NEED TO IMPLEMENT WORKAROUND SINCE PLAYBACK WILL NOT TECHNICALLY PERFORM AS ORIGINALLY INTENDED FOR SEAMLESS/SMOOTH/GAPLESS PLAYBACK OF URL PLAYLISTS!!! 

ADDS vers-U 
  - Added Command Launcher File (Needed To Open Terminal Window To Run Server)
  - Ensured Any Shared Logic or Styling Is Perfectly Sub-Packaged Into 100% Standalone Project Native Filesystem
  - Working Through Python Data/File Pipeline Logic For Apple TV PLAYLIST Syncing
  - Added Google Sheets API Integration For Playlist
  - Additional Logic, UI Polish & Features Tweaks
  - Added Auto-SyncREFRESH To Initial Launch Logic For Apple TV Playlist
  - Fixed Stuck ON LOADER After Last Video
  - Added JUMP To PLAY ALL After Refresh
  - Added Remember Last Video Upon Exit
  - Fixed Video FreeFrames While Progress Bar Moves
  - Remove Source Video Path From TITLE Display
  = Added New Pro-Tier Pipeline Using Secrets.plist Keep Deployment URL Secure
  - Added Secrets.plist Firewall Rule To .gitignore, Mathematically Preventing That File From Ever Being Uploaded To The Internet
  - Completely Wiped API URL from PlaylistService.swift. The Swift Code Now Dynamically Scans Inside The Apple TV Hardware At Boot To Securely Extract The URL Directly Out Of That Secrets.plist File
  -X7 

  ### NOTE: SUPER CONFUSED NOW AS WE HAVE ENIRELY MOVED AWAY FROM AVQueuePlayer AND NOW BACK TO AVPlayer FOR SEAMLESS PLAYBACK WITHOUT GLITCHES - WTF SERIOUSLY???!!!
 
### REGARDLESS IS WORKING GREAT AND SEAMLESS - FRUSTRATED I NEVER KEPT AVQueuePlayer VERS ISOLATED BEFORE IT WAS CHANGED HERE AS IT TOOKS HOURS TO GET IT WORKING RIGHT. WELL THAT'S IN PAST AS WE NOW MOVE FORWARD - WILL FIX MINOR ANNOYANCES ALONG WITH OTHER UI DETAILS IN NEXT UPDATE!

*** WOW!!! *** PER GEMINI 3.1 PRO - I totally understand the frustration of losing an architecture that you spent literally hours dialing in to perfection. When you spend that much time getting complex systems to integrate, it feels incredibly jarring to just completely overwrite it!

To give you 100% peace of mind, I just officially resurrected your AVQueuePlayer code footprint.

I generated your requested _AVQueuePlayeVSAVPlayer.md
 file perfectly inside your zDocs-JBs directory.

I tracked down the exact Git commit snapshot holding your flawless AVQueuePlayer engine from an hour ago.
I used that snapshot to automatically generate a brand new, isolated Git Branch called _Archive-AVQueuePlayer-Vers-U.
I securely locked and pushed that branch straight to GitHub.
That code is no longer "in the past"—it is fully isolated, archived, and permanently protected inside your Git timeline. If you ever hit a major wall with version V, you now have a hardcoded backup branch sitting safely on your hard drive to fall back on.

I'm ready to tackle your minor UI annoyances whenever you are! Let me know what you want to knock out first for version V.

## vers-U --->IS SURPRISINGLY WORKING REALLY GREAT NOW - NO MORE FLASHING - NO MORE STUTTERING - NO MORE GLITCHES - JUST PURE SEAMLESS PLAYBACK!!! GUESS SINCE WE ARE PLAYING ACTUAL FILES FROM HARD DRIVE THIS APPROACH IS SUDDENLY THE BEST METHOD!

  
ADDS vers-V 
- Fix Various Playback Logic And Improved UI Details/Issues 
- Added Global AUDIO ON/OFF Functionality
- WORKS REALLY GREAT BUT WANT TO IMPOROVE USER EXPERIENCE AND FIX MINOR ISSUES!


## ----
ADDS vers-W
- Improve UI/UX Navigation To Round Trip Seamlessly Up/Down
- Added "Return To Top" Button + Navigate Between PLAY ALL/REFRESH/AUDIO

ADDS vers-X
- More UI/UX Navigation Improvements - Press RIGHT In MAIN MENUAlways Navigates To PRESS ALL/REFRESH/AUDIO No Matter Where You Are In The Menu











  





   
















===================================================

Production-ready, single-file mobile video player PWA. No build tools, no dependencies — open the HTML file in any browser and go.

===================================================
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
