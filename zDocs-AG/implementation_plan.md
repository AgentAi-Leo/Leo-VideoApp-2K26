# Multi-Playlist Architecture Overhaul Plan

## Core Objective
Upgrade the single-video "Intro" feature into a fully functional * INTRO PLAYLIST *, and introduce an identical * OUTRO PLAYLIST *. This transforms the app from a [Single Intro -> Main Playlist] sequence into a three-tiered pipeline: [Intro Playlist -> Main Playlist -> Outro Playlist].

## Proposed Changes

### State & Storage Mapping
- **Modify** `State.introVideo` (Object) -> `State.introPlaylist` (Array of objects).
- **Add** `State.outroPlaylist` (Array of objects).
- **Add** LocalStorage keys `vapp_intro_playlist` and `vapp_outro_playlist`.

### Component Duplication (HTML)
- **Intro Card:** Refactor `#intro-card` to match `#playlist-card`. Replace the single-preview block with a dynamic `<ul id="intro-list">` container. Ensure "Add Setup" has its own `Add to Intro Playlist` button.
- **Outro Card:** Duplicate the HTML structure of the `#playlist-card` and place it entirely below the Main Playlist. Give it `<ul id="outro-list">`.
- **Add Form Integrations:** Instead of a single "Set Intro" button overriding the solitary item, transition "Add to Intro" and "Add to Outro" to push objects into their respective state arrays and re-render.

### JavaScript Logic (DOM & Rendering)
- Break out the hardcoded `renderPlaylist()` function into a generic `renderList(array, containerId, templateType)` to allow DRY rendering of the Intro, Main, and Outro lists cleanly.
- Duplicate the `SortableJS` initialization loop to independently attach drag-and-drop mechanics to `#intro-list`, `#playlist-list`, and `#outro-list`.
- Ensure item deletions (`removeItem`) can target the specific array safely (Intro, Main, or Outro).

### Playback Queue Modification
- **Video Player State Machine:** Refactor the `playNextVideo()` iterator. It currently expects `[Intro, Playlist]`. It must be rewritten to sequentially exhaust the arrays:
  1. Iterate through `State.introPlaylist` until end.
  2. Transition to `State.playlist` and iterate until end.
  3. Transition to `State.outroPlaylist` and iterate until end.
  4. Yield EOF or loop the entire super-sequence if `Loop` is enabled.
- Ensure the "PREVIEW / PLAY" button triggers the exact first video in the highest available populated array.

## Verification Plan
### Automated Tests
- Validate DOM arrays inject correctly independently of each other.
### Manual Verification
1. Add 2 videos to Intro, 2 to Main, 2 to Outro. 
2. Play the first video and aggressively skip forward to ensure the state machine perfectly transitions boundary lines sequentially without crashing.
3. Drag and drop items internally within the Outro playlist and verify state persists on reload.
