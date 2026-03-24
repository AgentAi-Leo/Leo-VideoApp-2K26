# Google Sheets Integration for LeoTV Player (Automated Schema)

## Goal
Simplify the TV ecosystem by limiting the Apple TV to a single `INTRO`, single `MAIN`, and single `OUTRO` continuous playlist. The primary `video-app.html` web workspace will remain unchanged for normal web viewing, but will gain an "Apple TV Compatible" toggle to explicitly push selected web playlists into the TV's permanent Google Drive pipeline.

## Architecture

```
video-app.html (Web) 
   ↓ [User toggles "Sync to Apple TV" & Exports]
Python Script (Reads Export → Downloads YT/Vimeo → Uploads to Drive) 
   ↓ [Appends Log]
Google Sheet 
   ↓ [Apps Script JSON]
LeoTV Player (Fetches gapless direct links)
```

---

## 1. video-app.html Updates (The "Opt-in" Toggle)

The web app remains exactly as it is (using iFrames, oEmbed, etc. for fast web playback). We will inject:
- A hidden toggle labeled: **"🛜 Apple TV Compatible"** (Default: OFF).
- When toggled **ON**, the user can build a single TV-bound playlist.
- A new button: **"Export Apple TV Playlist"**. This will instantly save a small `.txt` or `.json` file containing the URLs and metadata of the `intro`, `main`, and `outro` videos currently on screen.
- **Brand Uniformity UI**: Beneath the export button, we will inject two clickable badges using the exact CSS from your AI-LLM Dashboard (`border-radius:20px; font-weight:600; padding:5px 14px`) pointing to the static Master Google Drive (`#1a73e8` background) and Master Google Sheet (`#0f9d58` background).

## 2. Automated Media Pipeline (Python)

We will update the `add_to_leotv.py` (or `sync_to_tv.py`) script to accept the exported JSON file from the web app natively:
`python3 sync_tv.py --file apple_tv_sync.json`

The script will automatically loop through the exported videos with enriched UX details:
1. **Fetch & Upload (with Progress Bars)**: 
   - Uses `yt-dlp` to download the highest quality `.mp4` video (displaying real-time download % progress in the terminal).
   - Uploads the video file permanently to your chosen storage provider (displaying real-time upload % progress).
2. **Log**: Records the permanent media URLs instantly to the Google Sheet under the exact `Batch ID` tags: `INTRO`, `MAIN`, or `OUTRO`.
3. **Clickable Quick-Links**: At the end of the sync, the script will output clickable quick-link buttons (direct hyperlink URLs in the terminal) pointing exactly to:
   - The specific Google Drive folder where the media was dumped.
   - The specific Google Sheet where the data was logged.

## 3. Google Apps Script & Apple TV

Because we are limiting the TV to a strictly linear `INTRO -> MAIN -> OUTRO` pipeline, everything becomes drastically simpler:
- The TV App no longer needs a "Playlist Browser" screen where the user selects a playlist. 
- When the Apple TV app opens, it fetches the JSON, builds the single gapless AVQueuePlayer queue, and starts playing flawlessly immediately.

### JSON Output Format
```json
{
  "intro": [{"title": "Opening.mp4", "url": "https://[drive_or_s3_url]"}],
  "main": [{"title": "Main Event.mov", "url": "https://[drive_or_s3_url]"}],
  "outro": [{"title": "Credits.mp4", "url": "https://[drive_or_s3_url]"}]
}
```

---

## Verification Plan
1. Add toggle to `video-app.html` and verify it exports the correct URLs.
2. Run the modified Python script against the export file and verify Drive uploads and Sheet population.
3. Remove the Browser UI from Apple TV Swift code so it boots directly into the full-screen gapless player!
