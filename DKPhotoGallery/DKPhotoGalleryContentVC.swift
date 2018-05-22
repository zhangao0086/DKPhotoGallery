//
//  DKPhotoGalleryContentVC.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 16/6/23.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

fileprivate class DKPhotoGalleryContentFooterViewContainer : UIView {
    
    private var footerView: UIView
    private var backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    init(footerView: UIView) {
        self.footerView = footerView
        
        super.init(frame: CGRect.zero)
        
        self.addSubview(self.backgroundView)
        self.backgroundView.contentView.addSubview(footerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        self.footerView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.footerView.bounds.height)
    }
}

////////////////////////////////////////////////////////////

internal protocol DKPhotoGalleryContentDataSource {
    
    func item(for index: Int) -> DKPhotoGalleryItem
    
    func numberOfItems() -> Int
    
    func hasIncrementalDataForLeft() -> Bool
    
    func incrementalItemsForLeft(resultHandler: @escaping ((_ count: Int) -> Void))
    
    func hasIncrementalDataForRight() -> Bool
    
    func incrementalItemsForRight(resultHandler: @escaping ((_ count: Int) -> Void))

}

internal protocol DKPhotoGalleryContentDelegate {
    
    func contentVCCanScrollToPreviousOrNext(_ contentVC: DKPhotoGalleryContentVC) -> Bool
    
}

////////////////////////////////////////////////////////////

@objc
open class DKPhotoGalleryContentVC: UIViewController, UIScrollViewDelegate {
    
    internal var dataSource: DKPhotoGalleryContentDataSource!
    internal var delegate: DKPhotoGalleryContentDelegate?
    
    public var pageChangeBlock: ((_ index: Int) -> Void)?
    public var prepareToShow: ((_ previewVC: DKPhotoBasePreviewVC) -> Void)?
    
    open var currentIndex = 0 {
        didSet {
            self.pageChangeBlock?(self.currentIndex)
        }
    }
    
    public var currentVC: DKPhotoBasePreviewVC {
        get { return self.previewVC(for: self.dataSource.item(for: self.currentIndex)) }
    }
    
    public var currentContentView: UIView {
        get { return self.currentVC.contentView }
    }
    
    private let mainView = DKPhotoGalleryScrollView()
    private var reuseableVCs: [ObjectIdentifier : [DKPhotoBasePreviewVC] ] = [:] // DKPhotoBasePreviewVC.Type : [DKPhotoBasePreviewVC]
    private var visibleVCs: [DKPhotoGalleryItem : DKPhotoBasePreviewVC] = [:]
    
    open var footerView: UIView? {
        didSet {
            self.updateFooterView()
            if let footerViewContainer = self.footerViewContainer {
                footerViewContainer.alpha = 0
                self.setFooterViewHidden(false, animated: true)
            }
        }
    }
        
    private var footerViewContainer: DKPhotoGalleryContentFooterViewContainer?
    
    private let pullDistance = CGFloat(60)
    private let indicatorSize = CGFloat(30)
    lazy private var leftIncrementalIndicator: DKPhotoIncrementalIndicator = {
        let indicator = DKPhotoIncrementalIndicator(frame: CGRect(x: (-self.pullDistance - self.indicatorSize) / 2,
                                                                  y: (self.view.bounds.height - self.indicatorSize) / 2,
                                                                  width: self.indicatorSize, height: self.indicatorSize))
        self.mainView.addSubview(indicator)
        return indicator
    }()
    
    lazy private var rightIncrementalIndicator: DKPhotoIncrementalIndicator = {
        let indicator = DKPhotoIncrementalIndicator(frame: CGRect(x: 0,
                                                                  y: (self.view.bounds.height - self.indicatorSize) / 2,
                                                                  width: self.indicatorSize, height: self.indicatorSize))
        self.mainView.addSubview(indicator)
        return indicator
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.clear
        
        self.mainView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mainView.delegate = self
        self.mainView.set(totalCount: self.dataSource.numberOfItems())
        self.view.addSubview(self.mainView)
        
        self.updateWithCurrentIndex(needToSetContentOffset: true, onlyCurrentIndex: true)
        
        self.updateFooterView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.prefillingReuseQueue()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.updateRightIncrementalIndicatorFrameIfNeeded()
    }
    
