import UIKit

// MARK: - Transition Context

/// Context information for phase shift transitions.
///
/// Encapsulates the source frame and configuration needed for a phase shift transition.
public struct PhaseShiftTransitionContext {
    
    // MARK: - Properties
    
    /// The source frame in window coordinates where the transition originates.
    ///
    /// This frame defines the starting point for the animation. The modal will animate
    /// from this frame to full screen during presentation, and reverse during dismissal.
    public let sourceFrame: CGRect
    
    /// The configuration for the transition animation.
    public let configuration: PhaseShiftConfiguration
    
    // MARK: - Initialization
    
    /// Creates a new transition context.
    ///
    /// - Parameters:
    ///   - sourceFrame: The source frame in window coordinates.
    ///   - configuration: The animation configuration. Defaults to `.default`.
    public init(
        sourceFrame: CGRect,
        configuration: PhaseShiftConfiguration = .default
    ) {
        self.sourceFrame = sourceFrame
        self.configuration = configuration
    }
}

