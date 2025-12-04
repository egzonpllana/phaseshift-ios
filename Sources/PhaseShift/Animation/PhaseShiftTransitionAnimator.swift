import UIKit

// MARK: - Transition Animator

/// Handles the animation for presenting and dismissing a modal from a source frame.
///
/// This animator implements `UIViewControllerAnimatedTransitioning` to provide custom
/// phase shift transitions. It animates the modal presentation by scaling and translating
/// from the source frame to full screen, and reverses the animation when dismissing.
///
/// ## Animation Details
///
/// The animation uses spring-based physics for smooth, natural motion:
/// - **Presentation**: Scales from source frame size to full screen with translation
/// - **Dismissal**: Reverses the animation, scaling back to source frame
///
/// ## Example Usage
///
/// ```swift
/// let animator = PhaseShiftTransitionAnimator(
///     sourceFrame: tappedItemFrame,
///     isPresenting: true,
///     configuration: .default
/// )
/// ```
final class PhaseShiftTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Properties
    
    /// The source frame in window coordinates.
    private let sourceFrame: CGRect

    /// Whether this animator is handling presentation (`true`) or dismissal (`false`).
    private let isPresenting: Bool
    
    /// The animation configuration.
    private let configuration: PhaseShiftConfiguration
    
    // MARK: - Initialization
    
    /// Creates a new transition animator.
    ///
    /// - Parameters:
    ///   - sourceFrame: The source frame in window coordinates.
    ///   - isPresenting: `true` for presentation, `false` for dismissal.
    ///   - configuration: The animation configuration. Defaults to `.default`.
    init(
        sourceFrame: CGRect,
        isPresenting: Bool,
        configuration: PhaseShiftConfiguration = .default
    ) {
        self.sourceFrame = sourceFrame
        self.isPresenting = isPresenting
        self.configuration = configuration
        super.init()
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return configuration.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresentation(using: transitionContext)
        } else {
            animateDismissal(using: transitionContext)
        }
    }
    
    // MARK: - Private Animation Methods
    
    /// Animates the presentation of the modal.
    ///
    /// - Parameter transitionContext: The transition context containing view controllers and views.
    private func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let toView = transitionContext.view(forKey: .to),
              let presentingViewController = transitionContext.viewController(forKey: .from),
              let presentingView = presentingViewController.view,
              let window = presentingView.window else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        // Add the destination view to the container
        containerView.addSubview(toView)
        toView.frame = finalFrame
        
        // Calculate initial transform based on source frame
        let sourceFrameInContainer = containerView.convert(sourceFrame, from: window)
        let initialX = sourceFrameInContainer.midX - finalFrame.midX
        let initialY = sourceFrameInContainer.midY - finalFrame.midY
        
        // Use uniform scale based on the smaller dimension to maintain aspect ratio
        // This prevents distortion when source and destination have different aspect ratios
        let scaleX = sourceFrameInContainer.width / finalFrame.width
        let scaleY = sourceFrameInContainer.height / finalFrame.height
        let uniformScale = min(scaleX, scaleY)
        
        // Set initial state - view appears at source frame with slight dim
        toView.transform = CGAffineTransform(translationX: initialX, y: initialY)
            .scaledBy(x: uniformScale, y: uniformScale)
        toView.alpha = 0.7 // Slight dim at start
        
        // Animate to final state - scale, position, and subtle alpha change
        UIView.animate(
            withDuration: configuration.duration,
            delay: 0,
            usingSpringWithDamping: configuration.springDamping,
            initialSpringVelocity: configuration.initialSpringVelocity,
            options: configuration.presentationOptions,
            animations: {
                toView.transform = .identity
                toView.alpha = 1.0 // Fade in slightly during scale
            },
            completion: { finished in
                transitionContext.completeTransition(finished)
            }
        )
    }
    
    /// Animates the dismissal of the modal.
    ///
    /// - Parameter transitionContext: The transition context containing view controllers and views.
    private func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard let _ = transitionContext.viewController(forKey: .from),
              let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            transitionContext.completeTransition(false)
            return
        }
        
        // CRITICAL: The view MUST stay in the container view during animation
        // UIKit provides it, but we need to ensure it stays there
        // Don't move it - animate it in place!
        
        // Ensure view is in container and visible
        if fromView.superview != containerView {
            containerView.addSubview(fromView)
        }
        
        // Use the actual view's frame/bounds for calculations
        let currentFrame = fromView.frame
        
        // Calculate final transform based on source frame center
        let sourceFrameInContainer = containerView.convert(sourceFrame, from: window)
        
        // Calculate translation to move view center to source frame center
        let translationX = sourceFrameInContainer.midX - currentFrame.midX
        let translationY = sourceFrameInContainer.midY - currentFrame.midY
        
        // Transform: translate to source center, then scale to 0
        let finalTransform = CGAffineTransform(translationX: translationX, y: translationY)
            .scaledBy(x: 0.01, y: 0.01)
        
        // Animate to source frame center with scale to 0
        UIView.animate(
            withDuration: configuration.duration,
            delay: 0,
            usingSpringWithDamping: configuration.springDamping,
            initialSpringVelocity: configuration.initialSpringVelocity,
            options: configuration.dismissalOptions,
            animations: {
                fromView.transform = finalTransform
                fromView.alpha = 0.0
            },
            completion: { finished in
                transitionContext.completeTransition(finished)
            }
        )
    }
}