    internal func filterVisibleVCs<T>(with className: T.Type) -> [T]? {
        var filtered = [T]()
        for (_, value) in self.visibleVCs {
            if let value = value as? T {
                filtered.append(value)
            }
        }
        
        return filtered
    }
    
    internal func setFooterViewHidden(_ hidden: Bool, animated: Bool, completeBlock: (() -> Void)? = nil) {
        guard let footerView = self.footerViewContainer else { return }
        
        let alpha = CGFloat(hidden ? 0 : 1)
        
        if footerView.alpha != alpha {
            let footerViewAnimationBlock = {
                footerView.alpha = alpha
            }
            
            if animated {
                UIView.animate(withDuration: 0.2, animations: footerViewAnimationBlock) { finished in
                    completeBlock?()
                }
            } else {
                footerViewAnimationBlock()
            }
        }
    }
    
    // MARK: - Private
    
    private func updateFooterView() {
        guard self.isViewLoaded else { return }
        
        if let footerView = self.footerView {
            self.footerViewContainer = DKPhotoGalleryContentFooterViewContainer(footerView: footerView)
            
            let footerViewHeight = footerView.bounds.height + (DKPhotoBasePreviewVC.isIphoneX() ? 34 : 0)
            self.footerViewContainer!.frame = CGRect(x: 0, y: self.view.bounds.height - footerViewHeight,
                                                     width: self.view.bounds.width, height: footerViewHeight)
            self.view.addSubview(self.footerViewContainer!)
        } else if let footerViewContainer = self.footerViewContainer {
            self.setFooterViewHidden(true, animated: true) {
                footerViewContainer.removeFromSuperview()
            }
            self.footerViewContainer = nil
        }
    }
    
    private func updateWithCurrentIndex(needToSetContentOffset need: Bool, animated: Bool = false, onlyCurrentIndex: Bool = false) {
        if need {
            self.mainView.scroll(to: self.currentIndex, animated: animated)
        }
        
        if onlyCurrentIndex {
            self.showViewIfNeeded(at: self.currentIndex)
        } else {
            let fromIndex = self.currentIndex > 0 ? self.currentIndex - 1 : 0
            let toIndex = min(self.currentIndex + 1, self.dataSource.numberOfItems() - 1)
            
            UIView.performWithoutAnimation {
                for index in fromIndex ... toIndex {
                    self.showViewIfNeeded(at: index)
                }
            }
        }
    }
    
    private func showViewIfNeeded(at index: Int) {
        let item = self.dataSource.item(for: index)
        
        if self.visibleVCs[item] == nil {
            let vc = self.previewVC(for: item)
            if vc.parent != self {
                self.addChildViewController(vc)
            }
            self.mainView.set(vc: vc, atIndex: index)
        }
    }
    
    private func previewVC(for item: DKPhotoGalleryItem) -> DKPhotoBasePreviewVC {
        if let vc = self.visibleVCs[item] {
            return vc
        }
        
        let previewVCClass = DKPhotoBasePreviewVC.photoPreviewClass(with: item)
        var vc = self.findPreviewVC(for: previewVCClass)
        if vc == nil {
            vc = previewVCClass.init()
        } else {
            vc!.prepareForReuse()
        }
        
        let previewVC = vc!
        
        self.prepareToShow?(previewVC)
        
        previewVC.item = item
        
        self.visibleVCs[item] = previewVC
        
        return previewVC
    }
    
    private func findPreviewVC(for vcClass: DKPhotoBasePreviewVC.Type) -> DKPhotoBasePreviewVC? {
        let classKey = ObjectIdentifier(vcClass)
        return self.reuseableVCs[classKey]?.popLast()
    }
    
    private func addToReuseQueueFromVisibleQueueIfNeeded(index: Int) {
        guard index >= 0 && index < self.dataSource.numberOfItems() else { return }
        
        let item = self.dataSource.item(for: index)
        if let vc = self.visibleVCs[item] {
            self.addToReuseQueue(vc: vc)
            
            self.mainView.remove(vc: vc, atIndex: index)
            self.visibleVCs.removeValue(forKey: item)
        }
    }
    
