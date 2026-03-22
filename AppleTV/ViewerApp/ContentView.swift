import SwiftUI

/// Root view — shows playlist browser or jumps straight to player
struct ContentView: View {
    @StateObject private var playlistService = PlaylistService()
    @State private var isPlaying = false

    var body: some View {
        NavigationStack {
            if isPlaying, !playlistService.playlist.isEmpty {
                PlayerView(
                    playlist: playlistService.playlist,
                    onExit: { isPlaying = false }
                )
                .ignoresSafeArea()
            } else {
                PlaylistBrowserView(
                    service: playlistService,
                    onPlay: { isPlaying = true }
                )
            }
        }
        .task {
            await playlistService.fetchPlaylist()
        }
    }
}
