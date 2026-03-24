import SwiftUI

/// Playlist browser — shows all videos, lets user tap to start playback
struct PlaylistBrowserView: View {
    var service: PlaylistService
    let onPlayQueue: ([VideoItem]) -> Void

    @FocusState private var focusedItem: String?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("LeoTV").font(.largeTitle).fontWeight(.bold).foregroundColor(.white)
                    Text("\(service.mainVideos.count) videos available")
                        .font(.subheadline).foregroundColor(.gray)
                }
                Spacer()
                Button(action: { Task { await service.fetchPlaylist() } }) {
                    Label("Refresh", systemImage: "arrow.clockwise").font(.callout)
                }
            }
            .padding(.horizontal, 60).padding(.top, 40).padding(.bottom, 20)

            if service.isLoading {
                Spacer()
                ProgressView("Loading playlist…").foregroundColor(.gray)
                Spacer()
            } else if let error = service.errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle").font(.system(size: 48)).foregroundColor(.yellow)
                    Text("Could not load playlist").font(.headline)
                    Text(error).font(.caption).foregroundColor(.gray)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 60) {
                        ForEach(service.groupedPlaylists, id: \.name) { group in
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text(group.name).font(.title2).fontWeight(.bold).foregroundColor(.white)
                                    Spacer()
                                    Button(action: {
                                        // Play All: Intro -> Section -> Outro
                                        let fullQueue = service.introVideos + group.videos + service.outroVideos
                                        onPlayQueue(fullQueue)
                                    }) {
                                        Label("Play All", systemImage: "play.fill")
                                            .padding(.horizontal, 10).padding(.vertical, 4)
                                    }
                                    .buttonStyle(.borderedProminent).tint(.blue)
                                }
                                
                                VStack(spacing: 8) {
                                    ForEach(Array(group.videos.enumerated()), id: \.element.id) { index, item in
                                        Button(action: {
                                            // Play Single Video directly bypassing Intro/Outro
                                            onPlayQueue([item])
                                        }) {
                                            PlaylistRow(item: item, index: index + 1)
                                        }
                                        .buttonStyle(PlaylistRowButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 60).padding(.bottom, 60)
                }
            }
        }
        .background(Color.black)
    }
}

struct PlaylistRow: View {
    let item: VideoItem
    let index: Int
    var body: some View {
        HStack(spacing: 16) {
            Text("\(index)").font(.title3.monospacedDigit()).foregroundColor(.gray).frame(width: 40, alignment: .trailing)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title).font(.body).foregroundColor(.white).lineLimit(1)
                if let desc = item.description, !desc.isEmpty {
                    Text(desc).font(.caption).foregroundColor(.gray).lineLimit(1)
                }
            }
            Spacer()
            Image(systemName: "play.circle.fill").font(.title2).foregroundColor(.blue)
        }
        .padding(.vertical, 14).padding(.horizontal, 24)
    }
}

struct PlaylistRowButtonStyle: ButtonStyle {
    @Environment(\.isFocused) var isFocused
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(RoundedRectangle(cornerRadius: 12).fill(isFocused ? Color.white.opacity(0.15) : Color.clear))
            .scaleEffect(isFocused ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}
