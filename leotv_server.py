import os
import sys
import json
import subprocess
from http.server import SimpleHTTPRequestHandler, HTTPServer

PORT = 8080
CURRENT_SYNC_PROCESS = None

class RequestHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=os.path.dirname(os.path.abspath(__file__)), **kwargs)

    def _send_cors_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')

    def do_OPTIONS(self):
        self.send_response(200)
        self._send_cors_headers()
        self.end_headers()

    def do_GET(self):
        global CURRENT_SYNC_PROCESS
        if self.path == '/':
            self.path = '/video-app.html'
            return super().do_GET()
        elif self.path == '/status':
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
        if self.path == '/sync':
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
        elif self.path == '/cancel':
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
