import UIKit
import SwiftUI

/// UIKit adapter API for presenting modals with phase shift transitions.
///
/// This adapter provides UIKit APIs that use the SwiftUI infrastructure,
/// ensuring consistent behavior between SwiftUI and UIKit presentations.
///
/// ## Example: Presenting SwiftUI View
///
/// ```swift
/// let contentView = MySwiftUIView()
/// PhaseShiftUIKitAdapter.present(
///     from: self,
///     sourceFrame: tappedItemFrame,
///     content: contentView
/// )
/// ```
///
/// ## Example: Presenting UIKit View Controller
///
/// ```swift
/// let detailVC = DetailViewController()
/// let navController = UINavigationController(rootViewController: detailVC)
/// PhaseShiftUIKitAdapter.present(
///     from: self,
///     sourceFrame: tappedItemFrame,
///     contentViewController: navController,
///     configuration: .fast
/// )
/// ```
public final class PhaseShiftUIKitAdapter {
    
    // MARK: - SwiftUI Presentation
    
    /// Presents a SwiftUI view as a modal with phase shift transition animation.
    ///
    /// This method uses the unified SwiftUI content hosting infrastructure,
    /// ensuring consistent behavior with SwiftUI API presentations.
    ///
    /// - Parameters:
    ///   - viewController: The view controller to present from.
    ///   - sourceFrame: The frame in window coordinates where the modal should animate from/to.
    ///   - content: The SwiftUI view to display in the modal.
    ///   - configuration: The animation configuration. Defaults to `.default`.
    public static func present<Content: View>(
        from viewController: UIViewController,
        sourceFrame: CGRect,
        content: Content,
        configuration: PhaseShiftConfiguration = .default
    ) {
        let modalViewController = PhaseShiftContentHost.createViewController(
            content: content,
            sourceFrame: sourceFrame,
            configuration: configuration,
            onDismiss: nil
        )
        
        viewController.present(modalViewController, animated: true)
    }
    
    // MARK: - UIKit Presentation
    
    /// Presents a UIKit view controller as a modal with phase shift transition animation.
    ///
    /// - Parameters:
    ///   - viewController: The view controller to present from.
    ///   - sourceFrame: The frame in window coordinates where the modal should animate from/to.
    ///   - contentViewController: The UIKit view controller to display in the modal.
    ///   - configuration: The animation configuration. Defaults to `.default`.
    public static func present(
        from viewController: UIViewController,
        sourceFrame: CGRect,
        contentViewController: UIViewController,
        configuration: PhaseShiftConfiguration = .default
    ) {
        let wrapper = PhaseShiftWrapperViewController(
            sourceFrame: sourceFrame,
            contentViewController: contentViewController,
            configuration: configuration
        )
        
        viewController.present(wrapper, animated: true)
    }
}

