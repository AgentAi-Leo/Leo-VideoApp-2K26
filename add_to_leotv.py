import os
import sys
import argparse
import subprocess
import shutil

# Hardcoded paths to your master reusable skills (as referenced in AI-LLM-Speech2Text)
BASICS_DIR = "/Users/jb3/__JB3_ADDs/004_DOCS/__JB3_DOCs/2025_JB3/___000-Basics"
UPLOAD_DRIVE_SCRIPT = os.path.join(BASICS_DIR, "Data-GoogleDrive", "scripts", "upload_to_drive.py")
APPEND_SHEET_SCRIPT = os.path.join(BASICS_DIR, "Data-GoogleSheet", "scripts", "append_to_sheet.py")

DEFAULT_SHEET_NAME = "LeoTV Master Playlist"
DEFAULT_DRIVE_FOLDER = "LeoTV Media"

def download_video(url, title):
    """Uses yt-dlp to download the highest quality mp4 from YouTube/Vimeo into /tmp/"""
    print(f"\n📥 Downloading highest quality MP4 stream from: {url}")
    
    # We require yt-dlp to be installed
    if not shutil.which("yt-dlp"):
        print("❌ Error: 'yt-dlp' is not installed. Please run: pip install yt-dlp")
        sys.exit(1)
        
    temp_dir = "/tmp/leotv_downloads"
    os.makedirs(temp_dir, exist_ok=True)
    
    # Clean string for file paths
    safe_title = "".join(c for c in title if c.isalnum() or c in (' ', '-', '_')).rstrip()
    output_template = os.path.join(temp_dir, f"{safe_title}.%(ext)s")
    
    cmd = [
        "yt-dlp",
        "-f", "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best",
        "--merge-output-format", "mp4",
        "-o", output_template,
        url
    ]
    
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"❌ yt-dlp download failed:\n{res.stderr}")
        sys.exit(1)
        
    # Find the downloaded file
    # We expect an .mp4 file.
    expected_file = os.path.join(temp_dir, f"{safe_title}.mp4")
    if not os.path.exists(expected_file):
        print(f"❌ Expected downloaded file not found at: {expected_file}")
        sys.exit(1)
        
    print(f"✅ Download complete: {expected_file}")
    return expected_file

def main():
    parser = argparse.ArgumentParser(description="Downloads a video via URL, uploads to Google Drive, and logs to the LeoTV Google Sheet.")
    parser.add_argument("--url", required=True, help="YouTube or Vimeo URL")
    parser.add_argument("--title", required=True, help="Title of the video for the Apple TV")
    parser.add_argument("--playlist", default="MAIN", help="Playlist Name (e.g., INTRO, MAIN, OUTRO). Default: MAIN")
    parser.add_argument("--sheet", default=DEFAULT_SHEET_NAME, help=f"Google Sheet name (Default: {DEFAULT_SHEET_NAME})")
    parser.add_argument("--folder", default=DEFAULT_DRIVE_FOLDER, help=f"Google Drive folder name (Default: {DEFAULT_DRIVE_FOLDER})")
    args = parser.parse_args()

    print(f"🎬 Preparing to ingest '{args.title}' into playlist '{args.playlist}'...")

    # 1. Download Local MP4 via yt-dlp
    local_file = download_video(args.url, args.title)

    # 2. Upload to Google Drive using your master skill script
    print(f"\n☁️ Uploading to Google Drive folder '{args.folder}'...")
    upload_cmd = [sys.executable, UPLOAD_DRIVE_SCRIPT, "--file", local_file, "--folder", args.folder]
    
    upload_res = subprocess.run(upload_cmd, capture_output=True, text=True)
    if upload_res.returncode != 0:
        print(f"❌ Drive upload failed:\n{upload_res.stderr}")
        sys.exit(1)

    drive_link = ""
    for line in upload_res.stderr.splitlines():
        if "Link:" in line:
            drive_link = line.split("Link:", 1)[1].strip()
            
    if not drive_link:
        print(f"⚠️ Warning: Could not parse Drive link from output. Raw stderr:\n{upload_res.stderr}")

    print(f"✅ Upload successful. Permanent Link: {drive_link}")

    # 3. Append to LeoTV Sheet using your master skill script
    print(f"\n📝 Logging permanent gapless link to Google Sheet '{args.sheet}'...")
    data_args = [args.title, "Success", "", drive_link]
    
    sheet_cmd = [
        sys.executable, APPEND_SHEET_SCRIPT, 
        "--title", args.sheet, 
        "--data"
    ] + data_args + [
        "--batch-id", args.playlist.upper()
    ]

    sheet_res = subprocess.run(sheet_cmd, capture_output=True, text=True)
    if sheet_res.returncode != 0:
        print(f"❌ Sheet appending failed:\n{sheet_res.stderr}")
        sys.exit(1)

    print("✅ Successfully added the Video row to Google Sheet!")
    
    # Cleanup local file to save disk space
    os.remove(local_file)
    print("🧹 Cleaned up local downloaded cache.")
    
    print("\n🎉 DONE! The Apple TV App will stream this gapless video the next time it refreshes.")

if __name__ == "__main__":
    main()
