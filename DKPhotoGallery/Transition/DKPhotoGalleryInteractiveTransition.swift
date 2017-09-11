//
//  DKPhotoGalleryInteractiveTransition.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 09/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

class DKPhotoGalleryInteractiveTransition: UIPercentDrivenInteractiveTransition {

    private var gallery: DKPhotoGallery!
    
    private var fromImageView: UIImageView?
    private var fromRect: CGRect!
    
    internal var isInteracting = false
    private var percent: CGFloat = 0
    private var toImageView: UIImageView?
    
    convenience init(gallery: DKPhotoGallery) {
        self.init()
        
        self.gallery = gallery
        self.setupGesture()
    }
    
    private func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        self.gallery.visibleViewController?.view.addGestureRecognizer(panGesture)
    }
    
    @objc
    private func handleGesture(_ recognizer: UIPanGestureRecognizer) {
        let offset = recognizer.translation(in: recognizer.view?.superview)
        
        switch recognizer.state {
        case .began:
            self.isInteracting = true
            self.fromImageView = self.gallery.currentImageView()
            self.fromRect = self.fromImageView?.frame
            
            self.gallery.setNavigationBarHidden(true, animated: true)
            
            self.toImageView = self.gallery.dismissImageViewBlock?(self.gallery.currentIndex())
            self.toImageView?.isHidden = true
        case .changed:
            let fraction = CGFloat(fabsf(Float(offset.y / 200)))
            self.percent = fmin(fraction, 1.0)
            
            if let fromImageView = self.fromImageView {
                let currentLocation = recognizer.location(in: nil)
                let originalLocation = CGPoint(x: currentLocation.x - offset.x, y: currentLocation.y - offset.y)
                var percent = CGFloat(1.0)
                percent = fmax(offset.y > 0 ? 1 - self.percent : CGFloat(1), 0.5)
                let currentWidth = self.fromRect.width * percent
                let currentHeight = self.fromRect.height * percent
                
                let result = CGRect(x: currentLocation.x - (originalLocation.x - self.fromRect.origin.x) * percent,
                                    y: currentLocation.y - (originalLocation.y - self.fromRect.origin.y) * percent,
                                    width: currentWidth,
                                    height: currentHeight)
                fromImageView.frame = (fromImageView.superview?.convert(result, from: nil))!
                
                if offset.y < 0 {
                    self.percent = -self.percent
                }
                
                self.colorAnimation()
            }
        case .ended,
             .cancelled:
            self.isInteracting = false
            let shouldComplete = self.percent > 0.5
            if !shouldComplete || recognizer.state == .cancelled {
                if let fromImageView = self.fromImageView {
                    UIView.animate(withDuration: 0.3, animations: { 
                        fromImageView.frame = self.fromRect
                        fromImageView.superview?.superview?.backgroundColor = UIColor.black
                        self.gallery.view.backgroundColor = UIColor.black
                    }) { (finished) in
                        self.toImageView?.isHidden = false
                    }
                }
            } else {
                self.gallery.dismissGallery()
                self.finish()
            }
            self.fromImageView = nil
            self.percent = 0
            self.toImageView = nil
        default:
            break
        }
    }
    
    private func colorAnimation() {
        if self.percent > 0.7 {
            UIView.animate(withDuration: 0.01, animations: { 
                self.fromImageView?.superview?.superview?.backgroundColor = UIColor.clear
                self.gallery.view.backgroundColor = UIColor.clear
            })
        } else {
            let colorAlpha: CGFloat = CGFloat(fabsf(Float(0.7 - self.percent)))
            UIView.animate(withDuration: 0.01, animations: { 
                self.fromImageView?.superview?.superview?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: colorAlpha)
                self.gallery.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: colorAlpha)
            })
        }
    }
}
