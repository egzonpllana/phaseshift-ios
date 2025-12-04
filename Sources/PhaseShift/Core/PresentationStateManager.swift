import UIKit

/// Manages presentation state synchronization logic.
///
/// This class encapsulates the logic for synchronizing external state changes
/// with the internal presentation state, following SRP.
@MainActor
final class PresentationStateManager {
    
    private enum Constants {
        static let retryDelayNanoseconds: UInt64 = 100_000_000
    }
    
    /// Determines the appropriate action based on current state.
    ///
    /// - Parameters:
    ///   - isPresented: Whether the modal should be presented.
    ///   - isPresenting: Whether a modal is currently being presented.
    ///   - hasPresentedViewController: Whether the presenting view controller has a presented view controller.
    ///   - onDismiss: Closure to call when dismissal is needed.
    ///   - onRetry: Closure to call when a retry is needed.
    ///   - onStateReset: Closure to call when state should be reset.
    func handleStateUpdate(
        isPresented: Bool,
        isPresenting: Bool,
        hasPresentedViewController: Bool,
        onDismiss: @escaping () -> Void,
        onRetry: @escaping () -> Void,
        onStateReset: @escaping () -> Void
    ) {
        if isPresented && !isPresenting {
            if hasPresentedViewController {
                scheduleRetry(onRetry: onRetry)
            }
        } else if !isPresented && isPresenting {
            onDismiss()
        } else if isPresented && isPresenting && !hasPresentedViewController {
            onStateReset()
        }
    }
    
    private func scheduleRetry(onRetry: @escaping () -> Void) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: Constants.retryDelayNanoseconds)
            onRetry()
        }
    }
}

