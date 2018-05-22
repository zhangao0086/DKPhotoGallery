//
//  DKPhotoIncrementalIndicator.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 2018/5/17.
//

import UIKit

class DKPhotoIncrementalIndicator: UIView {

    override open class var layerClass: Swift.AnyClass {
        get {
            return CAReplicatorLayer.self
        }
    }
    
    public var progress = 0
    
    private var replicatorLayer: CAReplicatorLayer!
    private var instanceLayer: CALayer!
    private let maxInstanceCount = 14
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.replicatorLayer = self.layer as! CAReplicatorLayer
        self.replicatorLayer.instanceCount = 0
        self.replicatorLayer.instanceDelay = CFTimeInterval(1 / Float(self.maxInstanceCount))
        self.replicatorLayer.instanceColor = UIColor.white.cgColor
        
        let angle = Float(Double.pi * 2.0) / Float(self.maxInstanceCount)
        self.replicatorLayer.instanceTransform = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
        
        self.instanceLayer = CALayer()
        self.instanceLayer.backgroundColor = UIColor.white.cgColor
        self.instanceLayer.opacity = 1.0
        self.replicatorLayer.addSublayer(self.instanceLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layerWidth: CGFloat = 2.0
        let midX = self.bounds.midX - layerWidth / 2.0
        self.instanceLayer.frame = CGRect(x: midX, y: 0.0, width: layerWidth, height: layerWidth * 3.0)
    }
    
    public func setProgress(_ progress: Float) {
        self.isHidden = false
        
        if progress == 0 {
            self.replicatorLayer.instanceCount = 0
        } else {
            self.replicatorLayer.instanceCount = Int(Float(self.maxInstanceCount) * progress)
        }
    }
    
    public func startAnimation() {
        self.isHidden = false
        
        self.replicatorLayer.instanceCount = self.maxInstanceCount

        let rotateAnimationShort = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimationShort.fromValue = 0.0
        rotateAnimationShort.toValue = CGFloat.pi * 2.0
        rotateAnimationShort.duration = 1
        rotateAnimationShort.repeatCount = 1
        rotateAnimationShort.isRemovedOnCompletion = true
        self.replicatorLayer.add(rotateAnimationShort, forKey: "RotateAnimationShort")
        
        let rotateAnimationLong = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimationLong.fromValue = CGFloat.pi * 2.0
        rotateAnimationLong.toValue = CGFloat.pi * 4.0
        rotateAnimationLong.duration = 2
        rotateAnimationLong.beginTime = CACurrentMediaTime() + rotateAnimationShort.duration
        rotateAnimationLong.repeatCount = Float.greatestFiniteMagnitude
        self.replicatorLayer.add(rotateAnimationLong, forKey: "RotateAnimationLong")
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 1
        fadeAnimation.repeatCount = Float.greatestFiniteMagnitude

        self.instanceLayer.add(fadeAnimation, forKey: "FadeAnimation")
    }
    
    public func stopAnimation() {
        self.isHidden = true
        
        self.replicatorLayer.removeAllAnimations()
        self.instanceLayer.removeAllAnimations()
    }
    
}
