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
            
            containerView.addSubview(snapshotImageView)
            
            fromView?.alpha = 0
            toImageView.isHidden = true
            UIView.animate(withDuration: transitionDuration, animations: {
                var toImageViewFrameInScreen = toImageView.superview!.convert(toImageView.frame, to: nil)
                snapshotImageView.contentMode = toImageView.contentMode
                let imageRect = self.imageFrame(toImageView.image!.size, toImageViewFrameInScreen, toImageView.contentMode)
                toImageViewFrameInScreen = CGRect(x: toImageViewFrameInScreen.origin.x + toImageViewFrameInScreen.width / 2 - imageRect.width / 2,
                                                  y: toImageViewFrameInScreen.origin.y + toImageViewFrameInScreen.height / 2 - imageRect.height / 2,
                                                  width: imageRect.width,
                                                  height: imageRect.height)
                snapshotImageView.transform = CGAffineTransform(a: toImageViewFrameInScreen.width / fromRect.width,
                                                                b: 0,
                                                                c: 0,
                                                                d: toImageViewFrameInScreen.height / fromRect.height,
                                                                tx: toImageViewFrameInScreen.origin.x - fromRect.origin.x + toImageViewFrameInScreen.width / 2 - fromRect.width / 2,
                                                                ty: toImageViewFrameInScreen.origin.y - fromRect.origin.y + toImageViewFrameInScreen.height / 2 - fromRect.height / 2)
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
    
    func imageFrame(_ imageSize: CGSize, _ boundingRect: CGRect, _ contentMode: UIViewContentMode) -> CGRect {
        let scales = self.imageScales(imageSize, boundingRect, contentMode)
        
        var imageFrame = CGRect(x: 0, y: 0, width: imageSize.width * scales.x, height: imageSize.height * scales.y)
        
        let center = CGPoint(x: (boundingRect.width - imageFrame.width) * 0.5,
                             y: (boundingRect.height - imageFrame.height) * 0.5)
        
        let top = CGFloat(0), left = CGFloat(0), right = boundingRect.width - imageFrame.width, bottom = boundingRect.height - imageFrame.height
        
        switch contentMode {
        case .redraw,
             .center,
             .scaleAspectFill,
             .scaleAspectFit,
             .scaleToFill:
            imageFrame.origin = center
        case .top:
            imageFrame.origin = CGPoint(x: center.x, y: 0)
        case .topLeft:
            imageFrame.origin = CGPoint(x: left, y: top)
        case .topRight:
            imageFrame.origin = CGPoint(x: right, y: top)
        case .bottom:
            imageFrame.origin = CGPoint(x: center.x, y: bottom)
        case .bottomLeft:
            imageFrame.origin = CGPoint(x: left, y: bottom)
        case .bottomRight:
            imageFrame.origin = CGPoint(x: right, y: bottom)
        case .left:
            imageFrame.origin = CGPoint(x: left, y: center.y)
        case .right:
            imageFrame.origin = CGPoint(x: right, y: center.y)
        }
        
        return imageFrame
    }
    
    func imageScales(_ imageSize: CGSize, _ boundingRect: CGRect, _ contentMode: UIViewContentMode) -> CGPoint {
        let scales = CGPoint(x: boundingRect.width / imageSize.width, y: boundingRect.height / imageSize.height)
        var resultScales = CGPoint.zero
        
        switch contentMode {
        case .scaleAspectFit:
            let scale = min(scales.x, scales.y)
            resultScales = CGPoint(x: scale, y: scale)
        case.scaleAspectFill:
            let scale = max(scales.x, scales.y)
            resultScales = CGPoint(x: scale, y: scale)
        case.scaleToFill:
            resultScales = scales
        default:
            resultScales = CGPoint(x: 1, y: 1)
        }
        
        if imageSize.width == 0 {
            resultScales.x = 1
        }
        
        if  imageSize.height == 0 {
            resultScales.y = 1
        }
        
        return resultScales
    }
	
}
