//
//  GuideVC.swift
//  adimvi
//
//  Created by Aira on 29.11.2021.
//  Copyright © 2021 webdesky.com. All rights reserved.
//

import UIKit

class GuideVC: UIViewController {

    @IBOutlet weak var btnClose: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var guideCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnClose.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClose)))
        guideCV.register(UINib(nibName: "GuideCell", bundle: nil), forCellWithReuseIdentifier: "GuideCell")
        guideCV.delegate = self
        guideCV.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageControl.subviews.forEach { (item) in
            item.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }
    }
    
    @objc func didTapClose() {
        UserDefaults.standard.setValue(true, forKey: "PassedGuide")
        self.dismiss(animated: true, completion: nil)
    }

}

//MARK: - Collection view delegate & datasource
extension GuideVC: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}

extension GuideVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return APPGUIDES.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GuideCell", for: indexPath) as! GuideCell
        let model = APPGUIDES[indexPath.row]
        cell.configCell(model: model)
        return cell
    }
    
    
}

extension GuideVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
