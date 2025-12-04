import UIKit

/// Protocol for providing window and root view controller access.
///
/// This protocol enables dependency injection and testability by abstracting
/// window access logic.
protocol WindowProviding {
    /// Returns the root view controller from the main window.
    /// - Returns: The root view controller, or `nil` if not available.
    func rootViewController() -> UIViewController?
}

/// Default implementation of `WindowProviding` using `UIApplication`.
struct DefaultWindowProvider: WindowProviding {
    func rootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        guard let window = windowScene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
}

