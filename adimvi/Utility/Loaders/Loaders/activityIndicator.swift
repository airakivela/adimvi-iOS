
//  activityIndicator.swift
//  demoLogin
//  Created by Mac on 27/10/2017 .
//  Copyright © 2017 Mindiii. All rights reserved.


import UIKit
class activityIndicator {
    
    var activityIndicatorImage : UIImageView!
    var backView: UIView!
    var window = UIApplication.shared.keyWindow
    
    func startActivityIndicator() -> Void {
        window = UIWindow(frame: UIScreen.main.bounds)
        let gifManager = SwiftyGifManager(memoryLimit:20)
        if UIDevice.current.userInterfaceIdiom == .pad {
            let gif = UIImage(gifName: "load.gif")
            self.activityIndicatorImage = UIImageView(gifImage: gif, manager: gifManager)
            activityIndicatorImage.backgroundColor = UIColor.clear
            activityIndicatorImage.clipsToBounds = true
            activityIndicatorImage.layer.cornerRadius = 10
            activityIndicatorImage.frame = CGRect(x: 170.0, y: 265, width: 100, height: 100)
            
        } else {
            let gif = UIImage(gifName: "load.gif")
            self.activityIndicatorImage = UIImageView(gifImage: gif, manager: gifManager)
            activityIndicatorImage.backgroundColor = UIColor.clear
            activityIndicatorImage.clipsToBounds = true
            activityIndicatorImage.layer.cornerRadius = 10
            activityIndicatorImage.frame = CGRect(x: 170.0, y: 265, width: 60, height: 60)
        }
        
        backView = UIView(frame: window!.frame)
        backView!.alpha = 0.5
        backView!.center = window!.center
        let gradient = CAGradientLayer()
        gradient.frame = backView!.bounds
        gradient.colors = [UIColor.black.cgColor,UIColor.white.cgColor]
        gradient.locations=[0.0,1.0]
        gradient.startPoint=CGPoint(x: 0, y: 10)
        gradient.endPoint=CGPoint(x: 0, y: backView!.bounds.height/2.5)
        backView!.layer.insertSublayer(gradient,at: 0)
        activityIndicatorImage!.center = window!.center
        window!.addSubview(backView!)
        window!.addSubview(activityIndicatorImage!)
        window!.makeKeyAndVisible()
    }
    
    func rotatImage(layer:CALayer) -> Void {
        var rotation: CABasicAnimation!
        rotation = CABasicAnimation(keyPath:"transform.rotation")
        rotation.fromValue = NSNumber(value: 0)
        rotation.toValue = NSNumber(value: (Float(2*Double.pi)))
        rotation.duration = 1.0
        rotation.repeatCount = Float(Double.infinity)
        layer.removeAllAnimations()
        layer.add(rotation, forKey: "Spin")
    }
    
    func stopActivity() -> Void {
        if activityIndicatorImage != nil{
            activityIndicatorImage.removeFromSuperview();
            backView.removeFromSuperview();
            window?.resignKey()
            activityIndicatorImage=nil;
            backView=nil
            window = nil
            
        }
    }
}
