
//  ImageLoadOperation.swift


import UIKit
 typealias ImageLoadOperationCompletionHandlerType = ((UIImage) -> ())?

//class ImageLoadOperation: Operation {
//    var url: String
//    var completionHandler: ImageLoadOperationCompletionHandlerType
//    var image: UIImage?
//
////    init(url: String) {
////        self.url = url
////    }
//    override func main() {
//        if isCancelled {
//            return
//        }

//        UIImage.downloadImageFromUrl(url) { [weak self] (image) in
//            guard let strongSelf = self,
//                !strongSelf.isCancelled,
//                let image = image else {
//                return
//            }
//            strongSelf.image = image
//            strongSelf.completionHandler?(image)
//        }
  //  }
//}
