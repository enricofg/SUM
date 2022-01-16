import UIKit

@IBDesignable
var viewController: UITabBar {
        switch self {
        case .calls:
            return StopsViewController()
    
        case .contacts:
            return BusViewController()
case .photos:
            return ARViewController()
        
        }
    }
    // these can be your icons
    var icon: UIImage {
        switch self {
        case .calls:
            return UIImage(named: "ic_phone")!
        
        case .photos:
            return UIImage(named: "ic_camera")!
case .contacts:
            return UIImage(named: "ic_contacts")!
        }
    }
var displayTitle: String {
        return self.rawValue.capitalized(with: nil)
    }
}
