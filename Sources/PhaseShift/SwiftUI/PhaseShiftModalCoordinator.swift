import SwiftUI
import UIKit

/// Coordinator that manages phase shift modal presentation state using SwiftUI patterns.
///
/// This coordinator handles the lifecycle and state management for modal presentations,
/// providing a clean SwiftUI-native approach to managing UIKit modal presentation.
@MainActor
final class PhaseShiftModalCoordinator: ObservableObject, ModalPresentationCoordinating {
    
    // MARK: - Published Properties
    
    /// Whether a modal is currently being presented.
    @Published private(set) var isPresenting = false
    
    // MARK: - Private Properties
    
    /// Whether a presentation is currently in progress (prevents race conditions).
    /// This is checked synchronously to prevent multiple presentations.
    private(set) var isPresentationInProgress = false
    
    /// Weak reference to the presenting view controller.
    private weak var presentingViewController: UIViewController?
    
    /// Weak reference to the presented modal view controller.
    private weak var presentedModalViewController: UIViewController?
    
    /// The source frame for the transition animation.
    private var sourceFrame: CGRect = .zero
    
    /// The animation configuration.
    private var configuration: PhaseShiftConfiguration = .default
    
    /// Callback invoked when modal is dismissed.
    private var onDismiss: (() -> Void)?
    
    /// Manager for presentation state synchronization.
    private let stateManager = PresentationStateManager()
    
    private enum Constants {
        static let retryDelayNanoseconds: UInt64 = 100_000_000
    }
    
    // MARK: - Presentation Management
    
    /// Presents a modal with the given SwiftUI content.
    ///
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
    ) {
        print("[PhaseShiftCoordinator] present() called")
        print("[PhaseShiftCoordinator] sourceFrame: \(sourceFrame)")
        print("[PhaseShiftCoordinator] isPresenting: \(isPresenting), isPresentationInProgress: \(isPresentationInProgress)")
        
        guard !isPresenting, !isPresentationInProgress else {
            print("[PhaseShiftCoordinator] Already presenting or in progress, returning")
            return
        }
        
        guard presentingViewController.presentedViewController == nil else {
            print("[PhaseShiftCoordinator] Presenting VC already has presented VC, scheduling retry")
            scheduleRetry(
                content: content,
                sourceFrame: sourceFrame,
                configuration: configuration,
                presentingViewController: presentingViewController,
                onDismiss: onDismiss
            )
            return
        }
        
        print("[PhaseShiftCoordinator] Setting isPresentationInProgress = true")
        isPresentationInProgress = true
        
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            print("[PhaseShiftCoordinator] Setting isPresenting = true")
            self.isPresenting = true
            self.isPresentationInProgress = false
        }
        
        self.sourceFrame = sourceFrame
        self.configuration = configuration
        self.presentingViewController = presentingViewController
        self.onDismiss = onDismiss
        
        print("[PhaseShiftCoordinator] Creating modal view controller")
        let modalViewController = PhaseShiftContentHost.createViewController(
            content: content,
            sourceFrame: sourceFrame,
            configuration: configuration,
            onDismiss: { [weak self] in
                self?.handleDismissal()
            }
        )
        
        presentedModalViewController = modalViewController
        print("[PhaseShiftCoordinator] Calling present() on \(type(of: presentingViewController))")
        presentingViewController.present(modalViewController, animated: true)
        print("[PhaseShiftCoordinator] present() call completed")
    }
    
    private func scheduleRetry<Content: View>(
        content: Content,
        sourceFrame: CGRect,
        configuration: PhaseShiftConfiguration,
        presentingViewController: UIViewController,
        onDismiss: (() -> Void)?
    ) {
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: Constants.retryDelayNanoseconds)
            guard let self = self, !self.isPresenting, !self.isPresentationInProgress else {
                return
            }
            self.present(
                content: content,
                sourceFrame: sourceFrame,
                configuration: configuration,
                from: presentingViewController,
                onDismiss: onDismiss
            )
        }
    }
    
    func dismiss() {
        guard isPresenting else {
            return
        }
        
        presentedModalViewController?.dismiss(animated: true)
        
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.handleDismissal()
        }
    }
    
    func updatePresentationState(
        isPresented: Bool,
        presentingViewController: UIViewController?
    ) {
        guard let presentingViewController = presentingViewController else {
            return
        }
        
        let hasPresentedViewController = presentingViewController.presentedViewController != nil
        
        stateManager.handleStateUpdate(
            isPresented: isPresented,
            isPresenting: isPresenting,
            hasPresentedViewController: hasPresentedViewController,
            onDismiss: { [weak self] in
                self?.dismiss()
            },
            onRetry: { [weak self] in
                guard let self = self, self.isPresenting == false else { return }
                self.updatePresentationState(
                    isPresented: isPresented,
                    presentingViewController: presentingViewController
                )
            },
            onStateReset: { [weak self] in
                guard let self = self else { return }
                Task { @MainActor in
                    self.isPresenting = false
                    self.presentedModalViewController = nil
                }
            }
        )
    }
    
    // MARK: - Private Methods
    
    private func handleDismissal() {
        guard isPresenting else {
            return
        }
        
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.isPresenting = false
            self.isPresentationInProgress = false
            self.presentedModalViewController = nil
            self.onDismiss?()
            self.onDismiss = nil
        }
    }
}

