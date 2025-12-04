import UIKit

// MARK: - UIViewController Extension

extension UIViewController {
    /// Returns the topmost view controller in the view controller hierarchy.
    ///
    /// This method recursively traverses the view controller hierarchy to find the
    /// topmost view controller, handling navigation controllers, tab bar controllers,
    /// and presented view controllers.
    ///
    /// - Returns: The topmost view controller in the hierarchy.
    public func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? self
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? self
        }
        
        return self
    }
}

