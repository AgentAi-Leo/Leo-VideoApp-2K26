import os
import sys
import argparse
import subprocess
import shutil
import json

# Master API Scripts
BASICS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Google_Backend")
UPLOAD_DRIVE_SCRIPT = os.path.join(BASICS_DIR, "Data-GoogleDrive", "scripts", "upload_to_drive.py")
APPEND_SHEET_SCRIPT = os.path.join(BASICS_DIR, "Data-GoogleSheet", "scripts", "append_to_sheet.py")

DEFAULT_SHEET_NAME = "LeoTV Master Playlist"
DEFAULT_DRIVE_FOLDER = "LeoTV Media"

def print_banner(text):
    print("\n" + "="*50)
    print(f" {text}")
    print("="*50 + "\n")

def update_progress(pct, msg):
    """Writes the current progress state to a JSON file for the leotv_server to read"""
    try:
        with open(".sync_progress.json", "w") as f:
            json.dump({"pct": pct, "msg": msg}, f)
    except:
        pass

def download_video(url, title):
    """Uses yt-dlp to download the video with realtime terminal progress"""
    print(f"\n📥 [DOWNLOADING] {title}")
    
    if not shutil.which("yt-dlp"):
        print("❌ Error: 'yt-dlp' is not installed. Please run: pip install yt-dlp")
        sys.exit(1)
        
    # CRITICAL: We must download to a persistent folder within the proxy server root! 
    # The HTTP server hosts from the current repository, so AppleTV requires exact internal bounds.
    base_dir = os.path.dirname(os.path.abspath(__file__))
    temp_dir = os.path.join(base_dir, "AppleTV", "_SavedSourceFiles")
    os.makedirs(temp_dir, exist_ok=True)
    
    safe_title = "".join(c for c in title if c.isalnum() or c in (' ', '-', '_')).rstrip()
    if not safe_title:
        safe_title = "video_export"
        
    output_template = os.path.join(temp_dir, f"{safe_title}.%(ext)s")
    
    # We pipe stdout to sys.stdout so the user sees the innate yt-dlp progress bar
    # CRITICAL FALLBACK: We MUST strictly enforce H.264 (avc1) video codecs. 
    # YouTube has started wrapping AV1 (av01) codecs inside .mp4 containers, causing AVPlayer and Finder to instantly crash.
    cmd = [
        "yt-dlp",
        "-f", "bestvideo[vcodec^=avc]+bestaudio[ext=m4a]/bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best",
        "--merge-output-format", "mp4",
        "-o", output_template,
        url
    ]
    
    res = subprocess.run(cmd)
    if res.returncode != 0:
        print(f"❌ yt-dlp download failed!")
        sys.exit(1)
        
    expected_file = os.path.join(temp_dir, f"{safe_title}.mp4")
    if not os.path.exists(expected_file):
        print(f"❌ Expected downloaded file not found at: {expected_file}")
        sys.exit(1)
        
    print(f"✅ Download complete: Size {os.path.getsize(expected_file) / (1024*1024):.1f} MB")
    return expected_file

# Helper to get the Mac's localized IP address for direct Apple TV streaming
def get_local_ip():
    import socket
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "127.0.0.1"

def upload_and_log(local_file, title, playlist_tag, drive_folder, sheet_name, local_link="", clear_sheet=False):
    print(f"\n☁️ [UPLOADING] Pushing to Google Drive ({drive_folder})...")
    upload_cmd = [sys.executable, UPLOAD_DRIVE_SCRIPT, "--file", local_file, "--folder", drive_folder]
    
    # Run the upload, capture output to parse the Drive Link
    upload_res = subprocess.run(upload_cmd, capture_output=True, text=True)
    if upload_res.returncode != 0:
        print(f"❌ Drive upload failed:\n{upload_res.stderr}")
        sys.exit(1)

    drive_link = ""
    for line in upload_res.stderr.splitlines() + upload_res.stdout.splitlines():
        if "Link:" in line:
            drive_link = line.split("Link:", 1)[1].strip()
            
    if not drive_link:
        print(f"⚠️ Warning: Could not parse Drive link. Proceeding anyway.")
        drive_link = "NO_LINK_FOUND"
    else:
        print(f"✅ Upload successful!")

    print(f"\n📝 [LOGGING] Appending to Google Sheet ({sheet_name}) as '{playlist_tag}'...")
    # Injecting local_link into what was previously the empty Transcription slot!
    data_args = [title, "Success", local_link, drive_link]
    
    sheet_cmd = [
        sys.executable, APPEND_SHEET_SCRIPT, 
        "--title", sheet_name, 
        "--data"
    ] + data_args + [
        "--batch-id", playlist_tag
    ]
    
    if clear_sheet:
        sheet_cmd.append("--clear")

    sheet_res = subprocess.run(sheet_cmd, capture_output=True, text=True)
    if sheet_res.returncode != 0:
        print(f"❌ Sheet appending failed:\n{sheet_res.stderr}")
        sys.exit(1)

    print("✅ Successfully appended row!")
    
    # CRITICAL: We can NO LONGER delete the local file!
    # If we delete it, the Apple TV Local Stream Link will 404 crash because the Mac proxy server has no file to stream!
    # os.remove(local_file)
    print("✅ Kept local cache alive for Apple TV Proxy Streaming!")

