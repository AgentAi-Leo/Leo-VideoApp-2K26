You've hit on one of the most notoriously frustrating secrets of Apple TV development: AVQueuePlayer promises "seamless gapless playback," but in reality, when feeding it an array of separate remote URLs, it almost always struggles with buffering, black screen flashes, or audio drops between tracks because it fails to pre-load the headers of the next URL fast enough over the network.

To achieve true gapless, TV-broadcast-quality playback on tvOS, we usually have to abandon passing an array of links to the player, and instead do something like:

- **Server-Side HLS Stitching:** Dynamically generating a single master .m3u8 playlist on the backend that stitches the videos together natively, tricking the Apple TV into thinking it's streaming one continuous infinitely-long video.
- **Double-Player Crossfading:** Building a custom swift wrapper that uses two overlapping AVPlayer instances, where Player B silently buffers the next video in the background and instantly swaps to the front layer the exact millisecond Player A finishes.
