import UIKit

internal extension UIViewController {
    func maybePop() {
        guard !(self.navigationController?.viewControllers.isEmpty ?? true) else {
            return
        }
        
        if self.navigationController!.viewControllers.count <= 1 && self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
