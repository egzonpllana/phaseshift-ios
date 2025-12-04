import UIKit

// MARK: - Configuration

/// Configuration for phase shift transition animations.
///
/// Use this structure to customize animation parameters for phase shift transitions.
public struct PhaseShiftConfiguration {
    
    // MARK: - Properties
    
    /// The duration of the transition animation in seconds.
    public let duration: TimeInterval
    
    /// The spring damping ratio for the animation (0.0 = bouncy, 1.0 = no bounce).
    public let springDamping: CGFloat
    
    /// The initial spring velocity for the animation.
    public let initialSpringVelocity: CGFloat
    
    /// Animation options for the presentation phase.
    public let presentationOptions: UIView.AnimationOptions
    
    /// Animation options for the dismissal phase.
    public let dismissalOptions: UIView.AnimationOptions
    
    // MARK: - Initialization
    
    /// Creates a new phase shift configuration.
    ///
    /// - Parameters:
    ///   - duration: The duration of the transition animation. Default is `0.4` seconds.
    ///   - springDamping: The spring damping ratio. Default is `0.8`.
    ///   - initialSpringVelocity: The initial spring velocity. Default is `0.5`.
    ///   - presentationOptions: Animation options for presentation. Default is `.curveEaseOut`.
    ///   - dismissalOptions: Animation options for dismissal. Default is `.curveEaseIn`.
    public init(
        duration: TimeInterval = 0.4,
        springDamping: CGFloat = 0.8,
        initialSpringVelocity: CGFloat = 0.5,
        presentationOptions: UIView.AnimationOptions = .curveEaseOut,
        dismissalOptions: UIView.AnimationOptions = .curveEaseIn
    ) {
        self.duration = duration
        self.springDamping = springDamping
        self.initialSpringVelocity = initialSpringVelocity
        self.presentationOptions = presentationOptions
        self.dismissalOptions = dismissalOptions
    }
    
    // MARK: - Default Configurations
    
    /// The default configuration with standard animation parameters.
    public static let `default` = PhaseShiftConfiguration()
    
    /// A fast configuration with shorter duration.
    public static let fast = PhaseShiftConfiguration(
        duration: 0.25,
        springDamping: 0.9,
        initialSpringVelocity: 0.6
    )
    
    /// A slow configuration with longer duration for more dramatic effect.
    public static let slow = PhaseShiftConfiguration(
        duration: 0.6,
        springDamping: 0.7,
        initialSpringVelocity: 0.4
    )
}

