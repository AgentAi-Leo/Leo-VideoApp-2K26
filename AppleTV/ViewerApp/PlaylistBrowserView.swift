import SwiftUI

/// Playlist browser — shows all videos, lets user tap to start playback
struct PlaylistBrowserView: View {
    @ObservedObject var service: PlaylistService
    let onPlay: (Int) -> Void    // passes the selected index

    @State private var selectedIndex: Int = 0
    @FocusState private var focusedItem: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Viewer App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("\(service.playlist.count) videos")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()

                // Refresh button
                Button(action: {
                    Task { await service.fetchPlaylist() }
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .font(.callout)
                }

                // Play All button (starts from index 0)
                Button(action: { onPlay(0) }) {
                    Label("Play All", systemImage: "play.fill")
                        .font(.callout)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            .padding(.horizontal, 60)
            .padding(.top, 40)
            .padding(.bottom, 20)

            // Loading state
            if service.isLoading {
                Spacer()
                ProgressView("Loading playlist…")
                    .progressViewStyle(.circular)
                    .foregroundColor(.gray)
                Spacer()
            }
            // Error state
            else if let error = service.errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.yellow)
                    Text("Could not load playlist")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Text("Using demo videos instead")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            // Playlist
            else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(service.playlist.enumerated()), id: \.element.id) { index, item in
                            Button(action: {
                                selectedIndex = index
                                onPlay(index)
                            }) {
                                PlaylistRow(
                                    item: item,
                                    index: index + 1,
                                    isSelected: selectedIndex == index
                                )
                            }
                            .buttonStyle(PlaylistRowButtonStyle())
                        }
                    }
                    .padding(.horizontal, 60)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.black)
    }
}

// MARK: - Playlist Row

/// Single row in the playlist browser
struct PlaylistRow: View {
    let item: VideoItem
    let index: Int
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Track number
            Text("\(index)")
                .font(.title3.monospacedDigit())
                .foregroundColor(.gray)
                .frame(width: 40, alignment: .trailing)

            // Title + creator
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(1)

                if let creator = item.creator, !creator.isEmpty {
                    Text(creator)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Play icon
            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 24)
    }
}

// MARK: - Custom Button Style for tvOS Focus

/// Custom button style that handles tvOS focus highlighting correctly
struct PlaylistRowButtonStyle: ButtonStyle {
    @Environment(\.isFocused) var isFocused

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isFocused ? Color.white.opacity(0.15) : Color.clear)
            )
            .scaleEffect(isFocused ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}
