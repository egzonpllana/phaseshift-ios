import SwiftUI

/// A view modifier that automatically tracks a view's frame for phase shift modal presentation.
///
/// This modifier simplifies frame tracking by handling all the boilerplate code
/// required for GeometryReader and PreferenceKey usage.
struct PhaseShiftFrameTracking: ViewModifier {
    let id: Int?
    @Binding var frame: CGRect
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: PhaseShiftFramePreferenceKey.self,
                            value: id.map { [$0: geometry.frame(in: .global)] } ?? [:]
                        )
                }
            )
            .onPreferenceChange(PhaseShiftFramePreferenceKey.self) { frames in
                Task { @MainActor in
                    if let id = id {
                        if let trackedFrame = frames[id] {
                            frame = trackedFrame
                        }
                    } else if let firstFrame = frames.values.first {
                        frame = firstFrame
                    }
                }
            }
    }
}

/// A view modifier for single-frame tracking without requiring an ID.
struct PhaseShiftSingleFrameTracking: ViewModifier {
    @Binding var frame: CGRect
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: PhaseShiftFramePreferenceKey.self,
                            value: [0: geometry.frame(in: .global)]
                        )
                }
            )
            .onPreferenceChange(PhaseShiftFramePreferenceKey.self) { frames in
                print("[PhaseShiftSingleFrameTracking] Preference change received, frames: \(frames)")
                Task { @MainActor in
                    if let trackedFrame = frames[0] {
                        print("[PhaseShiftSingleFrameTracking] Updating frame to: \(trackedFrame)")
                        frame = trackedFrame
                    } else {
                        print("[PhaseShiftSingleFrameTracking] No frame found for id 0")
                    }
                }
            }
    }
}

/// A view modifier that tracks multiple frames for collection/grid views.
///
/// This modifier simplifies tracking multiple frames by handling the preference
/// change callback automatically.
struct PhaseShiftFramesTracking: ViewModifier {
    @Binding var frames: [Int: CGRect]
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(PhaseShiftFramePreferenceKey.self) { newFrames in
                // Update synchronously for immediate availability
                // Only update if values actually changed to avoid unnecessary work
                if frames != newFrames {
                    frames = newFrames
                }
            }
    }
}

/// A helper view that wraps content and automatically tracks its frame.
///
/// Use this for collection items to simplify frame tracking in grids and lists.
public struct PhaseShiftFrameTracker<Content: View>: View {
    let id: Int
    let content: Content
    
    public var body: some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: PhaseShiftFramePreferenceKey.self,
                            value: [id: geometry.frame(in: .global)]
                        )
                }
            )
    }
}

extension View {
    /// Tracks this view's frame for phase shift modal presentation.
    ///
    /// This modifier automatically handles frame tracking, eliminating the need
    /// for manual GeometryReader and PreferenceKey boilerplate.
    ///
    /// ## Example (Single Frame - No ID Required)
    ///
    /// ```swift
    /// @State private var buttonFrame: CGRect = .zero
    ///
    /// Button("Present Modal") {
    ///     isPresented = true
    /// }
    /// .phaseShiftFrame(frame: $buttonFrame)
    /// ```
    ///
    /// - SeeAlso: ``SwiftUIExampleNavigationStackView`` for a complete single-frame example
    ///
    /// ## Example (With ID - For Collections)
    ///
    /// ```swift
    /// @State private var itemFrames: [Int: CGRect] = [:]
    ///
    /// ForEach(0..<items.count, id: \.self) { index in
    ///     ItemView(index: index)
    ///         .phaseShiftFrame(id: index, frame: .constant(.zero))
    /// }
    /// .phaseShiftFrames(frames: $itemFrames)
    /// ```
    ///
    /// - SeeAlso: ``SwiftUIExampleCollectionGridView`` for a complete collection example
    ///
    /// - Parameter frame: Binding that receives the tracked frame in global coordinates.
    ///
    /// - Returns: A view with frame tracking applied.
    public func phaseShiftFrame(frame: Binding<CGRect>) -> some View {
        modifier(PhaseShiftSingleFrameTracking(frame: frame))
    }
    
    /// Tracks this view's frame for phase shift modal presentation with an ID.
    ///
    /// Use this overload when tracking multiple frames in a collection/grid.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for this frame (required for collections).
    ///   - frame: Binding that receives the tracked frame in global coordinates.
    ///
    /// - Returns: A view with frame tracking applied.
    public func phaseShiftFrame(id: Int, frame: Binding<CGRect>) -> some View {
        modifier(PhaseShiftFrameTracking(id: id, frame: frame))
    }
    
    /// Tracks multiple frames for collection/grid views.
    ///
    /// Use this modifier on a container view (like `LazyVGrid`) to automatically
    /// collect all frames from child views that use `PhaseShiftFrameTracker`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// @State private var itemFrames: [Int: CGRect] = [:]
    ///
    /// LazyVGrid(columns: columns) {
    ///     ForEach(0..<items.count, id: \.self) { index in
    ///         PhaseShiftFrameTracker(id: index) {
    ///             ItemView(index: index)
    ///         }
    ///     }
    /// }
    /// .phaseShiftFrames(frames: $itemFrames)
    /// ```
    ///
    /// - SeeAlso: ``SwiftUIExampleCollectionGridView`` for a complete implementation
    ///
    /// - Parameter frames: Binding that receives all tracked frames.
    ///
    /// - Returns: A view with multi-frame tracking applied.
    public func phaseShiftFrames(frames: Binding<[Int: CGRect]>) -> some View {
        modifier(PhaseShiftFramesTracking(frames: frames))
    }
}

extension PhaseShiftFrameTracker {
    /// Creates a frame tracker for collection items.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for this item's frame.
    ///   - content: The view content to track.
    public init(id: Int, @ViewBuilder content: () -> Content) {
        self.id = id
        self.content = content()
    }
}

