import SwiftUI
import UIKit

/// Unified content hosting for phase shift modals.
///
/// Provides a single source of truth for hosting SwiftUI content in phase shift modals,
/// used by both SwiftUI and UIKit APIs to ensure consistent behavior.
enum PhaseShiftContentHost {
    
    /// Creates a view controller that hosts SwiftUI content with phase shift transitions.
    ///
    /// - Parameters:
    ///   - content: The SwiftUI view to display.
    ///   - sourceFrame: The source frame in window coordinates.
    ///   - configuration: The animation configuration.
    ///   - onDismiss: Optional callback invoked when modal is dismissed.
    ///
    /// - Returns: A configured view controller ready for presentation.
    static func createViewController<Content: View>(
        content: Content,
        sourceFrame: CGRect,
        configuration: PhaseShiftConfiguration,
        onDismiss: (() -> Void)?
    ) -> UIViewController {
        PhaseShiftContentViewController(
            sourceFrame: sourceFrame,
            content: content,
            configuration: configuration,
            onDismiss: onDismiss
        )
    }
}

