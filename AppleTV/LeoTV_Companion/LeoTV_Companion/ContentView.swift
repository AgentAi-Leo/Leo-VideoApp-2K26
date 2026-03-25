import SwiftUI

/// Root view — shows playlist browser or jumps straight to player
struct ContentView: View {
    @State private var playlistService = PlaylistService()
    @State private var isPlaying = false
    @State private var startIndex: Int = 0
    @State private var returnFocusIndex: Int?

    var body: some View {
        NavigationStack {
            if isPlaying, !playlistService.playlist.isEmpty {
                PlayerView(
                    playlist: playlistService.playlist,
                    startAt: startIndex,
                    onExit: { lastIndex in 
                        returnFocusIndex = lastIndex
                        isPlaying = false 
                    }
                )
                .ignoresSafeArea()
            } else {
                PlaylistBrowserView(
                    service: playlistService,
                    returnFocusIndex: $returnFocusIndex,
                    onPlay: { index in
                        startIndex = index
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
