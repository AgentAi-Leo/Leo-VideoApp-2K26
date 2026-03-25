import SwiftUI

/// Playlist browser — shows all videos, lets user tap to start playback
struct PlaylistBrowserView: View {
    var service: PlaylistService
    @Binding var returnFocusIndex: Int?
    let onPlay: (Int, Bool) -> Void    // passes the selected index and mute state

    @State private var selectedIndex: Int = 0
    @State private var isMuted: Bool = false
    
    enum FocusTarget: Hashable {
        case refresh
        case playAll
        case muteToggle
        case row(Int)
        case bottomWarpGate
        case rightWarpGate(Int)
        case leftWarpGate(Int, String)
    }
    @FocusState private var focusedField: FocusTarget?
    @State private var lastFocusedVideoRow: Int? = nil
    
    // Dynamic grouping helper to generate categorized sections natively mapping to the absolute AVPlayer indices
    var sections: [(name: String, items: [(offset: Int, element: VideoItem)])] {
        var result: [(name: String, items: [(offset: Int, element: VideoItem)])] = []
        let orderedCategories = ["INTRO", "MAIN", "OUTRO"]
        
        let enumeratedPlaylist = Array(service.playlist.enumerated())
        
        for cat in orderedCategories {
            let catItems = enumeratedPlaylist.filter { $0.element.category == cat }
            if !catItems.isEmpty {
                result.append((name: cat, items: catItems))
            }
        }
        
        let otherItems = enumeratedPlaylist.filter { !orderedCategories.contains($0.element.category ?? "") }
        if !otherItems.isEmpty {
            result.append((name: "OTHER", items: otherItems))
        }
        
        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("LeoTV Player")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("\(service.playlist.count) videos")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()

                // Play All button (starts from index 0)
                Button(action: { onPlay(0, isMuted) }) {
                    Label("Play All", systemImage: "play.fill")
                }
                .buttonStyle(HeaderButtonStyle())
                .focused($focusedField, equals: .playAll)
                .onMoveCommand { direction in
                    switch direction {
                    case .right: focusedField = .refresh
                    case .left:
                        if let lastRow = lastFocusedVideoRow {
                            focusedField = .row(lastRow)
                        }
                    case .down: focusedField = .row(0)
                    default: break
                    }
                }

                // Refresh button
                Button(action: {
                    Task { 
                        await service.fetchPlaylist() 
                        focusedField = .playAll
                    }
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(HeaderButtonStyle())
                .focused($focusedField, equals: .refresh)
                .onMoveCommand { direction in
                    switch direction {
                    case .left: focusedField = .playAll
                    case .right: focusedField = .muteToggle
                    case .down: focusedField = .row(0)
                    default: break
                    }
                }
                
                // Audio Toggle
                Button(action: { isMuted.toggle() }) {
                    Label(isMuted ? "Audio OFF" : "Audio ON", systemImage: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                }
                .buttonStyle(HeaderButtonStyle(
                    focusColor: isMuted ? Color(red: 145/255.0, green: 15/255.0, blue: 15/255.0) : Color(red: 39/255.0, green: 155/255.0, blue: 72/255.0),
                    isPersistent: isMuted
                ))
                .focused($focusedField, equals: .muteToggle)
                .onMoveCommand { direction in
                    switch direction {
                    case .left: focusedField = .refresh
                    case .right:
                        if let lastRow = lastFocusedVideoRow {
                            focusedField = .row(lastRow)
                        }
                    case .down: focusedField = .row(0)
                    default: break
                    }
                }
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
                    LazyVStack(spacing: 2) { // Reduced 75% from 8
                        ForEach(sections, id: \.name) { section in
                            Section(header:
                                Text(section.name)
                                    .font(.system(size: 40, weight: .bold)) // Decreased 10% from 45pt
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 40)
                                    .padding(.bottom, 12)
                            ) {
                                ForEach(section.items, id: \.element.id) { pair in
                                    HStack(spacing: 20) {
                                        // Spatially Independent Sub-Pixel Left-Warp (Section Jumper) Sibling
                                        if #available(tvOS 17.0, *) {
                                            Color.clear
                                                .frame(width: 1, height: 1)
                                                .focusable(true)
                                                .focused($focusedField, equals: .leftWarpGate(pair.offset, section.name))
                                                .focusEffectDisabled()
                                                .opacity(0.01)
                                        } else {
                                            Color.clear
                                                .frame(width: 1, height: 1)
                                                .focusable(true)
                                                .focused($focusedField, equals: .leftWarpGate(pair.offset, section.name))
                                                .opacity(0.01)
                                        }
                                        
                                        Button(action: {
                                            selectedIndex = pair.offset
                                            onPlay(pair.offset, isMuted)
                                        }) {
                                            PlaylistRow(
                                                item: pair.element,
                                                index: pair.offset + 1,
                                                isSelected: selectedIndex == pair.offset
                                            )
                                        }
                                        .buttonStyle(PlaylistRowButtonStyle())
                                        .focused($focusedField, equals: .row(pair.offset))
                                        
                                        // Spatially Independent Sub-Pixel Warp Gate Sibling
                                        if #available(tvOS 17.0, *) {
                                            Color.clear
                                                .frame(width: 1, height: 1)
                                                .focusable(true)
                                                .focused($focusedField, equals: .rightWarpGate(pair.offset))
                                                .focusEffectDisabled()
                                                .opacity(0.01)
                                        } else {
                                            Color.clear
                                                .frame(width: 1, height: 1)
                                                .focusable(true)
                                                .focused($focusedField, equals: .rightWarpGate(pair.offset))
                                                .opacity(0.01)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Structural Warp Gate
                        if !service.playlist.isEmpty {
                            Button(action: {
                                focusedField = .playAll
                            }) {
                                HStack {
                                    Spacer()
                                    Label("Return to Top", systemImage: "arrow.up.circle.fill")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 16)
                                    Spacer()
                                }
                            }
                            .buttonStyle(WarpGateButtonStyle())
                            .focused($focusedField, equals: .bottomWarpGate)
                            .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal, 60)
                    .padding(.bottom, 60)
                }
            }
        }
        .background(Color.black)
        .defaultFocus($focusedField, .playAll)
        .onAppear {
            // Because ContentView explicitly destroys and recreates this view via the 'isPlaying' boolean,
            // .onChange will mathematically never fire. We MUST hijack the focus state the absolute nanosecond the view mounts!
            if let index = returnFocusIndex {
                if index == -1 {
                    focusedField = .playAll
                } else {
                    focusedField = .row(index)
                }
                // Nullify it so it doesn't accidentally re-trigger if the view refreshes
                returnFocusIndex = nil
            }
        }
        .onChange(of: returnFocusIndex) { _, newIndex in
            if let index = newIndex {
                if index == -1 {
                    focusedField = .playAll
                } else {
                    focusedField = .row(index)
                }
                returnFocusIndex = nil
            }
        }
        .task {
            // Auto-refresh playlist identically to a manual refresh whenever the app launches
            if service.playlist.isEmpty {
                await service.fetchPlaylist()
            }
        }
        .onChange(of: focusedField) { _, newValue in
            // Always map the user's explicit coordinate baseline while scrolling geometrically
            if case let .row(index) = newValue {
                lastFocusedVideoRow = index
            }
            
            // Execute the kinematic camera teleportation instantly when striking the spatial right gate
            if case .rightWarpGate(_) = newValue {
                focusedField = .playAll
            }
            
            // Execute the Section-Jump logic when striking the left spatial gate
            if case let .leftWarpGate(currentOffset, sectionName) = newValue {
                Task {
                    // Yield the thread to allow TVOS to fully acknowledge the physical hit-test before scrambling the scroll state
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    await MainActor.run {
                        if let sectionIndex = sections.firstIndex(where: { $0.name == sectionName }),
                           let firstOffset = sections[sectionIndex].items.first?.offset {
                            
                            if currentOffset > firstOffset {
                                // Deep in section -> jump to head of CURRENT section
                                focusedField = .row(firstOffset)
                            } else if sectionIndex > 0, let prevOffset = sections[sectionIndex - 1].items.first?.offset {
                                // Already at head -> jump to head of PREVIOUS section
                                focusedField = .row(prevOffset)
                            } else {
                                // At absolute top of entire playlist -> jump entirely out to Header
                                focusedField = .playAll
                            }
                        }
                    }
                }
            }
            
            if newValue == .bottomWarpGate {
                // Initiate a tiny cinematic micro-delay to allow Apple TV to fully resolve the native focus geometry, completely erasing horizontal white-line artifacts before teleporting
                Task {
                    try? await Task.sleep(nanoseconds: 150_000_000)
                    await MainActor.run {
                        focusedField = .playAll
                    }
                }
            }
        }
    }
}

// MARK: - Playlist Row

/// Single row in the playlist browser
struct PlaylistRow: View {
    let item: VideoItem
    let index: Int
    let isSelected: Bool

    private func parseTitle(_ title: String) -> (cleanTitle: String, badge: String?) {
        if let start = title.firstIndex(of: "["), let end = title.firstIndex(of: "]"), start < end {
            let badgeSubstring = title[title.index(after: start)..<end]
            let badge = String(badgeSubstring)
            
            // Explicitly preserve the legacy bracket format for Unknown videos as requested by user
            if title.lowercased().starts(with: "unknown") {
                return (title.trimmingCharacters(in: .whitespaces), badge.uppercased())
            } else {
                // Cleanly strip the backend domain tag for properly named YouTube/Vimeo videos
                var clean = title.replacingOccurrences(of: "[\(badge)]", with: "")
                clean = clean.replacingOccurrences(of: "--", with: " - ")
                clean = clean.replacingOccurrences(of: "  ", with: " ")
                return (clean.trimmingCharacters(in: .whitespaces), badge.uppercased())
            }
        }
        return (title, nil)
    }
    
    private func badgeColor(for type: String) -> (bg: Color, text: Color) {
        switch type {
        case "PIXABAY": return (Color.yellow, Color.black)
        case "YOUTUBE": return (Color.red, Color.white)
        case "VIMEO":   return (Color.cyan, Color.black)
        case "PEXELS":  return (Color.green, Color.black)
        default:        return (Color.gray, Color.white)
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Track number
            Text("\(index)")
                .font(.system(size: 36, design: .default).monospacedDigit()) // Increased 11% from 32pt
                .foregroundColor(.gray)
                .frame(width: 40, alignment: .trailing)

            // Title + badges
            let parsed = parseTitle(item.title)
            
            HStack(spacing: 12) {
                if let badge = parsed.badge {
                    Text(badge)
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(badgeColor(for: badge).text)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(badgeColor(for: badge).bg)
                        )
                }
                
                Text(parsed.cleanTitle)
                    .font(.system(size: 32)) // Increased 10% from native .body (29pt)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }

            Spacer()

            // Play icon
            Image(systemName: "play.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white.opacity(0.65), Color(red: 39/255.0, green: 155/255.0, blue: 72/255.0))
                .font(.title2)
        }
        .padding(.vertical, 2) // Reduced padding 75% (from 6pt) for maximum layout compactness
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
            // Removed scaleEffect to mathematically guarantee the Play Icon stays statically aligned against the right-margin grid
    }
}

// MARK: - Custom Header Button Style

/// Custom button style for the header buttons (Refresh, Play All) to dynamically toggle between White / Cyan states
struct HeaderButtonStyle: ButtonStyle {
    @Environment(\.isFocused) var isFocused
    var focusColor: Color = Color(red: 39/255.0, green: 155/255.0, blue: 72/255.0)
    var isPersistent: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill((isFocused || isPersistent) ? focusColor : Color.white.opacity(0.15))
                    .shadow(color: (isFocused || isPersistent) ? focusColor.opacity(0.4) : .clear, radius: 8, y: 4)
            )
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .animation(.easeOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Custom Footer Button Style

/// Specialized style for the bottom Warp Gate to decouple Typography alpha tracking securely from the Background boundary
struct WarpGateButtonStyle: ButtonStyle {
    @Environment(\.isFocused) var isFocused
    var focusColor: Color = Color(red: 39/255.0, green: 155/255.0, blue: 72/255.0)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .opacity(isFocused ? 1.0 : 0.32)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isFocused ? focusColor : Color.white.opacity(0.03))
                    .shadow(color: isFocused ? focusColor.opacity(0.4) : .clear, radius: 8, y: 4)
            )
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .animation(.easeOut(duration: 0.2), value: isFocused)
    }
}
