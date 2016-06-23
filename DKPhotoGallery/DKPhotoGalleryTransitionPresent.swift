//
//  DKPhotoGalleryTransitionPresent.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 16/6/22.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

@objc
public class DKPhotoGalleryTransitionPresent: NSObject, UIViewControllerAnimatedTransitioning {
	
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
		let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! DKPhotoGallery
		let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
		
		let snapshotImageView = UIImageView()
		
		let fromImageView = self.imageBrowserVC.fromImageView!
		
		toViewController.view.alpha = 0
		containerView.insertSubview(toViewController.view, aboveSubview: fromViewController.view)
		
		snapshotImageView.image = fromImageView.image
		snapshotImageView.frame = fromImageView.frame
		snapshotImageView.contentMode = fromImageView.contentMode
		
		containerView.addSubview(snapshotImageView)
		fromImageView.hidden = true
		
		UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
			snapshotImageView.contentMode = .ScaleAspectFit
			snapshotImageView.frame = self.imageBrowserVC.view.bounds
		}, completion: ({completed in
			UIView.animateWithDuration(0.2, animations: {
				toViewController.view.alpha = 1
			}, completion: { (completed) in
				fromImageView.hidden = false

				snapshotImageView.removeFromSuperview()
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
			})
		}))
	}
	
}