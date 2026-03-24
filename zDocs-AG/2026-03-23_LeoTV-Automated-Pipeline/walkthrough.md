### Phase 3: Horizontal Layout Architecture (vers-P Breakdown)

**1. CSS Grid Transformation:**
- Introduced `.horizontal-playlist-container` encompassing the `Intro Workspace`, `Main Workspace`, and `Outro Workspace`.
- Triggered `display: grid` natively across the container with the responsive `repeat(auto-fit, minmax(320px, 1fr))` constraint mapping to create exactly 3 horizontal columns on desktop displays horizontally.

**2. Component Decoupling & Vertical Workflow Hierarchy:**
- **Step Badges (200% Scaled)**: Replaced legacy ">>>" titles with dynamic linear-gradient numerical tags (1, 2, 3), scaled explicitly by 200%, layered beneath a hollow dark gap parameter (`var(--bg)`) to invoke a native double-circle paradigm globally centered above card topography.
- **Destructive Footer Extractions**: Separated the three destructive clear commands from their inline dependencies. Centralized each into isolated standalone containers pushed deeply downwards with uniform `3rem` layout spacing to minimize workflow misclicks. Renamed primary button to "Clear Main" for global consistency.
- **Bottom-Flush Action Horizon**: Shifted all three primary playlist `.card` wrappers into `flex-direction: column` components, enabling dynamic `margin-top: auto` configurations to forcibly slam the destructive footers flat against the lowest common grid baseline, ensuring absolute horizontal visual symmetry despite uneven list lengths!
- **Toggle Header Architecture**: Gathered configuration toggles (loop, black gap space) onto their own upper boundary within the central card layout to structurally group configuration mechanics away from destruction states.

### Phase 4: Apple TV & Google Sheets Automation

**1. Automated Logging Architecture:**
- Discarded the manual 3-tab Google Sheet idea. Reused the `AI-LLM-Speech2Text` automation logic (`append_to_sheet.py`) so every video processing pipeline automatically writes `Timestamp`, `Batch ID` (Playlist Name), `Original File` (Title), and `Copy Link` (URL) to the master LeoTV Sheet.
- Created `add_to_leotv.py` which takes an `--input` video and `--playlist` name to push a video from your computer directly to Drive and log its data into the Sheet instantly.

**2. Apps Script API (`Code.gs`):**
- Built an Apps Script Web App that reads the automated schema described above.
- Safely processes rows by filtering out failed statuses, sorting chronologically by timestamp, and splitting the data into a clean JSON payload mapping `{"intro": [], "main": [], "outro": []}` logic via `Batch ID`.

**3. Apple TV Code Rewrite:**
- **`PlaylistService.swift`**: Rip-and-replaced the manual array demo with native `URLSession` API polling to fetch the Google Apps Script output.
- **`PlaylistBrowserView.swift`**: Added dynamic `ForEach(service.groupedPlaylists)` rendering to visually cluster videos under their respective `Batch ID` (e.g., MAIN vs FAVORITES).
- **Dynamic Play All Pipeline**: Refactored the `onPlayQueue([VideoItem])` injection to append `[INTRO] + [SELECTED_GROUP] + [OUTRO]` together seamlessly before handing off to the gapless `AVQueuePlayer` engine.

### Next Steps (Your Action Required):
1. **Deploy API**: Open the Master Google Sheet, click Extensions > Apps Script, paste `Code.gs`, and deploy as a Web App (Access: "Anyone").
2. **Wire App**: Copy the Web App URL and paste it into `PlaylistService.swift` on line `36`.
3. **Run App**: Build your `LeoTV_Companion` tvOS app in Xcode to test the live fetch!
