# Phase 5: Playlist Legibility Scaling (vers-R)

## Core Objective
The user requested a massive 125% legibility increase for the individual video items rendering inside the playlist cards.

## Architectural Options & Recommendation

**Option A: Scale the Entire Card by 125%**
*Pros:* Preserves exact relative proportions of all elements inside the card.
*Cons:* A 25% wider card across 3 columns will severely crowd the layout. On many 1080p and 1440p screens, it will violently break the 3-column grid and force the Outro playlist onto a second row, instantly destroying the beautiful side-by-side workflow we just built.

**Option B: Scale ONLY the Playlist Items (Highly Recommended)**
*Pros:* Keeps the primary 3-column UI structure fully intact, while strictly targeting the hard-to-read elements. We increase the thumbnail size, bump the title typography dramatically (a massive legibility boost), and thicken the internal padding.
*Cons:* The playlist scroll area will hold slightly fewer videos before scrolling kicks in (e.g. ~5 instead of 7). But since we just perfected that scrollbar mechanism in Phase 4, scrolling is fully native and elegant.

## Proposed Changes (Targeting Option B)
1. **Thumbnails:** Scale up from `50x28` to `72x40` (a ~144% scale).
2. **Typography:** Elevate the primary video title font sizes from `0.85rem` up to `1.05rem` natively.
3. **Container Padding:** Expand `.playlist-item` vertical padding blocks from `10px` to `16px`.
4. **Interactive Vectors:** Scale the internal drag handle and delete icons to maintain touch-target proportionality against the larger text.

## User Review Required
> [!IMPORTANT]
> Please review the architectural options above. Do you agree with **Option B** to scale up exclusively the interior playlist items without breaking the rigid 3-column master card boundaries?
