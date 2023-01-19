//
//  StoreVC.swift
//  adimvi
//
//  Created by javed carear  on 17/06/19.
//  Copyright © 2019 webdesky.com. All rights reserved.
//

import UIKit

struct store {
    var image = UIImage()
    var title = String()
    var descriptions = String()
    
}

class StoreVC: BaseViewController {
    var arrStore  = [store]()
    

    @IBOutlet weak var collectionStore: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //arrStore = [store(image: UIImage(named: ""), title: "<#T##String#>", descriptions: <#T##String#>) , store(image: <#T##UIImage#>, title: <#T##String#>, descriptions: <#T##String#>)]
      //self.navigationItem.titleView = self.setNavigationTitleView()
    }

}

//Mark:- Collection view delegate methods
extension StoreVC:UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
// Mark:- Collection view data source and layout menthods
extension StoreVC:UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreCVCell", for: indexPath) as! StoreCVCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.collectionStore.frame.size.width / 2
        
        let height = self.collectionStore.frame.size.height / 3
        
        return CGSize(width: width - 20, height: height - 20)
        
    }
    
    
}

class StoreCVCell: UICollectionViewCell {
    
}
