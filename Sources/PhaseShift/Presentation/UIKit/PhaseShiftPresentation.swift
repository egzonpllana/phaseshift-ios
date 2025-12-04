import UIKit
import SwiftUI

// MARK: - UIKit Presentation API

/// UIKit API for presenting modals with phase shift transitions.
///
/// Use this class to present modals directly from UIKit view controllers.
/// It provides static methods for presenting both SwiftUI views and UIKit view controllers
/// with phase shift transitions.
///
/// ## Example: Presenting SwiftUI View
///
/// ```swift
/// let contentView = MySwiftUIView()
/// PhaseShiftPresentation.present(
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
/// PhaseShiftPresentation.present(
///     from: self,
///     sourceFrame: tappedItemFrame,
///     contentViewController: navController,
///     configuration: .fast
/// )
/// ```
///
/// - SeeAlso: ``UIKitCollectionGridViewController`` for a complete UIKit example
public final class PhaseShiftPresentation {
    
    // MARK: - SwiftUI Presentation
    
    /// Presents a SwiftUI view as a modal with phase shift transition animation.
    ///
    /// This method uses the unified SwiftUI content hosting infrastructure
    /// for consistent behavior with SwiftUI API presentations.
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
        PhaseShiftUIKitAdapter.present(
            from: viewController,
            sourceFrame: sourceFrame,
            content: content,
            configuration: configuration
        )
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

