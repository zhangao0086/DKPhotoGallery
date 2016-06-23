//
//  DKPhotoGallery.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 15/7/20.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

@objc
public class DKPhotoGallery: UINavigationController, UIViewControllerTransitioningDelegate {
	
	public var fromImageView: UIImageView?
	
	internal weak var contentVC: DKPhotoGalleryContentVC!
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.blackColor()
		
		if let _ = self.fromImageView {
			self.transitioningDelegate = self
		}
		
		self.navigationBarHidden = true
		
		let contentVC = DKPhotoGalleryContentVC()
		self.viewControllers = [contentVC]
		
		contentVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(DKPhotoGallery.dismiss))
		
		let gesture = UITapGestureRecognizer(target: self, action: #selector(DKPhotoGallery.toggleNavigationBar))
		contentVC.view.addGestureRecognizer(gesture)
		
		self.contentVC = contentVC
	}
	
	func dismiss() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func toggleNavigationBar() {
		self.setNavigationBarHidden(!self.navigationBarHidden, animated: true)
	}
	
	// UIViewControllerTransitioningDelegate
	
	public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return DKPhotoGalleryTransitionPresent(imageBrowserVC: self)
	}
	
	public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return DKPhotoGalleryTransitionDismiss(imageBrowserVC: self)
	}
	
}