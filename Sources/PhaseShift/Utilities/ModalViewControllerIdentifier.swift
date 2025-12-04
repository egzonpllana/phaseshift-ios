import UIKit

/// Utility for identifying phase shift modal view controllers.
///
/// This utility provides a single source of truth for checking if a view controller
/// is a phase shift modal, enabling better separation of concerns.
enum ModalViewControllerIdentifier {
    /// Checks if the given view controller is a phase shift modal.
    /// - Parameter viewController: The view controller to check.
    /// - Returns: `true` if the view controller is a phase shift modal, `false` otherwise.
    static func isPhaseShiftModal(_ viewController: UIViewController) -> Bool {
        viewController is PhaseShiftContentViewController
    }
}

