# Phase 4: Scrollable List Architecture (vers-Q)

## Core Objective
The user requested "pagination" when a playlist exceeds 8 items to prevent the `.card` configurations from infinitely vertically stretching.

## Proposed Architectural Pivot: Scrollable Containers
Because the application utilizes **SortableJS for drag-and-drop reordering**, traditional literal pagination (e.g. Page 1, Page 2, Next) is technically hostile to user experience. If a user needs to drag item #12 to position #2, they cannot practically do it if item #12 is isolated on "Page 2".

**The Best Practice Solution:**
Instead of rigid pagination, we implement a **Fixed-Height Scrollable Container** equipped with a sleek, custom-styled scrollbar.

### Implementation Steps
1. Apply `max-height: 500px;` (approximately 7-8 items depending on screen size) to the `ul.playlist-list` CSS class.
2. Apply `overflow-y: auto;` and `overflow-x: hidden;` to trigger vertical scrolling only when the item ceiling is breached.
3. Design a custom Webkit scrollbar (matching the purple/dark glassmorphism theme) so it renders as a premium, native element rather than a clunky default grey browser scrollbar.
4. Scale all three terminal "Clear" action strings completely natively to `100% width` directly mirroring the volumetric visual weight of the master action nodes.
5. Manually upscale the typography padding arrays across the 3 `.btn--primary` Add parameters so they exactly mimic the external geometrical footprint forced structurally by the integrated `.btn--preview` SVGs.
6. Ensure SortableJS drag-and-drop auto-scrolls the container when pulling a list item toward the top or bottom boundaries.

## User Review Required
> [!IMPORTANT]
> Please review this UX architectural pivot! Do you approve mapping this requirement to a **Scrollable Container** rather than literal pagination, ensuring we perfectly preserve your existing drag-and-drop layout capabilities?

## Verification Plan
### Manual Verification
- Add 10+ items to a playlist to trigger the container overflow threshold.
- Visually inspect the custom scrollbar theming.
- Test drag-and-drop mechanics to ensure automatic boundary scrolling functions natively inside the constrained list.
