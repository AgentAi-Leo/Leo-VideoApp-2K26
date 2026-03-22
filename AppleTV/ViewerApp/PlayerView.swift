import SwiftUI
import AVKit
import Combine

/// Full-screen video player using AVQueuePlayer for seamless gapless playback.
/// This is the core of the app — AVQueuePlayer pre-buffers the next item
/// so transitions are sub-frame with zero pipeline teardown.
struct PlayerView: View {
    let playlist: [VideoItem]
    let onExit: () -> Void

    @StateObject private var playerManager = PlayerManager()

    var body: some View {
        ZStack {
            // Full-screen AVPlayer view
            VideoPlayer(player: playerManager.player)
                .ignoresSafeArea()

            // Now Playing overlay (fades out after 4s)
            if playerManager.showingInfo {
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(playerManager.currentTitle)
                                .font(.headline)
                                .foregroundColor(.white)
                            if let creator = playerManager.currentCreator, !creator.isEmpty {
                                Text(creator)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            Text("\(playerManager.currentIndex + 1) of \(playlist.count)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        Spacer()
                    }
                    .padding(40)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: playerManager.showingInfo)
            }
        }
        .onAppear {
            playerManager.loadPlaylist(playlist)
        }
        .onDisappear {
            playerManager.tearDown()
        }
        .onExitCommand {
            // Menu button on Siri Remote → go back to browser
            playerManager.tearDown()
            onExit()
        }
        .onPlayPauseCommand {
            playerManager.togglePlayPause()
        }
    }
}

// MARK: - PlayerManager (AVQueuePlayer orchestrator)

@MainActor
class PlayerManager: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var currentTitle: String = ""
    @Published var currentCreator: String?
    @Published var showingInfo: Bool = false

    private(set) var player: AVQueuePlayer = AVQueuePlayer()
    private var playlist: [VideoItem] = []
    private var cancellables = Set<AnyCancellable>()
    private var infoTimer: Timer?
    private var boundaryObserver: Any?

    /// Load the full playlist into AVQueuePlayer
    func loadPlaylist(_ items: [VideoItem]) {
        playlist = items
        guard !items.isEmpty else { return }

        // Build AVPlayerItems from URLs
        let playerItems = items.compactMap { item -> AVPlayerItem? in
            guard let url = item.mediaURL else { return nil }
            return AVPlayerItem(url: url)
        }

        // Replace queue contents
        player.removeAllItems()
        for item in playerItems {
            if player.canInsert(item, after: nil) {
                player.insert(item, after: nil)
            }
        }

        // Observe when the current item changes (track advancement)
        player.publisher(for: \.currentItem)
            .receive(on: RunLoop.main)
            .sink { [weak self] newItem in
                self?.handleItemChange(newItem)
            }
            .store(in: &cancellables)

        // Start playback
        player.play()
        updateNowPlaying(index: 0)
        flashInfo()
    }

    /// Handle track advancement
    private func handleItemChange(_ newItem: AVPlayerItem?) {
        guard let newItem = newItem else { return }

        // Find which playlist index this corresponds to
        let items = player.items()
        // The current item is at position 0 in the remaining queue
        // Calculate actual playlist index based on how many items have been consumed
        let remainingCount = items.count
        let totalLoaded = playlist.count  // approximate
        let consumed = totalLoaded - remainingCount
        let newIndex = max(0, consumed)

        if newIndex != currentIndex && newIndex < playlist.count {
            currentIndex = newIndex
            updateNowPlaying(index: newIndex)
            flashInfo()
        }
    }

    /// Update the displayed title/creator
    private func updateNowPlaying(index: Int) {
        guard index < playlist.count else { return }
        currentIndex = index
        currentTitle = playlist[index].title
        currentCreator = playlist[index].creator
    }

    /// Briefly show the now-playing info overlay
    private func flashInfo() {
        showingInfo = true
        infoTimer?.invalidate()
        infoTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.showingInfo = false
            }
        }
    }

    func togglePlayPause() {
        if player.rate > 0 {
            player.pause()
        } else {
            player.play()
        }
        flashInfo()
    }

    func skipNext() {
        player.advanceToNextItem()
    }

    func tearDown() {
        player.pause()
        player.removeAllItems()
        cancellables.removeAll()
        infoTimer?.invalidate()
        if let observer = boundaryObserver {
            player.removeTimeObserver(observer)
        }
    }
}
