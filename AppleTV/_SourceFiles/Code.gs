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
    // 🔥 DYNAMIC SHEET HUNTING: Search Google Drive for the absolute newest ' Playlist' sheet!
    var files = DriveApp.searchFiles("mimeType='application/vnd.google-apps.spreadsheet'");
    var newestFile = null;
    var newestTime = 0;
    
    while (files.hasNext()) {
        var file = files.next();
        var name = file.getName();
        if (name.indexOf(" Playlist") !== -1 || name.indexOf("LeoTV") !== -1) {
            var time = file.getDateCreated().getTime();
            if (time > newestTime) {
                newestTime = time;
                newestFile = file;
            }
        }
    }
    
    if (!newestFile) {
        return respondWithJSON([], headers);
    }
    
    // Open the dynamically discovered newest spreadsheet!
    var ss = SpreadsheetApp.openById(newestFile.getId());
    var sheet = ss.getActiveSheet();
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
    
    var allVideos = [];
    
    // Parse data rows (skip header)
    for (var i = 1; i < data.length; i++) {
        var row = data[i];
        
        // Skip failed items and empty rows
        var status = String(row[statusCol] || "");
        if (status.includes("failed") || status.includes("Error") || !row[linkCol]) {
           continue; 
        }
        
        var rawBatchId = String(row[batchIdCol] || "").trim().toUpperCase();
        var category = "MAIN"; // default fallback
        
        if (rawBatchId.endsWith("- INTRO") || rawBatchId === "INTRO") {
            category = "INTRO";
        } else if (rawBatchId.endsWith("- MAIN") || rawBatchId === "MAIN") {
            category = "MAIN";
        } else if (rawBatchId.endsWith("- OUTRO") || rawBatchId === "OUTRO") {
            category = "OUTRO";
        }
        
        var url = String(row[linkCol] || "");
        var localStreamingUrl = String(row[textCol] || "");
        
        // 🍏 Apple TV AVPlayer natively rejects Google Drive byte-ranges. 
        // We injected a gapless Local Area Server proxy URL into the Transcription column!
        // We will prioritize the blazing fast local server, but fallback to Drive.
        if (localStreamingUrl && localStreamingUrl.startsWith("http")) {
            url = localStreamingUrl;
        } else {
            var fileIdMatch = url.match(/\/file\/d\/([a-zA-Z0-9_-]+)/);
            if (fileIdMatch && fileIdMatch[1]) {
                var fileId = fileIdMatch[1];
                url = "https://drive.google.com/uc?export=download&id=" + fileId;
            }
        }
        
        var timestampMs = new Date(row[timeCol] || 0).getTime();
        
        var video = {
            "id": Utilities.getUuid(),
            "title": String(row[titleCol] || "Untitled Video"),
            "url": url,
            "creator": String(row[textCol] || ""),
            "category": category   // CRITICAL BUG FIX: Injecting category so Swift builds headers instead of OTHER
        };
        
        allVideos.push({
            "timestamp": timestampMs,
            "category": category,
            "data": video
        });
    }
    
    if (allVideos.length === 0) {
        return respondWithJSON([], headers);
    }
    
    // Sort all videos chronologically
    allVideos.sort(function(a, b) {
       return a.timestamp - b.timestamp; 
    });
    
    // Group sequentially: INTRO -> MAIN -> OUTRO
    var intro = allVideos.filter(function(v) { return v.category === "INTRO"; }).map(function(v) { return v.data; });
    var main = allVideos.filter(function(v) { return v.category === "MAIN"; }).map(function(v) { return v.data; });
    var outro = allVideos.filter(function(v) { return v.category === "OUTRO"; }).map(function(v) { return v.data; });
    
    // Combine strictly in playback order
    var flatPayload = intro.concat(main).concat(outro);
    
    return respondWithJSON(flatPayload, headers);
    
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
