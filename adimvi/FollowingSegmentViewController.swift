
//  FollowingSegmentViewController.swift
//  adimvi
//  Created by javed carear  on 16/10/19.
//  Copyright © 2019 webdesky.com. All rights reserved.

import UIKit
class FollowingSegmentViewController: UIViewController {
    @IBOutlet weak var ContainerWall: UIView!
    @IBOutlet weak var ContainerPublication: UIView!
    @IBOutlet weak var ContainerTag: UIView!
    @IBOutlet weak var segmentFollowing: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentFollowing.selectedSegmentIndex = 0
        segmentFollowing.addTarget(self, action: #selector(FollowingSegmentViewController.indexChanged(_:)), for: .valueChanged)
        self.view.addSubview(segmentFollowing)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.tabBarController?.tabBar.items![1].badgeValue = nil
        UserDefaults.standard.setValue(false, forKey: "HASNEWPOST")
        
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
//        let childPublicationVC = ContainerPublication.viewContainingController() as? FollowersVc
//        
//        childPublicationVC!.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "followersVC" {
            let vc = segue.destination as? FollowersVc
            vc?.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func OnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            ContainerPublication.isHidden = false
            ContainerWall.isHidden = true
            ContainerTag.isHidden = true
            
            return
            
        case 1:
            ContainerPublication.isHidden = true
            ContainerWall.isHidden = false
            ContainerTag.isHidden = true
            
            return
        case 2:
            ContainerPublication.isHidden = true
            ContainerWall.isHidden = true
            ContainerTag.isHidden = false
            
            return
            
        default:
            break
        }
    }
}

extension FollowingSegmentViewController: FollowersVCDelegate {
    func onShowRefreshController(isShowing: Bool) {
        self.segmentFollowing.isHidden = isShowing
    }
}
