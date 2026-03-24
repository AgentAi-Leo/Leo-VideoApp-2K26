import Foundation
import Observation

/// A single video item in the playlist
struct VideoItem: Identifiable, Codable {
    let id: String
    let playlist: String
    let title: String
    let url: String
    let description: String?
    let timestamp: String?

    /// Convenience: build a valid URL from the string
    var mediaURL: URL? { URL(string: url) }
}

struct PlaylistPayload: Codable {
    let intro: [VideoItem]
    let main: [VideoItem]
    let outro: [VideoItem]
}

/// Fetches playlist data from the published API endpoint
@MainActor
@Observable
class PlaylistService {
    var introVideos: [VideoItem] = []
    var mainVideos: [VideoItem] = []
    var outroVideos: [VideoItem] = []
    
    var isLoading = false
    var errorMessage: String?

    // Group main videos by their playlist name
    var groupedPlaylists: [(name: String, videos: [VideoItem])] {
        let grouped = Dictionary(grouping: mainVideos, by: { $0.playlist })
        return grouped.sorted { $0.key < $1.key }
    }

    // ── CONFIGURE THIS ──
    // Replace with your published Google Apps Script Web App URL
    private let playlistURL = "YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL_HERE"

    func fetchPlaylist() async {
        guard let url = URL(string: playlistURL) else {
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

            let payload = try JSONDecoder().decode(PlaylistPayload.self, from: data)
            introVideos = payload.intro
            mainVideos = payload.main
            outroVideos = payload.outro

        } catch {
            errorMessage = error.localizedDescription
            loadDemoPlaylist()
        }

        isLoading = false
    }

    /// Demo playlist
    private func loadDemoPlaylist() {
        introVideos = []
        mainVideos = [
            VideoItem(id: "demo1", playlist: "MAIN", title: "Sample Video 1", url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", description: "Blender", timestamp: nil),
            VideoItem(id: "demo2", playlist: "MAIN", title: "Sample Video 2", url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", description: "Blender", timestamp: nil)
        ]
        outroVideos = []
    }
}
