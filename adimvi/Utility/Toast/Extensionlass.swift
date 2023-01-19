

import Foundation
import UIKit

extension UIViewController {
    
     func showToastIMsg(type:String,strMSG:String) {
        self.view.makeToast(message: strMSG,
                            duration: TimeInterval(9000.0),
                            position: .top,
                            image: nil,
                            backgroundColor: UIColor.lightGray.withAlphaComponent(0.5),
                            titleColor: UIColor.yellow,
                            messageColor: UIColor.white,
                            font: nil)
    }

}
