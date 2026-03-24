import SwiftUI

/// Root view — jumps straight to gapless player
struct ContentView: View {
    @State private var playlistService = PlaylistService()
    @State private var activeQueue: [VideoItem] = []
    @State private var isPlaying = false

    var body: some View {
        NavigationStack {
            if isPlaying, !activeQueue.isEmpty {
                PlayerView(
                    playlist: activeQueue,
                    startAt: 0,
                    onExit: { 
                        // End of stream
                        isPlaying = false
                        activeQueue = []
                    }
                )
                .ignoresSafeArea()
            } else if playlistService.isLoading {
                ProgressView("Syncing Playlist...")
            } else {
                // Fallback if empty or failed
                VStack(spacing: 20) {
                    Image(systemName: "tv.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text(playlistService.errorMessage ?? "No videos found in sync.")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Button("Retry Sync") {
                        Task { await fetchAndPlay() }
                    }
                    .padding(.top, 20)
                }
            }
        }
        .task {
            await fetchAndPlay()
        }
    }
    
    private func fetchAndPlay() async {
        await playlistService.fetchPlaylist()
        let unified = playlistService.unifiedPlaylist
        if !unified.isEmpty {
            activeQueue = unified
            isPlaying = true
        }
    }
}
