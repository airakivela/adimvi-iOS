//  ButtonBarExampleViewController.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2017 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import TwitterProfile
import XLPagerTabStrip

protocol XLPagerDelegate {
    func didChangeScroll()
}

class XLPagerTabStripExampleViewController: ButtonBarPagerTabStripViewController, PagerAwareProtocol {
    
    //MARK: PagerAwareProtocol
    weak var pageDelegate: BottomPageDelegate?
    var currentViewController: UIViewController?{
        return viewControllers[currentIndex]
    }
    
    var pagerTabHeight: CGFloat?{
        return 30
    }
    
    //MARK: Properties
    var isReload = false
    var isFromPostDetail: Bool?
    var isFromOriginalWall: Bool?
    var isFromNotificationPost: Bool?
    var originalPostData: [String: Any] = [String: Any]()
    
    var scrollDelegate: XLPagerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        settings.style.buttonBarBackgroundColor = .background
        settings.style.buttonBarItemBackgroundColor = .background
        settings.style.selectedBarBackgroundColor = Colors.twitterBlue!
        settings.style.buttonBarItemTitleColor = Colors.twitterBlue
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarItemFont = UIFont.boldSystemFont(ofSize: 15.0)
    }
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        self.changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            oldCell?.label.textColor = Colors.twitterGray
            newCell?.label.textColor = Colors.twitterBlue
        }
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let vc = UIStoryboard.init(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.pageIndex = 0
        vc.pageTitle = "Perfil"
        let child_1 = vc
        let vc4 = UIStoryboard.init(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "WallPostViewController") as! WallPostViewController
        vc4.pageIndex = 1
        vc4.pageTitle = "Muro"
        vc4.isFromPostDetail = isFromPostDetail!
        vc4.originalPostData = self.originalPostData
        let child_2 = vc4
        let vc3 = UIStoryboard.init(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "PublicationViewController") as! PublicationViewController
        vc3.pageIndex = 2
        vc3.pageTitle = "Posts"
        let child_3 = vc3
        let vc1 = UIStoryboard.init(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "FollowersListViewController") as! FollowersListViewController
        vc1.pageIndex = 3
        vc1.pageTitle = "Seguidores"
        let child_4 = vc1
        let vc2 = UIStoryboard.init(name: "TabViewController", bundle: nil).instantiateViewController(withIdentifier: "FollowingViewController") as! FollowingViewController
        vc2.pageIndex = 4
        vc2.pageTitle = "Siguiendo"
        let child_5 = vc2
        if isFromPostDetail! || ISREWALL || isFromNotificationPost! {
            pagerTabStripController.currentIndex = 1
        }
        return [child_1, child_2, child_3, child_4, child_5]
    }
    
    override func reloadPagerTabStripView() {
        pagerBehaviour = .progressive(skipIntermediateViewControllers: arc4random() % 2 == 0, elasticIndicatorLimit: arc4random() % 2 == 0 )
        super.reloadPagerTabStripView()
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        guard indexWasChanged == true else { return }
        //IMPORTANT!!!: call the following to let the master scroll controller know which view to control in the bottom section
        self.pageDelegate?.tp_pageViewController(self.currentViewController, didSelectPageAt: toIndex)
        
    }
    
}
