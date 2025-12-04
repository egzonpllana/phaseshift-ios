import SwiftUI
import PhaseShift

/// Example view demonstrating fullscreen modal presentation with navigation.
///
/// The modal presents from a source frame, pushes to a detail screen,
/// and provides both dismiss and pop back functionality.
struct SwiftUIExampleNavigationStackView: View {
    @State private var isModalPresented = false
    @State private var sourceButtonFrame: CGRect = .zero
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("Fullscreen Modal Example")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Tap the button below to present a fullscreen modal")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    print("[FullscreenModalExample] Button tapped")
                    print("[FullscreenModalExample] Current sourceButtonFrame: \(sourceButtonFrame)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        print("[FullscreenModalExample] Setting isModalPresented = true")
                        print("[FullscreenModalExample] sourceButtonFrame at presentation: \(sourceButtonFrame)")
                        isModalPresented = true
                    }
                }) {
                    Text("Present Modal")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .phaseShiftFrame(frame: $sourceButtonFrame)
            }
            .navigationTitle("Modal Example")
            .navigationBarTitleDisplayMode(.large)
            .phaseShiftModal(
                isPresented: $isModalPresented,
                sourceFrame: sourceButtonFrame
            ) {
                FullscreenModalContentView()
            }
        }
    }
}

/// Content view for the fullscreen modal with navigation support.
struct FullscreenModalContentView: View {
    @Environment(\.dismissPhaseShift) private var dismissPhaseShift
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Modal Content")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("This is the first screen in the modal")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        navigationPath.append("detail")
                    }) {
                        Text("Push to Detail Screen")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        dismissPhaseShift?()
                    }) {
                        Text("Dismiss Modal")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Modal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { destination in
                if destination == "detail" {
                    FullscreenModalDetailView()
                }
            }
        }
    }
}

/// Detail view that can be pushed onto the navigation stack.
///
/// Provides both dismiss modal and pop back functionality.
struct FullscreenModalDetailView: View {
    @Environment(\.dismissPhaseShift) private var dismissPhaseShift
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Detail Screen")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("This is the detail screen pushed onto the navigation stack")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    dismissPhaseShift?()
                }) {
                    Text("Dismiss Whole Modal")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Pop Back")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SwiftUIExampleNavigationStackView()
}

