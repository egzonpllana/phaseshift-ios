import SwiftUI
import UIKit

// MARK: - View Modifier

/// A view modifier that enables presenting modals with custom phase shift transitions.
///
/// This modifier provides a SwiftUI-native API for presenting modals with phase shift
/// animations. It uses SwiftUI patterns and state management for a clean, declarative API.
///
/// ## Example
///
/// ```swift
/// struct ContentView: View {
///     @State private var isPresented = false
///     @State private var itemFrame: CGRect = .zero
///
///     var body: some View {
///         Button("Show Modal") {
///             isPresented = true
///         }
///         .phaseShiftModal(
///             isPresented: $isPresented,
///             sourceFrame: itemFrame
///         ) {
///             ModalContentView()
///         }
///     }
/// }
/// ```
///
/// - SeeAlso: ``SwiftUIExampleNavigationStackView`` for a complete example with navigation support
/// - SeeAlso: ``SwiftUIExampleCollectionGridView`` for a collection grid example
struct PhaseShiftModal<ModalContent: View>: ViewModifier {
    
    // MARK: - Properties
    
    /// Binding that controls the presentation state.
    @Binding var isPresented: Bool
    
    /// The source frame in window coordinates.
    let sourceFrame: CGRect
    
    /// Closure that returns the modal content view.
    let modalContent: () -> ModalContent
    
    /// The animation configuration.
    let configuration: PhaseShiftConfiguration
    
    /// Coordinator managing the presentation state.
    @StateObject private var coordinator = PhaseShiftModalCoordinator()
    
    // MARK: - Initialization
    
    /// Creates a new phase shift modal modifier.
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls the presentation state.
    ///   - sourceFrame: The source frame in window coordinates.
    ///   - modalContent: Closure returning the SwiftUI view to display.
    ///   - configuration: The animation configuration. Defaults to `.default`.
    init(
        isPresented: Binding<Bool>,
        sourceFrame: CGRect,
        modalContent: @escaping () -> ModalContent,
        configuration: PhaseShiftConfiguration = .default
    ) {
        self._isPresented = isPresented
        self.sourceFrame = sourceFrame
        self.modalContent = modalContent
        self.configuration = configuration
    }
    
    // MARK: - ViewModifier
    
    func body(content: Content) -> some View {
        content
            .background(
                PhaseShiftModalHelper(
                    isPresented: $isPresented,
                    sourceFrame: sourceFrame,
                    modalContent: modalContent,
                    configuration: configuration,
                    coordinator: coordinator,
                    windowProvider: DefaultWindowProvider()
                )
            )
    }
}

// MARK: - Presenter Helper

/// Helper view that bridges SwiftUI and UIKit for modal presentation.
///
/// This `UIViewControllerRepresentable` manages the actual presentation logic,
/// coordinating between SwiftUI's state management and UIKit's view controller system.
private struct PhaseShiftModalHelper<Content: View>: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    /// Binding that controls the presentation state.
    @Binding var isPresented: Bool
    
    /// The source frame in window coordinates.
    let sourceFrame: CGRect
    
    /// Closure that returns the modal content view.
    let modalContent: () -> Content
    
    /// The animation configuration.
    let configuration: PhaseShiftConfiguration
    
    /// The coordinator managing presentation state.
    @ObservedObject var coordinator: PhaseShiftModalCoordinator
    
    /// Provider for window and root view controller access.
    private let windowProvider: WindowProviding
    
    // MARK: - Initialization
    
    init(
        isPresented: Binding<Bool>,
        sourceFrame: CGRect,
        modalContent: @escaping () -> Content,
        configuration: PhaseShiftConfiguration,
        coordinator: PhaseShiftModalCoordinator,
        windowProvider: WindowProviding = DefaultWindowProvider()
    ) {
        self._isPresented = isPresented
        self.sourceFrame = sourceFrame
        self.modalContent = modalContent
        self.configuration = configuration
        self.coordinator = coordinator
        self.windowProvider = windowProvider
    }
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        print("[PhaseShiftModal] updateUIViewController called, isPresented: \(isPresented)")
        print("[PhaseShiftModal] sourceFrame: \(sourceFrame)")
        print("[PhaseShiftModal] coordinator.isPresenting: \(coordinator.isPresenting)")
        print("[PhaseShiftModal] coordinator.isPresentationInProgress: \(coordinator.isPresentationInProgress)")
        
        guard let rootViewController = windowProvider.rootViewController() else {
            print("[PhaseShiftModal] No root view controller found")
            return
        }
        
        let topMostViewController = rootViewController.topMostViewController()
        let isTopMostModal = ModalViewControllerIdentifier.isPhaseShiftModal(topMostViewController)
        
        print("[PhaseShiftModal] topMostViewController: \(type(of: topMostViewController))")
        print("[PhaseShiftModal] isTopMostModal: \(isTopMostModal)")
        
        if isTopMostModal && coordinator.isPresenting {
            if isPresented {
                print("[PhaseShiftModal] Modal already presented, skipping")
                return
            } else {
                print("[PhaseShiftModal] Dismissing modal")
                Task { @MainActor in
                    coordinator.dismiss()
                }
                return
            }
        }
        
        Task { @MainActor in
            if isPresented {
                print("[PhaseShiftModal] isPresented is true, checking if can present")
                if !coordinator.isPresenting && !coordinator.isPresentationInProgress {
                    print("[PhaseShiftModal] Calling coordinator.present()")
                    print("[PhaseShiftModal] sourceFrame: \(sourceFrame)")
                    coordinator.present(
                        content: modalContent(),
                        sourceFrame: sourceFrame,
                        configuration: configuration,
                        from: topMostViewController,
                        onDismiss: {
                            Task { @MainActor in
                                self.isPresented = false
                            }
                        }
                    )
                } else {
                    print("[PhaseShiftModal] Cannot present - isPresenting: \(coordinator.isPresenting), isPresentationInProgress: \(coordinator.isPresentationInProgress)")
                }
            } else {
                print("[PhaseShiftModal] isPresented is false")
                if coordinator.isPresenting {
                    print("[PhaseShiftModal] Dismissing coordinator")
                    coordinator.dismiss()
                }
            }
            
            coordinator.updatePresentationState(
                isPresented: isPresented,
                presentingViewController: topMostViewController
            )
        }
    }
}

// MARK: - View Extension

extension View {
    /// Presents a modal with a custom phase shift transition animation.
    ///
    /// Use this modifier to present a modal that animates from a source frame to full screen.
    /// The modal will reverse the animation when dismissed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var isPresented = false
    ///     @State private var itemFrame: CGRect = .zero
    ///
    ///     var body: some View {
    ///         Button("Show Modal") {
    ///             isPresented = true
    ///         }
    ///         .phaseShiftModal(
    ///             isPresented: $isPresented,
    ///             sourceFrame: itemFrame
    ///         ) {
    ///             ModalContentView()
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - isPresented: Binding that controls the presentation state.
    ///   - sourceFrame: The frame in window coordinates where the modal should animate from/to.
    ///   - configuration: The animation configuration. Defaults to `.default`.
    ///   - content: A closure that returns the SwiftUI view to display in the modal.
    ///
    /// - Returns: A view with the phase shift presentation modifier applied.
    public func phaseShiftModal<Content: View>(
        isPresented: Binding<Bool>,
        sourceFrame: CGRect,
        configuration: PhaseShiftConfiguration = .default,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(PhaseShiftModal(
            isPresented: isPresented,
            sourceFrame: sourceFrame,
            modalContent: content,
            configuration: configuration
        ))
    }
}

