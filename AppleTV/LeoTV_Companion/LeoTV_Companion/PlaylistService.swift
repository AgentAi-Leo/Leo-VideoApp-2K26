import Foundation
import Observation

/// A single video item in the playlist
struct VideoItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let url: String
    let creator: String?
    let category: String?

    init(id: UUID = UUID(), title: String, url: String, creator: String? = nil, category: String? = nil) {
        self.id = id
        self.title = title
        self.url = url
        self.creator = creator
        self.category = category
    }

    /// Convenience: build a valid URL from the string
    var mediaURL: URL? { URL(string: url) }
}

/// Fetches playlist data from a published Google Sheet (JSON endpoint)
@MainActor
@Observable
class PlaylistService {
    var playlist: [VideoItem] = []
    var isLoading = false
    var errorMessage: String?

    // ── CONFIGURE THIS ──
    // Replace with your published Google Sheet ID.
    // The sheet should have columns: title | url | creator
    // Publish via: File → Share → Publish to web → Sheet1 → TSV
    //
    // Or use the Google Sheets API v4 JSON endpoint:
    // https://sheets.googleapis.com/v4/spreadsheets/{SHEET_ID}/values/Sheet1?key={API_KEY}
    //
    // For simplicity, we support a plain JSON endpoint that returns an array:
    // Dynamically retrieve the Google API deployment URL from the highly secure Secrets.plist bundle natively compiled into the Apple TV hardware
    private var playlistURL: String {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let urlString = plist["PLAYLIST_API_URL"] as? String else {
            fatalError("CRITICAL: Secrets.plist is missing from the Xcode bundle! You must drag the 'Secrets.plist' file directly into Xcode's left sidebar to properly compile the API endpoint. Do not commit your Secrets.plist to Github.")
        }
        return urlString
    }

    func fetchPlaylist() async {
        guard let url = URL(string: playlistURL) else {
            // Fall back to demo playlist if no endpoint configured
            loadDemoPlaylist()
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            // Try decoding as direct JSON array first
            if let items = try? JSONDecoder().decode([VideoItem].self, from: data) {
                playlist = items
            }
            // Try Google Sheets API v4 format: { "values": [["title","url","creator"], ...] }
            else if let sheetsResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let values = sheetsResponse["values"] as? [[String]] {
                // Skip header row
                playlist = values.dropFirst().compactMap { row in
                    guard row.count >= 2, !row[1].isEmpty else { return nil }
                    return VideoItem(
                        title: row[0],
                        url: row[1],
                        creator: row.count > 2 ? row[2] : nil
                    )
                }
            } else {
                throw NSError(domain: "PlaylistService", code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "Unrecognized data format"])
            }

        } catch {
            errorMessage = error.localizedDescription
            loadDemoPlaylist()
        }

        isLoading = false
    }

    /// Demo playlist for testing before Google Sheets is connected
    private func loadDemoPlaylist() {
        playlist = [
            VideoItem(title: "Sample Video 1",
                      url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                      creator: "Blender Foundation"),
            VideoItem(title: "Sample Video 2",
                      url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
                      creator: "Blender Foundation"),
            VideoItem(title: "Sample Video 3",
                      url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
                      creator: "Blender Foundation"),
        ]
    }
}
