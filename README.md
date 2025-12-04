# PhaseShift

![PhaseShiftiOSSDKCoverImage](https://github.com/egzonpllana/phaseshift-ios/blob/main/%20phase-shift-ios-sdk-cover.png)

PhaseShift is a lightweight Swift Package providing elegant modal presentation with custom phase shift transition animations. The modal smoothly transitions from a source frame (e.g., a tapped item) to full screen, and reverses the animation when dismissing.

> The name **PhaseShift** represents the package's ability to seamlessly transition views between different phases or states. Just as a phase shift in physics describes a change in the state of a wave, this package enables smooth, elegant transitions between view states, creating a fluid and intuitive user experience.

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.9%2B-orange">
    <img src="https://img.shields.io/badge/iOS-16.0%2B-blue">
</p>

#### Elegant and type-safe API

```swift
.phaseShiftModal(
    isPresented: $isPresented,
    sourceFrame: itemFrame
) {
    ModalContentView()
}
```

## Features

💡 **Type-Safe API Calls** – Strongly typed SwiftUI and UIKit APIs.  
⚡️ **Smooth Animations** – Spring-based transitions with customizable parameters.  
🎯 **Frame-Based Transitions** – Animates from any source frame to full screen.  
🔄 **Bidirectional Animations** – Smooth presentation and dismissal transitions.  
🧩 **SwiftUI & UIKit Support** – Works seamlessly in both SwiftUI and UIKit projects.  
🧾 **Navigation Support** – Full navigation stack support within modals.

## Requirements

- iOS 16.0+
- Swift 5.9+
- SwiftUI

## Installation

### Swift Package Manager

Add PhaseShift to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/egzonpllana/phaseshift-ios", from: "1.0.0")
]
```

Or add it via Xcode: **File** → **Add Package Dependencies...**

### Import

```swift
import PhaseShift
```

## Usage

### SwiftUI Usage

#### Basic Example - Single Frame

For tracking a single view (like a button):

```swift
import SwiftUI
import PhaseShift

struct ContentView: View {
    @State private var isPresented = false
    @State private var buttonFrame: CGRect = .zero
    
    var body: some View {
        Button("Present Modal") {
            isPresented = true
        }
        .phaseShiftFrame(frame: $buttonFrame)
        .phaseShiftModal(
            isPresented: $isPresented,
            sourceFrame: buttonFrame
        ) {
            ModalContentView()
        }
    }
}
```

#### Basic Example - Collection/Grid

For tracking multiple items in a collection or grid:

```swift
import SwiftUI
import PhaseShift

struct ContentView: View {
    @State private var isPresented = false
    @State private var itemFrames: [Int: CGRect] = [:]
    @State private var selectedItemIndex: Int?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(0..<10, id: \.self) { index in
                    PhaseShiftFrameTracker(id: index) {
                        Button(action: {
                            selectedItemIndex = index
                            isPresented = true
                        }) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.2))
                                .overlay {
                                    Text("\(index + 1)")
                                }
                        }
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .phaseShiftFrames(frames: $itemFrames)
        }
        .phaseShiftModal(
            isPresented: $isPresented,
            sourceFrame: selectedItemFrame
        ) {
            if let index = selectedItemIndex {
                ModalContentView(itemIndex: index)
            }
        }
    }
    
    private var selectedItemFrame: CGRect {
        guard let index = selectedItemIndex,
              let frame = itemFrames[index] else {
            return .zero
        }
        return frame
    }
}
```

#### Frame Tracking APIs

**Single Frame Tracking** (No ID needed):
```swift
Button("Present Modal") {
    isPresented = true
}
.phaseShiftFrame(frame: $buttonFrame)
```

**Collection Frame Tracking**:
```swift
LazyVGrid(columns: columns) {
    ForEach(0..<items.count, id: \.self) { index in
        PhaseShiftFrameTracker(id: index) {
            ItemView(index: index)
        }
    }
}
.phaseShiftFrames(frames: $itemFrames)
```

#### Understanding PhaseShiftFrameTracker

`PhaseShiftFrameTracker` is a wrapper view that simplifies frame tracking for collection items. Instead of manually adding `GeometryReader` and `PreferenceKey` code to each item, you simply wrap your content:

**Before (Manual Approach):**
```swift
ForEach(0..<items.count, id: \.self) { index in
    ItemView(index: index)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: PhaseShiftFramePreferenceKey.self,
                        value: [index: geometry.frame(in: .global)]
                    )
            }
        )
}
.onPreferenceChange(PhaseShiftFramePreferenceKey.self) { frames in
    itemFrames = frames
}
```

**After (With PhaseShiftFrameTracker):**
```swift
ForEach(0..<items.count, id: \.self) { index in
    PhaseShiftFrameTracker(id: index) {
        ItemView(index: index)
    }
}
.phaseShiftFrames(frames: $itemFrames)
```

**Key Benefits:**
-  Eliminates boilerplate code
-  Cleaner, more readable syntax
-  Automatic frame updates
-  Works seamlessly with `LazyVGrid`, `LazyHGrid`, `List`, etc.

**Important Notes:**
- Each `PhaseShiftFrameTracker` must have a unique `id` (typically the item's index)
- Apply `.phaseShiftFrames(frames:)` to the container view (not individual items)
- Frames are automatically updated when views are laid out or scrolled

#### Dismissing from Modal Content

The `dismissPhaseShift` environment value is automatically available:

```swift
struct ModalContentView: View {
    @Environment(\.dismissPhaseShift) private var dismissPhaseShift
    
    var body: some View {
        VStack {
            Text("Modal Content")
            
            Button("Dismiss") {
                dismissPhaseShift?()
            }
        }
    }
}
```

### UIKit Usage

#### Presenting SwiftUI Views

```swift
import UIKit
import SwiftUI
import PhaseShift

