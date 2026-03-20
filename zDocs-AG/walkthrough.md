# Hover Preview Implementation

A dynamic floating 15-second visual preview window has been cleanly integrated for both the Playlist items and the pending Intro video.

## Built Features

- **Global Player Mount:** Created an absolute-tethered `#hover-preview-container` that floats universally on top of all application UI.
- **Debounced Interaction:** Tooltips require a tight `400ms` physical hover intent before spawning to completely prevent layout thrashing and jarring pop-ups if you just sweep your mouse across the list rapidly.
- **Smart Pointer Tracking:** Once the tooltip spans, it continuously monitors your mouse coordinates (`e.clientX`, `e.clientY`), positioning the tooltip `15px` down and to the right of your cursor payload. Real-time viewport bounds collision logic perfectly guarantees the window never bleeds off your monitor edge.
- **URL Payload Inference:** Automatically parses out raw links on the fly using the existing `detectVideoInfo()` logic. Instantiates a mute/autoplay `<iframe>` block if the string represents YouTube or Vimeo, and a silent `<video>` node for everything else.
- **Strict 15-Second Teardown Constraints:** Starts a strict programmatic `15000ms` background timer upon initialization. When the duration hits `0`, it completely rips the video pipeline out of the DOM, killing any active background bandwidth.

## Verification Steps
1. Navigate to the `Add / Edit` screen (HOME > Plus Button).
2. Hover over any pre-loaded item sitting in the **Playlist Queue**, or intentionally hover strictly over the floating `#intro-preview` element in the top form window.
3. Keep the mouse stationary for `400ms` and watch the cinematic tooltip spawn instantly and bind to your cursor position.
4. Keep the tooltip tethered strictly for 15 seconds to observe the programmatic teardown.
5. Exit the hovering target to instantly terminate the container pipeline.
