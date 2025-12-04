import SwiftUI

// MARK: - Environment Key

/// Environment key for the dismiss action.
private struct DismissActionKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

// MARK: - Environment Values Extension

extension EnvironmentValues {
    /// Environment value for dismissing the phase shift modal programmatically.
    ///
    /// This environment value is automatically available in all views presented within
    /// a phase shift modal. Use it to dismiss the modal from anywhere in the view hierarchy.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct ModalContentView: View {
    ///     @Environment(\.dismissPhaseShift) private var dismissPhaseShift
    ///
    ///     var body: some View {
    ///         Button("Dismiss") {
    ///             dismissPhaseShift?()
    ///         }
    ///     }
    /// }
    /// ```
    public var dismissPhaseShift: (() -> Void)? {
        get { self[DismissActionKey.self] }
        set { self[DismissActionKey.self] = newValue }
    }
}

