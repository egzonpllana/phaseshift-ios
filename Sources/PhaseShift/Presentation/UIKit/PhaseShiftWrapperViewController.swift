import UIKit

// MARK: - Wrapper View Controller

/// A wrapper view controller that presents UIKit view controllers with phase shift transitions.
///
/// This view controller wraps any UIKit view controller (including `UINavigationController`)
/// to enable phase shift transitions. It properly manages the child view controller lifecycle
/// and handles cleanup on dismissal.
///
/// ## Usage
///
/// ```swift
/// let detailVC = DetailViewController()
/// let wrapper = PhaseShiftWrapperViewController(
///     sourceFrame: tappedItemFrame,
///     contentViewController: detailVC,
///     configuration: .default
/// )
/// present(wrapper, animated: true)
/// ```
final class PhaseShiftWrapperViewController: UIViewController {
    
    // MARK: - Properties
    
    /// The transition delegate managing the custom animation.
    private let transitionDelegate: PhaseShiftTransitionDelegate
    
    /// The content view controller being wrapped.
    private let contentViewController: UIViewController
    
    // MARK: - Initialization
    
    /// Creates a new wrapper view controller.
    ///
    /// - Parameters:
    ///   - sourceFrame: The source frame in window coordinates.
    ///   - contentViewController: The UIKit view controller to display in the modal.
    ///   - configuration: The animation configuration. Defaults to `.default`.
    init(
        sourceFrame: CGRect,
        contentViewController: UIViewController,
        configuration: PhaseShiftConfiguration = .default
    ) {
        self.transitionDelegate = PhaseShiftTransitionDelegate(
            sourceFrame: sourceFrame,
            configuration: configuration
        )
        self.contentViewController = contentViewController
        super.init(nibName: nil, bundle: nil)
        setupModalPresentation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContentViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isBeingDismissed {
            cleanupContentViewController()
        }
    }
    
    // MARK: - Setup
    
    /// Configures the modal presentation style and transition delegate.
    private func setupModalPresentation() {
        modalPresentationStyle = .custom
        transitioningDelegate = transitionDelegate
    }
    
    /// Sets up the content view controller as a child view controller.
    private func setupContentViewController() {
        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentViewController.didMove(toParent: self)
    }
    
    /// Cleans up the content view controller when being dismissed.
    private func cleanupContentViewController() {
        contentViewController.willMove(toParent: nil)
        contentViewController.view.removeFromSuperview()
        contentViewController.removeFromParent()
    }
}
