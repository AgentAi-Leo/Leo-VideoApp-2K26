#!/bin/bash
# Automatically finds the current directory where this script lives
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "🍏=======================================🍏"
echo "        STARTING LEOTV ENVIRONMENT         "
echo "🍏=======================================🍏"
echo ""

# Force kill any old/ghost Python servers currently occupying port 8080
lsof -ti:8080 | xargs kill -9 2>/dev/null || true
echo "🧹 Cleared Port 8080..."

# Start the python server in the background
python3 "$DIR/leotv_server.py" &
SERVER_PID=$!

# Give the server a split second to boot up
sleep 1

# Open the HTML file natively via the local server to bypass YouTube CORS constraints
open "http://localhost:8080"

echo ""
echo "✅ App Opened in Browser."
echo "✅ Server Running on Port 8080."
echo ""
echo "⚠️ IMPORTANT: Keep this terminal window open while using"
echo "   the Export Apple TV Playlist feature!"
echo ""
echo "   (When you are finished, just exit/close this terminal window to gracefully stop the server)."
echo "========================================="

# Wait holds the terminal open until the user manually closes it, which stops the server
wait $SERVER_PID
