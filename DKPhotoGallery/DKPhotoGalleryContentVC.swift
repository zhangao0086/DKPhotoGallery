//
//  DKPhotoGalleryContentVC.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 16/6/23.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

@objc
open class DKPhotoGalleryContentVC: UIViewController, UIScrollViewDelegate {
	
	internal var items: [DKPhotoGalleryItem]!
    
    public var customLongPressActions: [UIAlertAction]?
    public var customPreviewActions: [Any]?
    
    public var pageChangeBlock: (() -> Void)?
    public var singleTapBlock: (() -> Void)?
    public var dismissBlock: (() -> Void)?
    
    open var currentIndex = 0 {
        didSet {
            self.pageChangeBlock?()
        }
    }
    
    public var currentVC: DKPhotoBasePreviewVC {
        get {
            return self.previewVC(at: self.currentIndex)
        }
    }
    
    public var currentContentView: UIView {
        get {
            return self.currentVC.contentView
        }
    }
    
	private let mainView = DKPhotoGalleryScrollView()
    private var reuseableVCs: [DKPhotoBasePreviewVC] = []
    private var visibleVCs: [Int : DKPhotoBasePreviewVC] = [:]
    
    open override func viewDidLoad() {
		super.viewDidLoad()
		
		self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.clear
		
        self.mainView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width + 20, height: self.view.bounds.height)
        self.mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mainView.delegate = self
        self.mainView.update(self.items.count)
        self.view.addSubview(self.mainView)
        
        self.updateWithCurrentIndex(needToSetContentOffset: true)
    }
    
    public func currentVC() -> DKPhotoBasePreviewVC {
        return self.previewVC(at: self.currentIndex)
    }
    
    public func currentContentView() -> UIView {
        return self.currentVC().contentView
    }
    
    // MARK: - Private
    
    private func updateWithCurrentIndex(needToSetContentOffset need : Bool) {
        if need {
            self.mainView.contentOffset = CGPoint(x: CGFloat(self.currentIndex) * self.mainView.bounds.width, y: 0)
        }
        
        for i in ((self.currentIndex - 1) >= 0 ? self.currentIndex - 1 : 0) ... min(self.currentIndex + 1, self.items.count - 1) {
            self.addView(at: i)
        }
    }
    
    private func addView(at index: Int) {
        let vc = self.previewVC(at: index)
        self.addChildViewController(vc)
        self.mainView.set(vc.view, atIndex: index)
    }
    
    private func previewVC(at index: Int) -> DKPhotoBasePreviewVC {
        if let vc = self.visibleVCs[index] {
            return vc
        }
        
        let item = self.items[index]
        
        var vc = self.findPreviewVC(for: DKPhotoBasePreviewVC.photoPreviewClass(with: item))
        if vc == nil {
            vc = DKPhotoBasePreviewVC.photoPreviewVC(with: item)
        } else {
            vc!.prepareReuse(with: item)
            self.reuseableVCs.remove(at: findIndex!)
        }
        
        vc?.customPreviewActions = self.customPreviewActions
        vc?.customLongPressActions = self.customLongPressActions
        if let singleTapBlock = self.singleTapBlock {
            vc?.singleTapBlock = singleTapBlock
        }
        
        self.visibleVCs[index] = vc
        
        return vc!
    }
    
    private func findPreviewVC(for vcClass: AnyClass) -> (Int?, DKPhotoBasePreviewVC?) {
        for (index, reuseableVC) in self.reuseableVCs.enumerated() {
            if reuseableVC.isKind(of: vcClass) {
                return (index, reuseableVC)
            }
        }
        
        return (nil, nil)
    }
    
    // MARK: - Orientations & Status Bar
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
        
    // MARK: - Touch 3D
    
    @available(iOS 9.0, *)
    open override var previewActionItems: [UIPreviewActionItem] {
        return self.currentVC.previewActionItems
    }
	
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        for i in ((index - 1) >= 0 ? index - 1 : 0) ... min(index + 1, self.items.count - 1) {
            if i != index {
                let vc = self.visibleVCs[i]
                vc?.resetScale()
            }
        }
        
        func addToReuseQueueIfNeeded(index: Int) {
            if let vc = self.visibleVCs[index] {
                self.reuseableVCs.append(vc)
                self.mainView.remove(vc.view, atIndex: index)
                vc.removeFromParentViewController()
                self.visibleVCs.removeValue(forKey: index)
            }
        }
        
        if index >= 2 {
            addToReuseQueueIfNeeded(index: index - 2)
        }
        
        if index + 2 <= self.items.count {
            addToReuseQueueIfNeeded(index: index + 2)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        if index != self.currentIndex {
            self.currentIndex = index
            self.updateWithCurrentIndex(needToSetContentOffset: false)
        }
    }
        
}
