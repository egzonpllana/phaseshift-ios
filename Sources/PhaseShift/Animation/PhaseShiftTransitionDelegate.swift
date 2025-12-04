import UIKit

// MARK: - Transition Delegate

/// Manages the custom transition animation for modal presentations from a source frame.
///
/// This delegate coordinates the presentation and dismissal animations using
/// ``PhaseShiftTransitionAnimator``. It implements `UIViewControllerTransitioningDelegate`
/// to provide animators for both presentation and dismissal phases.
///
/// ## Usage
///
/// ```swift
/// let delegate = PhaseShiftTransitionDelegate(
///     sourceFrame: tappedItemFrame,
///     configuration: .default
/// )
/// viewController.transitioningDelegate = delegate
/// ```
final class PhaseShiftTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    // MARK: - Properties
    
    /// The source frame in window coordinates.
    private let sourceFrame: CGRect
    
    /// The animation configuration.
    private let configuration: PhaseShiftConfiguration
    
    // MARK: - Initialization
    
    /// Creates a new transition delegate.
    ///
    /// - Parameters:
    ///   - sourceFrame: The source frame in window coordinates.
    ///   - configuration: The animation configuration. Defaults to `.default`.
    init(
        sourceFrame: CGRect,
        configuration: PhaseShiftConfiguration = .default
    ) {
        self.sourceFrame = sourceFrame
        self.configuration = configuration
        super.init()
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        PhaseShiftTransitionAnimator(
            sourceFrame: sourceFrame,
            isPresenting: true,
            configuration: configuration
        )
    }
    
    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        PhaseShiftTransitionAnimator(
            sourceFrame: sourceFrame,
            isPresenting: false,
            configuration: configuration
        )
    }
}

