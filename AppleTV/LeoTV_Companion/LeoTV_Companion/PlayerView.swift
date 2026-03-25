import SwiftUI
import AVKit
import Combine

/// Full-screen video player using AVQueuePlayer for seamless gapless playback.
/// This is the core of the app — AVQueuePlayer pre-buffers the next item
/// so transitions are sub-frame with zero pipeline teardown.
struct PlayerView: View {
    let playlist: [VideoItem]
    let startAt: Int
    let onExit: (Int) -> Void

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
            playerManager.onQueueFinished = {
                onExit(playerManager.currentIndex)
            }
            playerManager.loadPlaylist(playlist, startAt: startAt)
        }
        .onDisappear {
            playerManager.tearDown()
        }
        .onExitCommand {
            // Menu button on Siri Remote → go back to browser
            playerManager.tearDown()
            onExit(playerManager.currentIndex)
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
                playerManager.skipToBeginning()
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
    // Mark player as non-observed since AVPlayer isn't Observable-compatible
    @ObservationIgnored private(set) var player = AVPlayer()
    
    var currentIndex: Int = 0
    var currentTitle: String = ""
    var showingInfo: Bool = true
    
    private var playlist: [VideoItem] = []
    
    @ObservationIgnored private var infoTimer: Timer?
    @ObservationIgnored var onQueueFinished: (() -> Void)?

    // MARK: - Load & Start

    func loadPlaylist(_ items: [VideoItem], startAt: Int = 0) {
        playlist = items
        guard .isEmpty == false, startAt < items.count else { return }

        // Boot the manual event-driven loop
        playItem(at: startAt)

        // Hard-wire a NotificationCenter listener to catch the EXACT frame the video fully ends natively
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            // Verify this notification belongs strictly to the video we are currently playing
            guard let item = notification.object as? AVPlayerItem, item == self.player.currentItem else { return }
            self.skipNext()
        }
    }

    // MARK: - Track Management

    private func playItem(at index: Int) {
        // If we ran off the edge of the playlist array, the viewing loop is officially over
        guard index >= 0, index < playlist.count else {
            onQueueFinished?()
            return
        }
        guard let url = playlist[index].mediaURL else { return }
        
        // JIT Memory Allocation: Construct a fresh decoder item exactly when needed
        let freshItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: freshItem)
        
        currentIndex = index
        currentTitle = playlist[index].title
        
        flashInfo()
        player.play()
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
        playItem(at: currentIndex + 1)
    }

    func skipToBeginning() {
        playItem(at: 0)
    }

    func skipPrevious() {
        // If more than 3s into current track, restart it; otherwise precisely go to previous
        let currentTime = player.currentTime().seconds
        if currentTime > 3 {
            player.seek(to: .zero)
            flashInfo()
        } else if currentIndex > 0 {
            playItem(at: currentIndex - 1)
        }
    }

    // MARK: - Cleanup

    func tearDown() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        infoTimer?.invalidate()
    }
}
