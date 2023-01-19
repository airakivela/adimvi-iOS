 
//  TransitionAnimator.swift
//  ESaraswati
//
//  Created by Ripples on 06/07/18.
//  Copyright © 2018 Ripples. All rights reserved.
//
import UIKit

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    let durationExpanding = 0.5
    let durationClosing = 0.5
    var presenting = true
    var originFrame = CGRect.zero
    var dismissCompletion: (()->Void)?
    var view = UIView()
    

    func presentControllerWithAnimation(view:UIView , toPresent: UIViewController)  {
        self.view = view
        toPresent.transitioningDelegate = self
    }
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let originFrame = self.view.superview?.convert(self.view.frame, to: nil) else {
            return self
        }
        self.originFrame = originFrame
        self.presenting = true
//        self.isHidden = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
//        selectedCell.isHidden = false
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if presenting {
            return durationExpanding
        }
        return durationClosing
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to), let detailView = presenting ? toView: transitionContext.view(forKey: .from) else {
            return
        }

        let initialFrame = presenting ? originFrame : detailView.frame
        let finalFrame = presenting ? detailView.frame : originFrame
        let xScaleFactor = presenting ? initialFrame.width / finalFrame.width : finalFrame.width / initialFrame.width
        let yScaleFactor = presenting ? initialFrame.height / finalFrame.height : finalFrame.height / initialFrame.height
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor,
                                               y: yScaleFactor)

        if presenting {
            detailView.transform = scaleTransform
            detailView.center = CGPoint( x: initialFrame.midX, y: initialFrame.midY)
            detailView.clipsToBounds = true
        }

        containerView.addSubview(toView)
        containerView.bringSubviewToFront(detailView)

        if presenting {
            //update opening animation
            UIView.animate(withDuration: durationExpanding, delay:0.0,
                           usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, //gives it some bounce to make the transition look neater than if you have defaults
                animations: {
                    detailView.transform = CGAffineTransform.identity
                    detailView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                },
                completion:{_ in
                    transitionContext.completeTransition(true)
                }
            )
        } else {
            //update closing animation
            UIView.animate(withDuration: durationClosing, delay:0.0, options: .curveLinear,
                   animations: {
                        detailView.transform = scaleTransform
                        detailView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
                   },
                   completion:{_ in
                        if !self.presenting {
                            self.dismissCompletion?()
                        }
                        transitionContext.completeTransition(true)
                   }
            )
        }
    }

}