class MyViewController: UIViewController {
    func presentModal(from frame: CGRect) {
        let contentView = MySwiftUIView()
        
        PhaseShiftPresentation.present(
            from: self,
            sourceFrame: frame,
            content: contentView
        )
    }
}
```

#### Presenting UIKit View Controllers

```swift
class MyViewController: UIViewController {
    func presentModal(from frame: CGRect) {
        let detailVC = DetailViewController()
        let navController = UINavigationController(rootViewController: detailVC)
        
        PhaseShiftPresentation.present(
            from: self,
            sourceFrame: frame,
            contentViewController: navController
        )
    }
}
```

#### Getting Frame from UIView

PhaseShift provides a convenient extension for getting frames:

```swift
// Get frame in window coordinates
let frame = myButton.frameInWindow()

PhaseShiftPresentation.present(
    from: self,
    sourceFrame: frame,
    content: MySwiftUIView()
)
```

The `frameInWindow()` method is automatically available on all `UIView` instances when you import PhaseShift.

## API Reference

### SwiftUI API

#### `phaseShiftModal(isPresented:sourceFrame:content:)`

Presents a modal with custom phase shift transition.

**Parameters:**
- `isPresented: Binding<Bool>` - Controls the presentation state
- `sourceFrame: CGRect` - Frame in window coordinates for animation origin
- `content: () -> Content` - Closure returning the SwiftUI view to display

#### `phaseShiftFrame(frame:)`

Tracks a single view's frame for modal presentation. No ID required.

**Parameters:**
- `frame: Binding<CGRect>` - Binding that receives the tracked frame

#### `phaseShiftFrame(id:frame:)`

Tracks a view's frame with an ID (for collections).

**Parameters:**
- `id: Int` - Unique identifier for this frame
- `frame: Binding<CGRect>` - Binding that receives the tracked frame

#### `PhaseShiftFrameTracker(id:content:)`

Wrapper view that automatically tracks a view's frame (for collections).

`PhaseShiftFrameTracker` is a helper view that wraps your content and automatically handles frame tracking using `GeometryReader` and `PreferenceKey`. It eliminates the need for manual frame tracking boilerplate when working with collections or grids.

**When to use:**
- Tracking multiple items in a `LazyVGrid` or `LazyHGrid`
- Tracking items in a `List` or `ScrollView`
- Any scenario where you need to track multiple frames with unique IDs

**How it works:**
1. Wrap each item's content with `PhaseShiftFrameTracker(id:)`
2. Apply `.phaseShiftFrames(frames:)` to the container (grid/list)
3. All frames are automatically collected into the `frames` dictionary

**Example:**
```swift
@State private var itemFrames: [Int: CGRect] = [:]
@State private var selectedIndex: Int?

LazyVGrid(columns: columns) {
    ForEach(0..<items.count, id: \.self) { index in
        PhaseShiftFrameTracker(id: index) {
            ItemView(index: index)
                .onTapGesture {
                    selectedIndex = index
                    isPresented = true
                }
        }
    }
}
.phaseShiftFrames(frames: $itemFrames)
```

**Parameters:**
- `id: Int` - Unique identifier for this item's frame (typically the item's index)
- `content: () -> Content` - The view content to track (use `@ViewBuilder` syntax)

#### `phaseShiftFrames(frames:)`

Collects multiple frames from child `PhaseShiftFrameTracker` views.

**Parameters:**
- `frames: Binding<[Int: CGRect]>` - Binding that receives all tracked frames

### UIKit API

#### `PhaseShiftPresentation.present(from:sourceFrame:content:)`

Presents a SwiftUI view as a modal from a UIViewController.

**Parameters:**
- `from: UIViewController` - The view controller to present from
- `sourceFrame: CGRect` - Frame in window coordinates for animation origin
- `content: Content` - The SwiftUI view to display

#### `PhaseShiftPresentation.present(from:sourceFrame:contentViewController:)`

Presents a UIKit view controller as a modal.

**Parameters:**
- `from: UIViewController` - The view controller to present from
- `sourceFrame: CGRect` - Frame in window coordinates for animation origin
- `contentViewController: UIViewController` - The view controller to display (supports UINavigationController)

### Environment Values

#### `dismissPhaseShift: (() -> Void)?`

Environment value available in modal content views to dismiss the modal programmatically.

## Examples

Complete working examples are available in the `Examples/` directory:

- **SwiftUI Collection Grid Example** (`Examples/SwiftUIExamples/SwiftUIExampleCollectionGridView.swift`) - Collection grid with modal presentation
- **SwiftUI Navigation Stack Example** (`Examples/SwiftUIExamples/SwiftUIExampleNavigationStackView.swift`) - Fullscreen modal with navigation support
- **UIKit Collection Grid Example** (`Examples/UIKitExamples/UIKitCollectionGridViewController.swift`) - UIKit-only implementation with collection grid

All examples demonstrate:
- Frame tracking using `PhaseShiftFrameTracker` and `.phaseShiftFrame()`
- Modal presentation with phase shift transitions
- Navigation within modals
- Dismissal handling

## Notes

- The `sourceFrame` must be in **window coordinates** (automatically handled by frame tracking APIs)
- Use `.phaseShiftFrame(frame:)` for single views (no ID needed)
- Use `PhaseShiftFrameTracker` + `.phaseShiftFrames(frames:)` for collections
- The modal uses `.custom` presentation style for full control over transitions
- Navigation within the modal is fully supported
- Frame tracking APIs handle all the GeometryReader/PreferenceKey boilerplate automatically

## License

PhaseShift is released under the MIT license. See LICENSE for details.
