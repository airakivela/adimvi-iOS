//
//  PageVC.swift
//  adimvi
//
//  Created by javed carear  on 15/06/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit

class PageVC: UIPageViewController {
    
    fileprivate lazy var pages:[UIViewController] = {
        return [
            self.getViewController(withIdentifier: "TabVC1") , self.getViewController(withIdentifier: "TabVC2") ,
                self.getViewController(withIdentifier: "TabVC3"),
                self.getViewController(withIdentifier: "TabVC4")
            ]
    }()
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: identifier)
        
    }
    
    var pageControl = UIPageControl()
    var skipButton = UIButton()
    var nextButton = UIButton()
    var i:Int = 1
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.dataSource = self
        self.delegate = self
        if let firstVC = pages.first{
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
       self.configurePageControl()
        self.configureSkipButtonAdd()
        self.configireNextButtonAdd()
        
        //self.nextButtonAdd()
    }
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = pages.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.init(named: "Dots")
        self.pageControl.pageIndicatorTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.pageControl.currentPageIndicatorTintColor = UIColor.init(named: "Dots")
        self.view.addSubview(pageControl)
    }
    
    func configureSkipButtonAdd(){
        skipButton.frame = CGRect(x: 0 , y: view.bounds.maxY - 50, width: 120, height: 45)
        skipButton.setTitleColor(.darkGray, for: .normal)
        skipButton.setTitle("Omitir", for: .normal)
        skipButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        skipButton.addTarget(self, action: #selector(actionSkip), for: .touchUpInside)
        
        self.skipButton.isHidden = true
        view.addSubview(skipButton)
    }
    
    @objc func actionSkip(){
       self.goToLoginVC()
    }
    
    func configireNextButtonAdd(){
        nextButton.frame = CGRect(x: (view.bounds.width - 120 )  , y: view.bounds.maxY - 50, width: 120, height: 45)
        nextButton.setTitleColor( .darkGray, for: .normal)
        nextButton.setTitle("Continuar", for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        nextButton.addTarget(self, action: #selector(actionNext), for: .touchUpInside)
        view.addSubview(nextButton)
    }
    
    @objc func actionNext(){
        
        if i == 4 {
           self.goToLoginVC()
        }else {
            setViewControllers([pages[i]], direction: .forward, animated: true, completion: nil)
            pageControl.currentPage = i
            i += 1
            
        }
       
    }
    
    func goToLoginVC(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
//        let detailVC = LoginVC()
//        detailVC.modalPresentationStyle = .fullScreen
//        present(detailVC, animated: true)
        
    }
   
}

extension PageVC : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.index(of: viewController) else {
            return nil
        }
        
       
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return nil }
        
        guard pages.count > previousIndex else { return nil        }
        
        if previousIndex == 0 {
            self.skipButton.isHidden = true
        }else {
            self.skipButton.isHidden = false
        }
        i -= 1
         pageControl.currentPage = previousIndex
        return pages[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil }
        
        guard pages.count > nextIndex else { return nil         }
         pageControl.currentPage = nextIndex
        
        if nextIndex == 0 {
            self.skipButton.isHidden = true
        }else if nextIndex == 4 {
            self.goToLoginVC()
        } else {
            self.skipButton.isHidden = false
        }
        i += 1
        return pages[nextIndex]
    }
}

extension PageVC : UIPageViewControllerDelegate {
    
}
