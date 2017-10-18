//
//  DKPhotoGalleryScrollView.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 07/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

class DKPhotoGalleryScrollView: UIScrollView {
    
    private var items = Array<NSObject>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.alwaysBounceHorizontal = true
        self.alwaysBounceVertical = false
        self.isPagingEnabled = true
        self.delaysContentTouches = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update(_ itemCount: Int) {
        self.contentSize = CGSize(width: CGFloat(itemCount * Int((screenWidth() + 20))),
                                  height: screenHeight())
        self.items = []
        
        for _ in 0 ..< itemCount {
            self.items.append(NSNull())
        }
    }
    
    public func set(_ subview: UIView, atIndex index: Int) {
        if self.items[index] != subview {
            self.items[index] = subview
            self.addSubview(subview)
            subview.frame = CGRect(x: CGFloat(index) * (screenWidth() + 20), y: 0,
                                   width: screenWidth(), height: screenHeight())
        }
    }
    
    public func remove(_ subview: UIView, atIndex index: Int) {
        if self.items[index] == subview {
            self.items[index] = NSNull()
            subview.removeFromSuperview()
        }
    }
    
    private func screenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }

    private func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
}
