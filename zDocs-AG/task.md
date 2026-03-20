# Video Preview Tooltip Implementation

[x] Design and append the global `preview-tooltip` container to the DOM.
[x] Implement CSS for the floating tooltip (absolute positioning, hidden by default).
[x] Build logic to resolve the media URL into an iframe (YouTube/Vimeo) or native video element payload.
[x] Create mouseenter/mouseleave listeners on playlist items and the intro item.
[x] Implement the mouse tracking logic to tether the tooltip's coordinates to the cursor.
[x] Add the 15-second auto-teardown logic to clear the iframe and explicitly pause/stop the preview after 15 seconds.
