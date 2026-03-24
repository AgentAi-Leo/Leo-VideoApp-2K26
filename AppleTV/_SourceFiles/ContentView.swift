import SwiftUI

/// Root view — shows playlist browser or jumps straight to player
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
                        isPlaying = false
                        activeQueue = []
                    }
                )
                .ignoresSafeArea()
            } else {
                PlaylistBrowserView(
                    service: playlistService,
                    onPlayQueue: { queue in
                        activeQueue = queue
                        isPlaying = true
                    }
                )
            }
        }
        .task {
            await playlistService.fetchPlaylist()
        }
    }
}