def main():
    parser = argparse.ArgumentParser(description="Processes a video-app.html JSON export and syncs it to Apple TV storage.")
    parser.add_argument("--file", required=True, help="Path to the apple_tv_sync.json file exported from the web app.")
    args = parser.parse_args()

    if not os.path.exists(args.file):
        print(f"❌ Error: Could not find file {args.file}")
        sys.exit(1)

    with open(args.file, 'r') as f:
        data = json.load(f)

    print_banner(f"LeoTV Apple TV Sync Pipeline")
    
    # Calculate Total Videos for accurate Progress Bar
    categories = ["intro", "main", "outro"]
    total_videos = sum(len(data.get(cat, [])) for cat in categories)
    if total_videos == 0: total_videos = 1
    videos_done = 0
    
    # Custom Naming & Subfolder Logic
    from datetime import datetime
    raw_name = args.file.replace(".json", "")
    if raw_name == "apple_tv_sync":
        stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        master_name = f"LeoTVMedia_{stamp}"
    else:
        master_name = raw_name
        
    master_drive_folder = master_name
    master_sheet_name = f"{master_name} Playlist" # Reverting to unique isolated spreadsheets per user constraint!
    
    update_progress(0, "Starting Sync Pipeline...")

    unknown_tracker = {}
    folder_name_map = {
        "intro": "1-INTRO",
        "main": "2-MAIN",
        "outro": "3-OUTRO"
    }

    is_first_upload = True

    for cat in categories:
        videos = data.get(cat, [])
        if not videos:
            continue
            
        print(f"\n>>> PROCESSING {cat.upper()} PLAYLIST ({len(videos)} videos) <<<")
        for i, vid in enumerate(videos):
            title = vid.get("title", "")
            url = vid.get("url", "")
            
            if not url:
                continue
                
            if not title or title.lower() == "unknown":
                is_unknown = True
            else:
                is_unknown = False

            from urllib.parse import urlparse
            try:
                domain_parts = urlparse(url).netloc.lower().split('.')
                if len(domain_parts) >= 2:
                    if domain_parts[-2] in ('co', 'com', 'org', 'net') and len(domain_parts) >= 3:
                        main_domain = domain_parts[-3]
                    else:
                        main_domain = domain_parts[-2]
                else:
                    main_domain = domain_parts[0]
            except:
                main_domain = "web"
                
            if main_domain == "youtu":
                main_domain = "youtube"
                
            if is_unknown:
                known_count = unknown_tracker.get(main_domain, 0) + 1
                unknown_tracker[main_domain] = known_count
                title = f"Unknown-[{main_domain}]-{known_count}"
            else:
                # Forcefully inject global domain badge so Apple TV Swift can parse YouTube/Vimeo gracefully!
                if f"[{main_domain}]" not in title.lower():
                    title = f"{title} [{main_domain.lower()}]"
                
            base_pct = (videos_done / total_videos) * 100
            step_pct = 100 / total_videos
            
            update_progress(int(base_pct + (step_pct * 0.1)), f"Downloading {title}...")
            local_file = download_video(url, title)
            
            update_progress(int(base_pct + (step_pct * 0.6)), f"Uploading {title} to Drive...")
            
            # Use numbered subfolders to force strict alphabetical sorting in Google Drive
            folder_prefix = folder_name_map.get(cat, cat.upper())
            target_drive_folder = f"{master_drive_folder}/{folder_prefix}"
            
            # Generate localized streaming proxy URL so Apple TV bypasses Google Drive AVPlayer hostility
            import urllib.parse
            filename = os.path.basename(local_file)
            safe_filename = urllib.parse.quote(filename)
            local_http_link = f"http://{get_local_ip()}:8080/AppleTV/_SavedSourceFiles/{safe_filename}"
            
            upload_and_log(local_file, title, cat.upper(), target_drive_folder, master_sheet_name, local_http_link, clear_sheet=is_first_upload)
            is_first_upload = False
            
            videos_done += 1
            update_progress(int((videos_done / total_videos) * 100), f"Finished processing {title}")

    update_progress(100, "Sync Complete!")
    print_banner(f"SYNC COMPLETE! Processed {videos_done} videos.")
    
    # Terminal UI Badges
    from sys import platform
    drive_link = "https://drive.google.com" # Can manually update to exact folder later
    sheet_link = "https://docs.google.com/spreadsheets" # Can manually update to exact sheet later

    # OSC 8 clickable link syntax for modern terminals
    print(f"\n👉 \033]8;;{drive_link}\033\\[\x1b[44m \x1b[37m\x1b[1m📁 OPEN MASTER GOOGLE DRIVE\x1b[0m ]\033]8;;\033\\")
    print(f"👉 \033]8;;{sheet_link}\033\\[\x1b[42m \x1b[37m\x1b[1m📊 OPEN MASTER GOOGLE SHEET\x1b[0m ]\033]8;;\033\\\n")
    print("Your Apple TV is now fully synced and gapless!")

if __name__ == "__main__":
    main()
