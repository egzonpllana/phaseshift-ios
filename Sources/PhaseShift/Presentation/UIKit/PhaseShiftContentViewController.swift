import UIKit
import SwiftUI

// MARK: - Content View Controller

/// A view controller that wraps SwiftUI content for modal presentation with custom phase shift transitions.
///
/// This view controller bridges SwiftUI views with UIKit's modal presentation system,
/// enabling phase shift transitions for SwiftUI content. It can be used directly from
/// UIKit or via the SwiftUI ``phaseShiftModal(isPresented:sourceFrame:content:)`` modifier.
///
/// This is the unified content hosting implementation used by both SwiftUI and UIKit APIs
/// to ensure consistent behavior across both presentation methods.
///
/// ## Usage
///
/// ```swift
/// let contentViewController = PhaseShiftContentViewController(
///     sourceFrame: tappedItemFrame,
///     content: MySwiftUIView(),
///     configuration: .default
/// )
/// present(contentViewController, animated: true)
/// ```
public final class PhaseShiftContentViewController: UIHostingController<AnyView> {
    
    // MARK: - Properties
    
    /// The transition delegate managing the custom animation.
    let transitionDelegate: PhaseShiftTransitionDelegate
    
    /// Callback invoked when the modal is dismissed (either programmatically or externally).
    private var onDismiss: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Creates a new content view controller with SwiftUI content.
    ///
    /// - Parameters:
    ///   - sourceFrame: The source frame in window coordinates.
    ///   - content: The SwiftUI view to display in the modal.
    ///   - configuration: The animation configuration. Defaults to `.default`.
    ///   - onDismiss: Optional callback invoked when the modal is dismissed.
    public init<Content: View>(
        sourceFrame: CGRect,
        content: Content,
        configuration: PhaseShiftConfiguration = .default,
        onDismiss: (() -> Void)? = nil
    ) {
        self.transitionDelegate = PhaseShiftTransitionDelegate(
            sourceFrame: sourceFrame,
            configuration: configuration
        )
        self.onDismiss = onDismiss
        
        let wrappedContent = AnyView(content)
        super.init(rootView: wrappedContent)
        
        setupDismissEnvironment()
        setupModalPresentation()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isBeingDismissed {
            onDismiss?()
            onDismiss = nil
        }
    }
    
    // MARK: - Setup
    
    private func setupModalPresentation() {
        modalPresentationStyle = .custom
        transitioningDelegate = transitionDelegate
        definesPresentationContext = true
    }
    
    /// Sets up the dismiss environment value for SwiftUI content.
    private func setupDismissEnvironment() {
        rootView = AnyView(
            rootView.environment(\.dismissPhaseShift) { [weak self] in
                self?.dismiss(animated: true)
            }
        )
    }
}

