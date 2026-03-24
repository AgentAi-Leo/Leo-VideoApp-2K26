> **LeoTV** and **LeoTV_Companion** play user-defined playlists with dedicated **Intro**, **Main**, and **Outro** sections — seamlessly queued for continuous, gapless viewing. Supports video (`.mp4`, `.mov`, `.m4v`, `.m3u8`) and audio (`.mp3`, `.m4a`, `.wav`, `.flac`) up to **4K HDR** on Apple TV. LeoTV streams from any browser; LeoTV_Companion delivers native Siri Remote controls and hardware-accelerated playback on Apple TV 4K. - APPROVED

# Video & Audio Support — LeoTV Apps

## LeoTV (Web App — `video-app.html`)

| Spec | Details |
|------|---------|
| **Player** | HTML5 `<video>` element |
| **Max Resolution** | **4K (3840×2160)** — browser-dependent |
| **HDR** | No |
| **Codecs** | H.264, H.265/HEVC, VP9, AV1 (varies by browser) |
| **AirPlay Limit** | 1080p (Apple protocol cap) |

---

## LeoTV_Companion (tvOS — `AVQueuePlayer`)

| Spec | Details |
|------|---------|
| **Player** | Apple `AVFoundation` / `AVQueuePlayer` |
| **Max Resolution** | **4K (3840×2160) HDR** |
| **HDR** | ✅ HDR10, Dolby Vision |
| **Codecs** | H.264 (AVC) up to 4K, H.265 (HEVC) up to 4K HDR/DV, VP9 (YouTube profile) |
| **Hardware** | Apple TV 4K (3rd gen) — A15 Bionic chip |

---

## Supported File Types

### Video Formats

| Format | Extension | LeoTV (Web) | LeoTV_Companion (tvOS) |
|--------|-----------|:-----------:|:---------------------:|
| MP4 (H.264) | `.mp4` | ✅ | ✅ |
| MP4 (H.265/HEVC) | `.mp4` | ⚠️ Safari only | ✅ |
| MOV (QuickTime) | `.mov` | ⚠️ Safari only | ✅ |
| M4V (iTunes) | `.m4v` | ⚠️ Safari only | ✅ |
| HLS Stream | `.m3u8` | ✅ | ✅ |
| WebM (VP9) | `.webm` | ✅ Chrome/Firefox | ❌ |
| AVI | `.avi` | ❌ | ❌ |
| MKV | `.mkv` | ❌ | ❌ |
| WMV | `.wmv` | ❌ | ❌ |
| FLV | `.flv` | ❌ | ❌ |

> **Best format for both apps:** `.mp4` with H.264 video codec — universal compatibility

### Audio Formats

| Format | Extension | LeoTV (Web) | LeoTV_Companion (tvOS) |
|--------|-----------|:-----------:|:---------------------:|
| MP3 | `.mp3` | ✅ | ✅ |
| AAC | `.aac`, `.m4a` | ✅ | ✅ |
| WAV | `.wav` | ✅ | ✅ |
| FLAC | `.flac` | ✅ | ✅ |
| ALAC (Apple Lossless) | `.m4a` | ✅ Safari | ✅ |
| OGG Vorbis | `.ogg` | ✅ Chrome/Firefox | ❌ |
| AIFF | `.aiff` | ✅ Safari | ✅ |

---

## 🎵 Can We Play Audio-Only Files?

### **Yes!** Both apps can play audio files natively.

**LeoTV (Web):** The HTML5 `<video>` element plays audio files — it just shows a black screen. Works with any direct audio URL (`.mp3`, `.m4a`, `.wav`, etc.).

**LeoTV_Companion (tvOS):** `AVQueuePlayer` handles audio files identically to video — it's a media player, not strictly a video player. Simply put an audio URL in the playlist and it plays seamlessly as part of the queue.

### Streaming Audio Sources

| Source | LeoTV (Web) | LeoTV_Companion (tvOS) | Notes |
|--------|:-----------:|:---------------------:|-------|
| **Direct MP3/M4A URL** | ✅ | ✅ | Best option — paste the direct file URL |
| **SoundCloud** | ⚠️ | ⚠️ | Requires API to extract stream URL (not direct links) |
| **Spotify** | ❌ | ❌ | DRM-protected, no direct streaming |
| **Apple Music** | ❌ | ⚠️ | Requires MusicKit framework on tvOS |
| **YouTube Audio** | ❌ | ❌ | DRM/terms restrictions |
| **Self-hosted files** | ✅ | ✅ | Any HTTPS-hosted audio file works |
| **HLS Audio Stream** | ✅ | ✅ | `.m3u8` audio streams work natively |

> **TL;DR:** If you have a **direct URL** to an audio file (`.mp3`, `.m4a`, `.wav`), both apps play it instantly. SoundCloud requires extracting the stream URL via their API first.

---

## Comparison

| Feature | LeoTV (Web) | LeoTV_Companion (tvOS) |
|---------|-------------|----------------------|
| Max Resolution | 4K | **4K** |
| HDR Support | ❌ | ✅ HDR10 / Dolby Vision |
| Gapless Playback | ❌ (AirPlay flashes) | ✅ Zero-gap via AVQueuePlayer |
| Codec Support | Browser-limited | Native Apple hardware decode |
| Audio Playback | ✅ | ✅ |
| Best For | Desktop/mobile viewing | **TV viewing (best quality)** |

---

## Notes

- The demo sample videos (Big Buck Bunny, Elephants Dream, Sintel) are all **1080p H.264**
- The native tvOS app is the clear winner for quality and seamless playback
- AirPlay from the web app is capped at 1080p regardless of source resolution
- The tvOS app bypasses AirPlay entirely — direct hardware decoding on Apple TV
- **AVI, MKV, WMV, FLV** are not natively supported on any Apple platform — convert to `.mp4 (H.264)` for best compatibility
- Audio files play in both apps without any code changes — just add the URL to the playlist
