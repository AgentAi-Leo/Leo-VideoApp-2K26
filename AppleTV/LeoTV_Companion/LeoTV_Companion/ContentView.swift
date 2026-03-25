import SwiftUI

/// Root view — shows playlist browser or jumps straight to player
struct ContentView: View {
    @State private var playlistService = PlaylistService()
    @State private var isPlaying = false
    @State private var startIndex: Int = 0
    @State private var returnFocusIndex: Int?
    @State private var isMuted: Bool = false

    var body: some View {
        NavigationStack {
            if isPlaying, !playlistService.playlist.isEmpty {
                PlayerView(
                    playlist: playlistService.playlist,
                    startAt: startIndex,
                    isMuted: isMuted,
                    onExit: { lastIndex in 
                        if lastIndex == playlistService.playlist.count - 1 {
                            returnFocusIndex = -1 // Magic integer triggering 'Play All' focus reset
                        } else {
                            returnFocusIndex = lastIndex
                        }
                        isPlaying = false 
                    }
                )
                .ignoresSafeArea()
            } else {
                PlaylistBrowserView(
                    service: playlistService,
                    returnFocusIndex: $returnFocusIndex,
                    onPlay: { index, muted in
                        startIndex = index
                        isMuted = muted
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
