import SwiftUI
import PhaseShift

/// Example SwiftUI content view for UIKit modal presentation.
struct UIKitModalContentView: View {
    let itemIndex: Int
    @Environment(\.dismissPhaseShift) private var dismissPhaseShift
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Item \(itemIndex + 1)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("This modal was presented from the UIKit collection grid")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        navigationPath.append("detail")
                    }) {
                        Text("Push Detail View")
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
                        Text("Dismiss")
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
            .navigationTitle("Modal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { destination in
                if destination == "detail" {
                    UIKitModalDetailView(itemIndex: itemIndex)
                }
            }
        }
    }
}

/// Detail view that can be pushed onto the navigation stack.
struct UIKitModalDetailView: View {
    let itemIndex: Int
    @Environment(\.dismissPhaseShift) private var dismissPhaseShift
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Detail View")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("This is a detail view pushed onto the navigation stack")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("Item Index: \(itemIndex + 1)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
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
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

