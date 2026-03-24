import SwiftUI
import AVKit
import Combine

/// Full-screen video player using AVQueuePlayer for seamless gapless playback.
/// This is the core of the app — AVQueuePlayer pre-buffers the next item
/// so transitions are sub-frame with zero pipeline teardown.
struct PlayerView: View {
    let playlist: [VideoItem]
    let startAt: Int
    let onExit: () -> Void

    @State private var playerManager = PlayerManager()

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
                            if let desc = playerManager.currentDescription, !desc.isEmpty {
                                Text(desc)
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
            playerManager.loadPlaylist(playlist, startAt: startAt)
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
        .onMoveCommand { direction in
            switch direction {
            case .left:
                playerManager.skipPrevious()
            case .right:
                playerManager.skipNext()
            case .up:
                // Restart entire playlist from beginning (Play All)
                playerManager.rebuildQueue(from: 0)
            default:
                break
            }
        }
    }
}

// MARK: - PlayerManager (AVQueuePlayer orchestrator)

@MainActor
@Observable
class PlayerManager {
    var currentIndex: Int = 0
    var currentTitle: String = ""
    var currentDescription: String?
    var showingInfo: Bool = false

    // Mark player as non-observed since AVQueuePlayer isn't Observable-compatible
    @ObservationIgnored private(set) var player: AVQueuePlayer = AVQueuePlayer()
    @ObservationIgnored private var playlist: [VideoItem] = []
    @ObservationIgnored private var playerItems: [AVPlayerItem] = []
    @ObservationIgnored private var currentItemObserver: NSKeyValueObservation?
    @ObservationIgnored private var infoTimer: Timer?
    @ObservationIgnored private var timeObserver: Any?

    // MARK: - Load & Start

    /// Load the playlist into AVQueuePlayer, optionally starting at a specific index.
    func loadPlaylist(_ items: [VideoItem], startAt: Int = 0) {
        playlist = items
        guard !items.isEmpty else { return }

        // Build AVPlayerItems from URLs (keep a parallel array for index mapping)
        playerItems = items.compactMap { item -> AVPlayerItem? in
            guard let url = item.mediaURL else { return nil }
            return AVPlayerItem(url: url)
        }

        // Replace queue contents — only add items from startAt onwards
        player.removeAllItems()
        let startItems = Array(playerItems.dropFirst(startAt))
        for item in startItems {
            if player.canInsert(item, after: nil) {
                player.insert(item, after: nil)
            }
        }

        // Track which index we're on using KVO (Swift 6 safe)
        currentItemObserver = player.observe(\.currentItem, options: [.new]) { [weak self] _, change in
            Task { @MainActor [weak self] in
                guard let self = self, let newItem = change.newValue as? AVPlayerItem else { return }
                if let idx = self.playerItems.firstIndex(of: newItem) {
                    self.currentIndex = idx
                    self.updateNowPlaying(index: idx)
                    self.flashInfo()
                }
            }
        }

        // Start playback
        currentIndex = startAt
        updateNowPlaying(index: startAt)
        flashInfo()
        player.play()
    }

    // MARK: - Track Management

    /// Update the displayed title/creator
    private func updateNowPlaying(index: Int) {
        guard index < playlist.count else { return }
        currentIndex = index
        currentTitle = playlist[index].title
        currentDescription = playlist[index].description
    }

    /// Briefly show the now-playing info overlay (auto-hides after 4s)
    private func flashInfo() {
        showingInfo = true
        infoTimer?.invalidate()
        infoTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.showingInfo = false
            }
        }
    }

    // MARK: - Playback Controls

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
        flashInfo()
    }

    func skipPrevious() {
        // If more than 3s into current track, restart it; otherwise go to previous
        let currentTime = player.currentTime().seconds
        if currentTime > 3 {
            player.seek(to: .zero)
        } else if currentIndex > 0 {
            // Rebuild the queue from the previous index
            rebuildQueue(from: currentIndex - 1)
        }
        flashInfo()
    }

    /// Rebuild the queue starting from a specific playlist index
    func rebuildQueue(from index: Int) {
        player.pause()
        player.removeAllItems()

        let items = Array(playerItems.dropFirst(index))
        for item in items {
            // Re-create AVPlayerItem because used items can't be re-inserted
            if let url = (item.asset as? AVURLAsset)?.url {
                let freshItem = AVPlayerItem(url: url)
                // Replace in our tracking array too
                if let oldIdx = playerItems.firstIndex(of: item) {
                    playerItems[oldIdx] = freshItem
                }
                if player.canInsert(freshItem, after: nil) {
                    player.insert(freshItem, after: nil)
                }
            }
        }

        currentIndex = index
        updateNowPlaying(index: index)
        player.play()
    }

    // MARK: - Cleanup

    func tearDown() {
        player.pause()
        player.removeAllItems()
        currentItemObserver?.invalidate()
        currentItemObserver = nil
        infoTimer?.invalidate()
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
}
