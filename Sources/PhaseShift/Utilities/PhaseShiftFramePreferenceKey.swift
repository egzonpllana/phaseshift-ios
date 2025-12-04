import SwiftUI

// MARK: - Frame Preference Key

/// Preference key for passing item frame information up the view hierarchy.
///
/// Use this preference key to track frames of items in a grid or list for phase shift
/// modal presentation. The frames are stored as a dictionary mapping item indices to
/// their corresponding frames in global coordinates.
///
/// ## Example Usage
///
/// ```swift
/// struct GridView: View {
///     @State private var itemFrames: [Int: CGRect] = [:]
///
///     var body: some View {
///         LazyVGrid(columns: columns) {
///             ForEach(0..<items.count, id: \.self) { index in
///                 ItemView(index: index)
///                     .background(
///                         GeometryReader { geometry in
///                             Color.clear
///                                 .preference(
///                                     key: PhaseShiftFramePreferenceKey.self,
///                                     value: [index: geometry.frame(in: .global)]
///                                 )
///                         }
///                     )
///             }
///         }
///         .onPreferenceChange(PhaseShiftFramePreferenceKey.self) { frames in
///             itemFrames = frames
///         }
///     }
/// }
/// ```
public struct PhaseShiftFramePreferenceKey: PreferenceKey {
    
    // MARK: - PreferenceKey
    
    /// The default value for the preference key (empty dictionary).
    public static var defaultValue: [Int: CGRect] = [:]
    
    /// Reduces multiple preference values into a single value.
    ///
    /// When multiple views provide preference values, this method merges them,
    /// with newer values taking precedence over older ones for the same key.
    ///
    /// - Parameters:
    ///   - value: The current accumulated value (modified in place).
    ///   - nextValue: A closure that returns the next value to merge.
    public static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

