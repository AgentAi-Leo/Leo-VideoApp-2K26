# Hover Video Preview Tooltip Plan

## Core Objective
Implement a dynamic 15-second visual preview window that appears when users hover their mouse over items in the Playlist queue or over the active Intro video on the Create tab.

## Proposed Changes

### UI & Styling Updates
- Inject a hidden, floating `div id="hover-preview-container"` globally into the `document.body`.
- Add CSS to absolutely position this container (`position: fixed`, `z-index: 9999`) and fix its dimensions to a clean rectangular aspect ratio (e.g., `width: 240px; height: 135px;`).
- Add glassmorphism or a dark background to the container, with `pointer-events: none` so it elegantly floats under the cursor without disrupting interactive flow.

### Event Tracking & Positioning Logic
- Attach event delegation to `#panel-create` to listen for `mouseenter`, `mousemove`, and `mouseleave` over components matching `.playlist-item` or `#intro-preview`.
- **Mouseenter:** Wait for a short 400ms delay to prevent accidental flashes while scrolling rapidly. Once triggered, capture the embedded URL.
- **Mousemove:** Dynamically update the container's `left` and `top` properties to rigidly trail the cursor coordinates, offsetting slightly down and right (+15px) so the mouse doesn't cover the video. Ensure collision mapping so it never bleeds off-screen.
- **Mouseleave:** Instantly tear down the preview and conceal the container.

### Dynamic Video Payload Resolution
- Map the extracted item URL to its correct rendering payload:
  - **YouTube:** `<iframe src="https://www.youtube.com/embed/[ID]?autoplay=1&mute=1&controls=0&modestbranding=1" ...>`
  - **Vimeo:** `<iframe src="https://player.vimeo.com/video/[ID]?autoplay=1&muted=1&background=1" ...>`
  - **Native (MP4/WEBM):** `<video src="[URL]" autoplay muted loop style="object-fit:cover;">`
- Inject the resolved payload directly into the preview container.

### 15-Second Teardown Circuit
- The moment the payload is injected, start a strict 15-second (`15000ms`) shutdown timer.
- Once 15 seconds collapse, forcibly wipe the floating container's innerHTML (terminating all video streams instantly) and hide the block, exactly fulfilling the 15-second constraint.

## Verification Plan
1. Hover over a YouTube link in the playlist; verify the preview iframe spins up silently and auto-plays.
2. Confirm the floating module cleanly follows mouse coordinates.
3. Keep hovering for 15 seconds; confirm the player forcefully terminates precisely at the time limit.
4. Drag mouse away; verify instantaneous teardown.
