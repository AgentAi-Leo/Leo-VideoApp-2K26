# LeoTV-Companion — tvOS Companion App

A minimal tvOS app that plays video playlists **seamlessly** on Apple TV using `AVQueuePlayer`. No AirPlay, no gaps, no screensaver flash.

## Quick Start (Xcode)

### 1. Create the Xcode project
1. Open **Xcode → File → New → Project**
2. Choose **tvOS → App**
3. Settings:
   - Product Name: `LeoTVCompanion`
   - Team: Your Apple ID
   - Organization Identifier: `com.yourname` (anything works)
   - Interface: **SwiftUI**
   - Language: **Swift**
4. Save to: `AppleTV/` folder (overwrite/replace the existing folder)

### 2. Replace the generated source files
Xcode will generate boilerplate files. **Replace them** with the files already in `LeoTVCompanion/`:
- Delete Xcode's auto-generated `ContentView.swift` and `LeoTVCompanion.swift`
- Drag all `.swift` files from this `LeoTVCompanion/` folder into the Xcode project navigator

### 3. Configure your playlist source
Edit `PlaylistService.swift` line 39:
```swift
private let playlistURL = "YOUR_GOOGLE_SHEET_JSON_ENDPOINT_HERE"
```
Replace with your Google Sheets JSON endpoint (see below). Or leave as-is to use the demo playlist for testing.

### 4. Build & Run
1. Connect your Apple TV to Xcode:
   - Apple TV → Settings → Remotes and Devices → Remote App and Devices
   - Xcode → Window → Devices and Simulators → pair your Apple TV
2. Select your Apple TV as the run destination
3. Hit **⌘R** (Build & Run)

## Google Sheets Setup

### Option A: Published Sheet (simplest)
1. Create a Google Sheet with columns: `title | url | creator`
2. Add your video URLs (direct `.mp4` links)
3. File → Share → Publish to web → Select "Sheet1" → Choose "Tab-separated values"
4. Use Google Sheets API v4 endpoint:
```
https://sheets.googleapis.com/v4/spreadsheets/YOUR_SHEET_ID/values/Sheet1?key=YOUR_API_KEY
```

### Option B: Apps Script JSON endpoint
1. Create a Google Sheet with the same columns
2. Extensions → Apps Script → paste:
```javascript
function doGet() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  const data = sheet.getDataRange().getValues();
  const headers = data.shift();
  const items = data.map(row => ({
    title: row[0],
    url: row[1],
    creator: row[2] || ""
  }));
  return ContentService.createTextOutput(JSON.stringify(items))
    .setMimeType(ContentService.MimeType.JSON);
}
```
3. Deploy → New Deployment → Web App → Anyone can access
4. Use the deployment URL as your `playlistURL`

## Files

| File | Purpose |
|------|---------|
| `LeoTVCompanion.swift` | App entry point |
| `ContentView.swift` | Root navigation (browser ↔ player) |
| `PlayerView.swift` | **AVQueuePlayer** — gapless seamless playback |
| `PlaylistBrowserView.swift` | Playlist UI with Siri Remote navigation |
| `PlaylistService.swift` | Fetches playlist from Google Sheets |

## Controls (Siri Remote)
- **Click/Tap** on a video → starts playback from that video
- **Play/Pause** button → toggles playback
- **Menu** button → back to playlist browser
- **Swipe** → standard tvOS scrubbing
