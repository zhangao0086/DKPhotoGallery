//
//  DKPhotoGalleryTransitionDismiss.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 16/6/22.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

@objc
open class DKPhotoGalleryTransitionDismiss: NSObject, UIViewControllerAnimatedTransitioning {
	
    var gallery: DKPhotoGallery!
    
	// UIViewControllerAnimatedTransitioning
	
	open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.25
	}
	
	open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let transitionDuration = self.transitionDuration(using: transitionContext)
        
		let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        
        self.gallery.setNavigationBarHidden(true, animated: true)
        
        if let toImageView = self.gallery.dismissImageViewBlock?(self.gallery.contentVC.currentIndex) {
            let fromImageView = self.gallery.currentImageView()
            let fromRect = fromImageView.frame
            
            let snapshotImageView = UIImageView(image: toImageView.image)
            snapshotImageView.contentMode = fromImageView.contentMode
            snapshotImageView.frame = fromRect
            snapshotImageView.clipsToBounds = true
            
            containerView.addSubview(snapshotImageView)
            
            fromView?.alpha = 0
            toImageView.isHidden = true
            UIView.animate(withDuration: transitionDuration, animations: {
                let toImageViewFrameInScreen = toImageView.superview!.convert(toImageView.frame, to: nil)
                snapshotImageView.contentMode = toImageView.contentMode
                snapshotImageView.frame = toImageViewFrameInScreen
            }) { (finished) in
                toImageView.isHidden = false
                snapshotImageView.removeFromSuperview()
                
                let wasCanceled = transitionContext.transitionWasCancelled
                if wasCanceled {
                    fromView?.alpha = 1
                }
                
                transitionContext.completeTransition(!wasCanceled)
            }
        } else {
            UIView.animate(withDuration: transitionDuration, animations: { 
                containerView.alpha = 0
            }, completion: { (finished) in
                let wasCanceled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCanceled)
            })
        }
	}
    	
}