    private func addToReuseQueue(vc: DKPhotoBasePreviewVC) {
        let classKey = ObjectIdentifier(type(of: vc))
        var queue: [DKPhotoBasePreviewVC]! = self.reuseableVCs[classKey]
        if queue == nil {
            queue = []
        }
        
        queue.append(vc)
        self.reuseableVCs[classKey] = queue
    }
    
    private var isFilled = false
    private func prefillingReuseQueue() {
        guard !self.isFilled else { return }
        
        self.isFilled = true
        
        [DKPhotoImagePreviewVC(),
         DKPhotoImagePreviewVC(),
         DKPhotoPlayerPreviewVC(),
         DKPhotoPlayerPreviewVC(),
         self.currentVC.previewType == .photo ? DKPhotoPlayerPreviewVC() : DKPhotoImagePreviewVC()]
            
            .forEach { (previewVC) in
                previewVC.view.isHidden = true
                self.mainView.addSubview(previewVC.view)
                self.addToReuseQueue(vc: previewVC)
        }
        
        self.updateWithCurrentIndex(needToSetContentOffset: false)
    }
    
    private func isScrollViewBouncing() -> Bool {
        if self.mainView.contentOffset.x < -(self.mainView.contentInset.left) {
            return true
        } else if self.mainView.contentOffset.x > self.mainView.contentSize.width - self.mainView.bounds.width + self.mainView.contentInset.right {
            return true
        } else {
            return false
        }
    }
    
    private func resetScaleForVisibleVCs() {
        if self.currentIndex > 0 {
            self.visibleVCs[self.dataSource.item(for: self.currentIndex - 1)]?.resetScale()
        } else if self.currentIndex < self.dataSource.numberOfItems() - 1 {
            self.visibleVCs[self.dataSource.item(for: self.currentIndex + 1)]?.resetScale()
        }
    }
    
    private func scrollToPrevious() {
        guard self.currentIndex > 0 else { return }
        
        self.currentIndex -= 1
        self.addToReuseQueueFromVisibleQueueIfNeeded(index: self.currentIndex + 2)
        self.updateWithCurrentIndex(needToSetContentOffset: true)
    }
    
    private func scrollToNext() {
        guard self.currentIndex < self.dataSource.numberOfItems() - 1 else { return }
        
        self.currentIndex += 1
        self.addToReuseQueueFromVisibleQueueIfNeeded(index: self.currentIndex - 2)
        self.updateWithCurrentIndex(needToSetContentOffset: true)
    }
    
    private func scrollToCurrentPage() {
        guard self.currentIndex >= 0 && self.currentIndex <= self.dataSource.numberOfItems() - 1 else { return }
        
        self.updateWithCurrentIndex(needToSetContentOffset: true)
    }
    
    private func updateLeftIncrementalIndicator() {
        let scrollView = self.mainView
        
        let progress = Float(min(1, abs(scrollView.contentOffset.x) / self.pullDistance))
        if !scrollView.isDragging && progress == 1 {
            let originalContentOffsetX = scrollView.contentOffset.x
            scrollView.contentInset.left = self.pullDistance
            scrollView.contentOffset.x = originalContentOffsetX
            self.leftIncrementalIndicator.startAnimation()
            
            self.dataSource.incrementalItemsForLeft { [weak self] (count) in
                guard let strongSelf = self else { return }
                
                let canScrollToPreviousOrNext = strongSelf.delegate?.contentVCCanScrollToPreviousOrNext(strongSelf) ?? true
                let shouldScrollToPrevious = canScrollToPreviousOrNext && !scrollView.isDragging &&
                    scrollView.contentOffset.x == -strongSelf.pullDistance
                
                if count > 0 {
                    strongSelf.currentIndex += count
                    strongSelf.mainView.insertBefore(totalCount: count)
                    strongSelf.updateRightIncrementalIndicatorFrameIfNeeded()
                }
                
                strongSelf.leftIncrementalIndicator.stopAnimation()
                UIView.animate(withDuration: 0.4, animations: {
                    scrollView.contentInset.left = 0
                    if shouldScrollToPrevious {
                        strongSelf.scrollToPrevious()
                    } else {
                        strongSelf.scrollToCurrentPage()
                    }
                })
            }
        } else {
            self.leftIncrementalIndicator.setProgress(progress)
        }
    }
    
