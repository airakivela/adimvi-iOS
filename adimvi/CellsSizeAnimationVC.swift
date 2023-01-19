//
//  CellsSizeAnimationVC.swift
//  FAPaginationLayout
//  Created by Fahid Attique on 14/06/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.

import UIKit

class CellsSizeAnimationVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet var collectionView: UICollectionView!
    
    let ArrayName = ["Tendencias","Recientes","Más votados","Más visitados","Más comentados"]
    
    let ArrayTitle = ["Descubre novedades y las publicaciones más populares que están circulando por toda la comunidad.",
                      "Entérate de lo último que se ha publicado y mantente siempre al día de lo que está pasando a tu alrededor.","¿Te gusta o no te gusta? Sumérgete entre las publicaciones que más cariño y likes han conseguido.","Explora entre los posts que más interés y views han generado entre personas de todo el mundo.","Hay publicaciones que han dado mucho de qué hablar últimamente, ¿te animas a comentar tú también?"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.numberOfPages = 5
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    private func viewConfigrations() {
        
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    func snapToCenter() {
        let centerPoint = view.convert(view.center, to: collectionView)
        
        let centerIndexPath = collectionView.indexPathForItem(at: centerPoint)!
        collectionView.scrollToItem(at: centerIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        snapToCenter()
    }
    
    
    func scrollToNextCell(){
        let cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let contentOffset = collectionView.contentOffset
        //scroll to next cell
        collectionView.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
        
    }
    
    func scrollToBackCell(){
        
        let cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let contentOffset = collectionView.contentOffset
        collectionView.scrollRectToVisible(CGRect(x: contentOffset.x - cellSize.width-1 ,y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
        
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x/scrollView.frame.width
        
        pageControl.currentPage = Int(page)
    }
}

//  Collection View FlowLayout Delegate & Data Source

extension CellsSizeAnimationVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ArrayName.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.collectionView.frame.size.width/1
        let height = self.collectionView.frame.size.height/1
        return CGSize(width: width - 0,height:height - 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.wallpaperImageView.image = UIImage(named: "\(indexPath.item)")
        cell.LabelName.text! = ArrayName[indexPath.item]
        cell.LabelTitle.text! = ArrayTitle[indexPath.item]
        
        cell.buttonTap.tag = indexPath.item
        cell.buttonTap.addTarget(self, action: #selector(self.tapAction(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonback.tag = indexPath.item
        cell.buttonback.addTarget(self, action: #selector(self.OnBack(_:)), for: UIControl.Event.touchUpInside)
        
        cell.buttonNext.tag = indexPath.item
        cell.buttonNext.addTarget(self, action: #selector(self.OnNext(_:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    
    
    
    @objc func OnBack(_ sender : UIButton) {
        scrollToBackCell()
        
    }
    
    @objc func OnNext(_ sender : UIButton) {
        scrollToNextCell()
    }
    
    @objc func tapAction(_ sender : UIButton) {
        switch sender.tag {
        case 0:
            let vc:MostActiveVC = self.storyboard?.instantiateViewController(withIdentifier: "MostActiveVC") as! MostActiveVC
            vc.hidesBottomBarWhenPushed = true
            vc.Webservice = "getMostTreandingPost"
            vc.SegmentType = "0"
            vc.labelTitle.title = "Tendencias"
            vc.Title = "Tendencias"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 1:
            let vc:MostActiveVC = self.storyboard?.instantiateViewController(withIdentifier: "MostActiveVC") as! MostActiveVC
            vc.hidesBottomBarWhenPushed = true
            vc.Webservice = "getRecentPost"
            vc.SegmentType = "0"
            vc.labelTitle.title = "Recientes"
            vc.Title = "Recientes"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2:
            let vc:MostActiveVC = self.storyboard?.instantiateViewController(withIdentifier: "MostActiveVC") as! MostActiveVC
            vc.hidesBottomBarWhenPushed = true
            vc.Webservice = "getMostVotedPost"
            vc.SegmentType = "0"
            vc.labelTitle.title = "Más votados"
            vc.Title = "Más votados"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 3:
            
            let vc:MostActiveVC = self.storyboard?.instantiateViewController(withIdentifier: "MostActiveVC") as! MostActiveVC
            vc.hidesBottomBarWhenPushed = true
            vc.Webservice = "getMostViewsPost"
            vc.SegmentType = "0"
            vc.labelTitle.title = "Más visitados"
            vc.Title = "Más visitados"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 4:
            let vc:MostActiveVC = self.storyboard?.instantiateViewController(withIdentifier: "MostActiveVC") as! MostActiveVC
            vc.hidesBottomBarWhenPushed = true
            vc.Webservice = "getMostCommentedPost"
            vc.SegmentType = "0"
            vc.labelTitle.title = "Más comentados"
            vc.Title = "Más comentados"
            self.navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
}
