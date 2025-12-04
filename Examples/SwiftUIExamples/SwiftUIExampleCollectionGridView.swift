import SwiftUI
import PhaseShift

/// A view displaying a collection grid with a large title navigation bar.
///
/// Displays items in a 3-column grid layout with equal height and width cells.
struct SwiftUIExampleCollectionGridView: View {
    private let itemsPerRow = 3
    private let numberOfRows = 10
    private let totalItems: Int
    
    @State private var selectedItemIndex: Int?
    @State private var itemFrames: [Int: CGRect] = [:]
    @State private var itemColors: [Int: Color] = [:]
    @State private var isModalPresented = false
    
    init() {
        self.totalItems = itemsPerRow * numberOfRows
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: itemsPerRow),
                    spacing: 16
                ) {
                    ForEach(0..<totalItems, id: \.self) { index in
                        PhaseShiftFrameTracker(id: index) {
                            CollectionGridItemView(
                                index: index,
                                color: itemColor(for: index),
                                onTap: {
                                    selectedItemIndex = index
                                    // Small delay to ensure layout is complete
                                    Task { @MainActor in
                                        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
                                        isModalPresented = true
                                    }
                                }
                            )
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                .padding(16)
                .phaseShiftFrames(frames: $itemFrames)
                .onAppear {
                    initializeColorsIfNeeded()
                }
            }
            .navigationTitle("Collection")
            .navigationBarTitleDisplayMode(.large)
            .phaseShiftModal(
                isPresented: $isModalPresented,
                sourceFrame: selectedItemFrame
            ) {
                if let index = selectedItemIndex {
                    ModalContentView(
                        itemIndex: index,
                        backgroundColor: itemColor(for: index)
                    )
                }
            }
        }
    }
    
    private var selectedItemFrame: CGRect {
        guard let index = selectedItemIndex,
              let frame = itemFrames[index] else {
            return .zero
        }
        return frame
    }
    
    private func itemColor(for index: Int) -> Color {
        if let color = itemColors[index] {
            return color
        }
        return generateRandomColor(for: index)
    }
    
    private func initializeColorsIfNeeded() {
        guard itemColors.isEmpty else { return }
        var colors: [Int: Color] = [:]
        for index in 0..<totalItems {
            colors[index] = generateRandomColor(for: index)
        }
        itemColors = colors
    }
    
    private func generateRandomColor(for index: Int) -> Color {
        var generator = SeededRandomNumberGenerator(seed: UInt64(index))
        let hue = Double.random(in: 0...1, using: &generator)
        let saturation = Double.random(in: 0.4...0.95, using: &generator)
        let brightness = Double.random(in: 0.5...0.95, using: &generator)
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }
}

/// A single item in the collection grid.
private struct CollectionGridItemView: View {
    let index: Int
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 0)
                .fill(color)
                .overlay {
                    Text("\(index + 1)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// A seeded random number generator for deterministic random values.
private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed == 0 ? 1 : seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}

#Preview {
    SwiftUIExampleCollectionGridView()
}

