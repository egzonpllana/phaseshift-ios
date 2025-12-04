import UIKit

extension UIView {
    /// Returns the frame of this view in window coordinates.
    ///
    /// Use this method to get the frame needed for phase shift modal presentation.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let frame = myButton.frameInWindow()
    /// PhaseShiftPresentation.present(
    ///     from: self,
    ///     sourceFrame: frame,
    ///     content: MySwiftUIView()
    /// )
    /// ```
    ///
    /// - Returns: The frame of this view in window coordinates, or `.zero` if not in a window hierarchy.
    /// - SeeAlso: ``UIKitCollectionGridViewController`` for a complete example using this method
    public func frameInWindow() -> CGRect {
        guard let window = window else {
            return .zero
        }
        return convert(bounds, to: window)
    }
}

