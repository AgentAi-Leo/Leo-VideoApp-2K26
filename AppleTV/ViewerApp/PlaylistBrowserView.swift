import SwiftUI

/// Playlist browser — shows all videos, lets user tap to start playback
struct PlaylistBrowserView: View {
    @ObservedObject var service: PlaylistService
    let onPlay: () -> Void

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

                // Play All button
                Button(action: onPlay) {
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
                            PlaylistRow(
                                item: item,
                                index: index + 1,
                                isSelected: selectedIndex == index
                            )
                            .focused($focusedItem, equals: item.id)
                            .onTapGesture {
                                selectedIndex = index
                                onPlay()
                            }
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

/// Single row in the playlist browser
struct PlaylistRow: View {
    let item: VideoItem
    let index: Int
    let isSelected: Bool

    @Environment(\.isFocused) var isFocused

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

            // Play icon for focused item
            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .opacity(isFocused ? 1 : 0)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isFocused ? Color.white.opacity(0.1) : Color.clear)
        )
        .contentShape(Rectangle())
    }
}
