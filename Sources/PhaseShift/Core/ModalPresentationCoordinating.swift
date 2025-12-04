import SwiftUI
import UIKit

/// Protocol defining the contract for modal presentation coordination.
///
/// This protocol enables dependency injection and testability by abstracting
/// the modal presentation coordination logic.
@MainActor
protocol ModalPresentationCoordinating: ObservableObject {
    /// Whether a modal is currently being presented.
    var isPresenting: Bool { get }
    
    /// Whether a presentation is currently in progress.
    var isPresentationInProgress: Bool { get }
    
    /// Presents a modal with the given SwiftUI content.
    /// - Parameters:
    ///   - content: The SwiftUI view to display in the modal.
    ///   - sourceFrame: The source frame in window coordinates.
    ///   - configuration: The animation configuration.
    ///   - presentingViewController: The view controller to present from.
    ///   - onDismiss: Optional callback invoked when modal is dismissed.
    func present<Content: View>(
        content: Content,
        sourceFrame: CGRect,
        configuration: PhaseShiftConfiguration,
        from presentingViewController: UIViewController,
        onDismiss: (() -> Void)?
    )
    
    /// Dismisses the currently presented modal.
    func dismiss()
    
    /// Updates the presentation state based on external changes.
    /// - Parameters:
    ///   - isPresented: Whether the modal should be presented.
    ///   - presentingViewController: The view controller that should present the modal.
    func updatePresentationState(
        isPresented: Bool,
        presentingViewController: UIViewController?
    )
}

