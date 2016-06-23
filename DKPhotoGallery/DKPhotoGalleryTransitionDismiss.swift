//
//  DKPhotoGalleryTransitionDismiss.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 16/6/22.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

@objc
public class DKPhotoGalleryTransitionDismiss: NSObject, UIViewControllerAnimatedTransitioning {
	
	var imageBrowserVC: DKPhotoGallery!
	
	init(imageBrowserVC: DKPhotoGallery) {
		super.init()
		
		self.imageBrowserVC = imageBrowserVC
	}
	
	// UIViewControllerAnimatedTransitioning
	
	public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return 0.25
	}
	
	public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView()!
		let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
		let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
		
		let snapshotImageView = UIImageView()
		
		var fromImageView: UIImageView!
		var toImageView: UIImageView!
		
		containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
		fromImageView = self.imageBrowserVC.contentVC.currentImageView()
		toImageView = self.imageBrowserVC.fromImageView
		
		snapshotImageView.image = fromImageView.image
		snapshotImageView.frame = fromImageView.frame
		snapshotImageView.contentMode = fromImageView.contentMode
		
		containerView.addSubview(snapshotImageView)
		
		fromImageView.hidden = true
		UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
			fromViewController.view.alpha = 0
			snapshotImageView.frame = toImageView.frame
		}, completion: ({completed in
			
//			UIView.animateWithDuration(0.2, animations: {
//				snapshotImageView.alpha = 0
//				self.imageBrowserVC.view.alpha = 1
//			}, completion: { (completed) in
//				self.imageBrowserVC.view.alpha = 1
				snapshotImageView.removeFromSuperview()
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
//			})
		}))
	}
	
}