//
//  DKPhotoGalleryScrollView.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 07/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

class DKPhotoGalleryScrollView: UIScrollView {
    
    private var items = Array<UIView?>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.alwaysBounceHorizontal = true
        self.alwaysBounceVertical = false
        self.delaysContentTouches = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func set(totalCount: Int) {
        self.contentSize = CGSize(width: CGFloat(totalCount) * cellWidth() - 20,
                                  height: 0)
        self.items = []
        
        for _ in 0 ..< totalCount {
            self.items.append(nil)
        }
    }
    
    public func insertBefore(totalCount: Int) {
        let lastIndex = Int(self.contentOffset.x / cellWidth())
        
        for _ in 0 ..< totalCount {
            self.items.insert(nil, at: 0)
        }
        
        for index in max(0, totalCount + lastIndex - 1) ... min(self.items.count - 1, totalCount + lastIndex + 1) {
            if let view = self.items[index] {
                view.frame.origin.x = self.cellOrigin(for: index).x
            }
        }
        
        self.contentSize.width = CGFloat(self.items.count) * cellWidth() - 20
        self.contentOffset.x += (CGFloat(totalCount) * cellWidth())
    }
    
    public func insertAfter(totalCount: Int) {
        for _ in 0 ..< totalCount {
            self.items.append(nil)
        }
        
        self.contentSize.width = CGFloat(self.items.count) * cellWidth() - 20
    }
    
    public func set(vc: UIViewController, atIndex index: Int) {
        if self.items[index] != vc.view {
            self.items[index] = vc.view
            
            if vc.view.superview == nil {
                self.addSubview(vc.view)
            } else {
                vc.viewWillAppear(true)
                vc.view.isHidden = false
                vc.viewDidAppear(true)
            }
            vc.view.frame = self.cellRect(for: index)
        }
    }
    
    public func remove(vc: UIViewController, atIndex index: Int) {
        if self.items[index] == vc.view {
            self.items[index] = nil
            vc.viewWillDisappear(true)
            vc.view.isHidden = true
            vc.viewDidDisappear(true)
        }
    }
    
    public func scroll(to index: Int, animated: Bool = false) {
        self.setContentOffset(self.cellOrigin(for: index), animated: animated)
    }
    
    public func cellRect(for index: Int) -> CGRect {
        return CGRect(origin: self.cellOrigin(for: index),
                      size: CGSize(width: pageWidth(), height: pageHeight()))
    }
    
    public func cellOrigin(for index: Int) -> CGPoint {
        return CGPoint(x: CGFloat(index) * cellWidth(), y: 0)
    }
    
    public func positionFromContentOffset() -> CGFloat {
        return self.contentOffset.x / cellWidth()
    }
    
    public func cellWidth() -> CGFloat {
        return pageWidth() + 20
    }
    
    public func pageWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }

    public func pageHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitTestingView = super.hitTest(point, with: event) {
            if hitTestingView.isKind(of: UISlider.self) {
                self.isScrollEnabled = false
            } else {
                self.isScrollEnabled = true
            }
            
            return hitTestingView
        } else {
            return nil
        }
    }
    
}
