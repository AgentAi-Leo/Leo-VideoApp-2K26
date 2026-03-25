import os
import sys
import json
import subprocess
from http.server import SimpleHTTPRequestHandler, HTTPServer

# Force execution scope to this project directory, natively overriding macOS `.command` Launcher defaults
os.chdir(os.path.dirname(os.path.abspath(__file__)))

PORT = 8080
CURRENT_SYNC_PROCESS = None

class RequestHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=os.path.dirname(os.path.abspath(__file__)), **kwargs)

    def _send_cors_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')

    def do_OPTIONS(self):
        self.send_response(200)
        self._send_cors_headers()
        self.end_headers()

    def do_GET(self):
        global CURRENT_SYNC_PROCESS
        
        req_path = self.path.split('?')[0]
        
        # 🍎 CORE AVPLAYER BYPASS: Apple TV strictly demands '206 Partial Content' byte-ranges for .mp4 streaming!
        if req_path.startswith('/AppleTV/_SavedSourceFiles/'):
            import urllib.parse
            import mimetypes
            
            # Extract absolute local path
            file_path = urllib.parse.unquote(req_path.lstrip('/'))
            if not os.path.exists(file_path):
                self.send_error(404, "Video payload not found on Mac proxy")
                return

            try:
                file_size = os.path.getsize(file_path)
                content_type, _ = mimetypes.guess_type(file_path)
                if not content_type:
                    content_type = 'video/mp4'

                start = 0
                end = file_size - 1

                # Parse the specific byte range the Apple TV requested
                if 'Range' in self.headers:
                    range_header = self.headers['Range']
                    range_match = range_header.replace('bytes=', '').split('-')
                    
                    start = int(range_match[0]) if range_match[0] else 0
                    if len(range_match) > 1 and range_match[1]:
                        end = int(range_match[1])
                    
                    self.send_response(206)
                    self.send_header('Content-Range', f'bytes {start}-{end}/{file_size}')
                else:
                    self.send_response(200)
                
                chunk_size = (end - start) + 1
                
                self.send_header('Content-Type', content_type)
                self.send_header('Accept-Ranges', 'bytes')
                self.send_header('Content-Length', str(chunk_size))
                self.end_headers()
                
                # Stream tightly packed 5MB micro-chunks to prevent Python server ram crashes
                with open(file_path, 'rb') as f:
                    f.seek(start)
                    bytes_to_read = chunk_size
                    buf_size = 1024 * 1024 * 5
                    
                    while bytes_to_read > 0:
                        read_len = min(bytes_to_read, buf_size)
                        data = f.read(read_len)
                        if not data:
                            break
                        self.wfile.write(data)
                        bytes_to_read -= len(data)
            except BrokenPipeError:
                # Expected when Apple TV seeks timeline rapidly
                pass
            except Exception as e:
                print(f"⚠️ Proxy Stream Interruption: {e}")
            return
            
        if req_path == '/':
            self.path = '/video-app.html'
            return super().do_GET()
        elif req_path == '/status':
            is_running = CURRENT_SYNC_PROCESS is not None and CURRENT_SYNC_PROCESS.poll() is None
            
            pct = 0
            msg = ""
            try:
                if os.path.exists(".sync_progress.json"):
                    with open(".sync_progress.json", "r") as f:
                        data = json.load(f)
                        pct = data.get("pct", 0)
                        msg = data.get("msg", "")
            except:
                pass
                
            if not is_running and CURRENT_SYNC_PROCESS is not None:
                pct = 100
                msg = "Sync Complete!"
                
            self.send_response(200)
            self._send_cors_headers()
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({
                "running": is_running,
                "pct": pct,
                "msg": msg
            }).encode('utf-8'))
            return
        return super().do_GET()

    def do_POST(self):
        global CURRENT_SYNC_PROCESS
        
        req_path = self.path.split('?')[0]
        
        if req_path == '/sync':
            # Block duplicate exports
            if CURRENT_SYNC_PROCESS is not None and CURRENT_SYNC_PROCESS.poll() is None:
                self.send_response(400)
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(b"An export is already natively executing in the terminal!")
                return
                
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)
            
            try:
                payload = json.loads(post_data.decode('utf-8'))
                
                # Extract filename and data payload
                filename = payload.get("filename", "apple_tv_sync")
                if not filename.endswith(".json"):
                    filename += ".json"
                    
                export_data = payload.get("data", {})

                print(f"\n📡 Received TV Sync payload! Saving as '{filename}'...")
                
                # Save JSON
                with open(filename, 'w') as f:
                    json.dump(export_data, f, indent=2)
                    
                # Respond success to browser immediately before starting long downloads
                self.send_response(200)
                self._send_cors_headers()
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"status": "success", "message": "Payload received. Initiating background download!"}).encode('utf-8'))
                
                # Launch the sync_tv.py sequence in the background
                print(f"🚀 Triggering sync_tv.py automatically...")
                CURRENT_SYNC_PROCESS = subprocess.Popen([sys.executable, "sync_tv.py", "--file", filename])

            except Exception as e:
                print(f"❌ Error parsing payload: {e}")
                self.send_response(400)
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(b"Invalid JSON")
        elif req_path == '/cancel':
            if CURRENT_SYNC_PROCESS is not None and CURRENT_SYNC_PROCESS.poll() is None:
                print("🛑 User requested export cancellation. Forcefully terminating sync processor...")
                CURRENT_SYNC_PROCESS.terminate()
                CURRENT_SYNC_PROCESS = None
                self.send_response(200)
                self._send_cors_headers()
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"status": "cancelled"}).encode('utf-8'))
            else:
                self.send_response(400)
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(b"No export is currently running.")
        else:
            self.send_response(404)
            self.end_headers()

def run_server():
    server_address = ('', PORT)
    httpd = HTTPServer(server_address, RequestHandler)
    print(f"🍏 LeoTV Bridge Server actively listening on http://localhost:{PORT}")
    print(f"Keep this window open! Any exports from video-app.html will be instantly processed here.")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print("Server stopped.")

if __name__ == '__main__':
    run_server()
