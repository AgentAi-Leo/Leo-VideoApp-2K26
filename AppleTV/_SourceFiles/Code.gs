// LeoTV Google Sheets Playlist API (Code.gs)
//
// HOW TO DEPLOY:
// 1. Open your LeoTV Master Playlist in Google Sheets
// 2. Click Extensions > Apps Script
// 3. Paste this code into Code.gs
// 4. Click Deploy > New Deployment
// 5. Select type: Web App
// 6. Execute as: Me
// 7. Who has access: Anyone
// 8. Copy the Web App URL and provide it to the tvOS app

function doGet(e) {
  // Always set CORS headers
  var headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET",
    "Access-Control-Allow-Headers": "Content-Type",
    "Cache-Control": "no-cache"
  };
  
  try {
    var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    var data = sheet.getDataRange().getValues();
    
    // Safety check: is it an empty sheet?
    if (data.length <= 1) {
      return respondWithJSON({"intro": [], "main": [], "outro": []}, headers);
    }
    
    var headersRow = data[0];
    
    // Find column indices by header name (graceful fallback to A/D/E/I if changed)
    var batchIdCol = headersRow.indexOf("Batch ID");
    var titleCol = headersRow.indexOf("Original File");
    var statusCol = headersRow.indexOf("Status");
    var linkCol = headersRow.indexOf("Copy Link");
    var timeCol = headersRow.indexOf("Timestamp");
    var textCol = headersRow.indexOf("Transcription");
    var driveCol = headersRow.indexOf("Google Drive Folder"); // Alternative playlist name
    
    // Set default zero-based indices if exact header match fails
    if (batchIdCol === -1) batchIdCol = 0;   // Col A
    if (timeCol === -1) timeCol = 2;         // Col C
    if (titleCol === -1) titleCol = 3;       // Col D
    if (statusCol === -1) statusCol = 4;     // Col E
    if (textCol === -1) textCol = 5;         // Col F
    if (linkCol === -1) linkCol = 8;         // Col I
    
    var payload = {
      "intro": [],
      "main": [],
      "outro": []
    };
    
    var rows = [];
    
    // Parse data rows (skip header)
    for (var i = 1; i < data.length; i++) {
        var row = data[i];
        
        // Skip failed items and empty rows
        var status = String(row[statusCol] || "");
        if (status.includes("failed") || status.includes("Error") || !row[linkCol]) {
           continue; 
        }
        
        // Determine Playlist Name (Batch ID -> Drive Folder -> "Default")
        var playlistName = String(row[batchIdCol] || "").trim();
        if (!playlistName && driveCol !== -1) {
            playlistName = String(row[driveCol] || "").trim();
        }
        if (!playlistName) {
            playlistName = "Default";
        }
        
        // Use Copy Link, fallback to Preview formula match if necessary
        var url = String(row[linkCol] || "");
        
        // Build video object
        var video = {
            "id": "vid_" + i,
            "playlist": playlistName,
            "title": String(row[titleCol] || "Untitled Video"),
            "url": url,
            "description": String(row[textCol] || ""),
            "timestamp": String(row[timeCol] || new Date().toISOString())
        };
        
        rows.push({
            "timestamp": new Date(row[timeCol] || 0).getTime(), // Used for sorting
            "data": video
        });
    }
    
    // Sort oldest to newest
    rows.sort(function(a, b) {
       return a.timestamp - b.timestamp; 
    });
    
    // Distribute into JSON structure
    for (var j = 0; j < rows.length; j++) {
        var v = rows[j].data;
        var pName = v.playlist.toUpperCase();
        
        if (pName === "INTRO") {
            payload.intro.push(v);
        } else if (pName === "OUTRO") {
            payload.outro.push(v);
        } else {
            payload.main.push(v);
        }
    }
    
    return respondWithJSON(payload, headers);
    
  } catch(error) {
    return respondWithError(error.toString(), headers);
  }
}

function respondWithJSON(object, headers) {
  var output = ContentService.createTextOutput(JSON.stringify(object));
  output.setMimeType(ContentService.MimeType.JSON);
  
  // Note: ContentService handles headers implicitly behind Google's redirect proxy,
  // but keeping them structurally makes it easier if ported.
  return output;
}

function respondWithError(message, headers) {
  var output = ContentService.createTextOutput(JSON.stringify({"error": message}));
  output.setMimeType(ContentService.MimeType.JSON);
  return output;
}