    private func updateRightIncrementalIndicator() {
        let scrollView = self.mainView
        
        let progress = Float(min(1, (scrollView.contentOffset.x - (scrollView.contentSize.width - scrollView.bounds.width)) / self.pullDistance))
        if !scrollView.isDragging && progress == 1 {
            let originalContentOffsetX = scrollView.contentOffset.x
            scrollView.contentInset.right = self.pullDistance
            scrollView.contentOffset.x = originalContentOffsetX
            self.rightIncrementalIndicator.startAnimation()
            
            self.dataSource.incrementalItemsForRight { [weak self] (count) in
                guard let strongSelf = self else { return }
                
                let canScrollToPreviousOrNext = strongSelf.delegate?.contentVCCanScrollToPreviousOrNext(strongSelf) ?? true
                let shouldScrollToNext = canScrollToPreviousOrNext && !scrollView.isDragging &&
                    scrollView.contentSize.width == scrollView.contentOffset.x + scrollView.bounds.width - strongSelf.pullDistance
                
                if count > 0 {
                    strongSelf.mainView.insertAfter(totalCount: count)
                    strongSelf.updateRightIncrementalIndicatorFrameIfNeeded()
                }
                
                strongSelf.rightIncrementalIndicator.stopAnimation()
                UIView.animate(withDuration: 0.4, animations: {
                    scrollView.contentInset.right = 0
                    if shouldScrollToNext {
                        strongSelf.scrollToNext()
                    } else {
                        strongSelf.scrollToCurrentPage()
                    }
                })
            }
        } else {
            self.rightIncrementalIndicator.setProgress(progress)
        }
    }
    
    private func updateRightIncrementalIndicatorFrameIfNeeded() {
        if self.dataSource.hasIncrementalDataForRight() {
            self.rightIncrementalIndicator.frame.origin.x = self.mainView.contentSize.width + (self.pullDistance - self.indicatorSize) / 2
        }
    }
    
    // MARK: - Orientations & Status Bar
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard !self.isScrollViewBouncing() else { return }
        
        self.resetScaleForVisibleVCs()
    }
    
    private var scrollToCurrentPageWhenEndDragging = false
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard !self.isScrollViewBouncing() else { return }
        
        let halfPageWidth = self.mainView.pageWidth() * 0.5
        let originalIndex = self.currentIndex
        
        // Check which way to move
        let movedX = targetContentOffset.pointee.x - self.mainView.cellOrigin(for: self.currentIndex).x
        if movedX < -halfPageWidth {
            self.currentIndex -= 1 // Move left
        } else if movedX > halfPageWidth {
            self.currentIndex += 1 // Move right
        }
        
        if originalIndex != self.currentIndex {
            self.currentVC.photoPreviewWillDisappear()
            self.addToReuseQueueFromVisibleQueueIfNeeded(index: originalIndex > self.currentIndex ? originalIndex + 1 : originalIndex - 1)
            self.updateWithCurrentIndex(needToSetContentOffset: false)
        }
        
        if abs(velocity.x) >= 2 {
            targetContentOffset.pointee.x = self.mainView.cellOrigin(for: self.currentIndex).x
        } else {
            // If velocity is too slow, stop and move with default velocity
            targetContentOffset.pointee.x = scrollView.contentOffset.x
            self.scrollToCurrentPageWhenEndDragging = true
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !self.isScrollViewBouncing() && self.scrollToCurrentPageWhenEndDragging else { return }

        self.scrollToCurrentPageWhenEndDragging = false

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.mainView.scroll(to: self.currentIndex)
        }, completion: { (finished) in
            self.resetScaleForVisibleVCs()
        })
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= 0 {
            if self.dataSource.hasIncrementalDataForLeft() && scrollView.contentInset.left == 0 {
                self.updateLeftIncrementalIndicator()
            }
        } else if scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.bounds.width {
            if self.dataSource.hasIncrementalDataForRight() && scrollView.contentInset.right == 0 {
                self.updateRightIncrementalIndicator()
            }
        }
    }
    
}
