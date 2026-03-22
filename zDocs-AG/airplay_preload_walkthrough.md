# AirPlay Transition Flash Minimization — Blob Pre-Fetch Cache

## Changes Made
- Added `_blobCache` Map and `_preloadNextBlob()` to `video-app.html`
- `loadVideo()` checks blob cache for local `blob:` URLs before using direct URLs
- Reverted dual-element swap approach (incompatible with AirPlay)
- CORS failures silently fall back to direct URL loading

## Note
CORS restrictions on some hosts may prevent blob pre-fetching. The flash minimization works best with self-hosted or CORS-enabled video URLs.
