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
    
    func index(of item: DKPhotoGalleryItem) -> Int?
    
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
        get { return self.visibleVCs[self.dataSource.item(for: self.currentIndex)]! }
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
    private var leftIncrementalIndicator: DKPhotoIncrementalIndicator?
    private var rightIncrementalIndicator: DKPhotoIncrementalIndicator?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.clear
        
        self.mainView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mainView.delegate = self
        self.mainView.set(totalCount: self.dataSource.numberOfItems())
        self.view.addSubview(self.mainView)
        
        self.updateVisibleViews(index: self.currentIndex, scrollToIndex: true, indexOnly: true)
        
        self.updateFooterView()
        
        if self.dataSource.hasIncrementalDataForLeft() {
            self.leftIncrementalIndicator = DKPhotoIncrementalIndicator.indicator(with: .left) {
                self.dataSource.incrementalItemsForLeft { [weak self] (count) in
                    guard let strongSelf = self, let leftIncrementalIndicator = strongSelf.leftIncrementalIndicator else { return }
                    
                    let scrollView = strongSelf.mainView
                    let canScrollToPreviousOrNext = strongSelf.delegate?.contentVCCanScrollToPreviousOrNext(strongSelf) ?? true
                    let shouldScrollToPrevious = canScrollToPreviousOrNext && !scrollView.isDragging &&
                        scrollView.contentOffset.x == -leftIncrementalIndicator.pullDistance
                    
                    if count > 0 {
                        strongSelf.currentIndex += count
                        strongSelf.mainView.insertBefore(totalCount: count)
                        strongSelf.updateVisibleViews(index: strongSelf.currentIndex, scrollToIndex: false)
                    }
                    
                    leftIncrementalIndicator.endRefreshing()
                    UIView.animate(withDuration: 0.4, animations: {
                        if shouldScrollToPrevious {
                            strongSelf.scrollToPrevious()
                        } else if !scrollView.isDragging {
                            strongSelf.scrollToCurrentPage()
                        } else {
                            scrollView.contentOffset = scrollView.contentOffset
                        }
                    }, completion: { finished in
                        leftIncrementalIndicator.isEnabled = strongSelf.dataSource.hasIncrementalDataForLeft()
                    })
                }
            }
            
            self.mainView.addSubview(self.leftIncrementalIndicator!)
        }
        
        if self.dataSource.hasIncrementalDataForRight() {
            self.rightIncrementalIndicator = DKPhotoIncrementalIndicator.indicator(with: .right) {
                self.dataSource.incrementalItemsForRight { [weak self] (count) in
                    guard let strongSelf = self, let rightIncrementalIndicator = strongSelf.rightIncrementalIndicator else { return }
                    
                    let scrollView = strongSelf.mainView
                    let canScrollToPreviousOrNext = strongSelf.delegate?.contentVCCanScrollToPreviousOrNext(strongSelf) ?? true
                    let shouldScrollToNext = canScrollToPreviousOrNext && !scrollView.isDragging &&
                        scrollView.contentSize.width == scrollView.contentOffset.x + scrollView.bounds.width - rightIncrementalIndicator.pullDistance
                    
                    if count > 0 {
                        strongSelf.mainView.insertAfter(totalCount: count)
                        strongSelf.updateVisibleViews(index: strongSelf.currentIndex, scrollToIndex: false)
                    }
                    
                    rightIncrementalIndicator.endRefreshing()
                    UIView.animate(withDuration: 0.4, animations: {
                        if shouldScrollToNext {
                            strongSelf.scrollToNext()
                        } else if !scrollView.isDragging {
                            strongSelf.scrollToCurrentPage()
                        } else {
                            scrollView.contentOffset = scrollView.contentOffset
                        }
                    }, completion: { finished in
                        rightIncrementalIndicator.isEnabled = strongSelf.dataSource.hasIncrementalDataForRight()
                    })
                }
            }
            
            self.mainView.addSubview(self.rightIncrementalIndicator!)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.prefillingReuseQueue()
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
    
    private func updateVisibleViews(index: Int, scrollToIndex need: Bool, animated: Bool = false, indexOnly: Bool = false) {
        if need {
            self.mainView.scroll(to: index, animated: animated)
        }
     
        if indexOnly {
            self.showViewIfNeeded(at: index)
        } else {
            let fromIndex = index > 0 ? index - 1 : 0
            let toIndex = min(index + 1, self.dataSource.numberOfItems() - 1)
            
            for (visibleItem, visibleVC) in self.visibleVCs {
                if let visibleIndex = self.dataSource.index(of: visibleItem) {
                    if visibleIndex != index {
                        visibleVC.photoPreviewWillDisappear()
                        
                        if visibleIndex < fromIndex || visibleIndex > toIndex {
                            self.addToReuseQueueFromVisibleQueueIfNeeded(index: visibleIndex)
                        }
                    }
                }
            }
            
            UIView.performWithoutAnimation {
                for index in fromIndex ... toIndex {
                    self.showViewIfNeeded(at: index)
                }
            }
        }
        
        self.currentIndex = index
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
        
        self.updateVisibleViews(index: self.currentIndex, scrollToIndex: false)
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

        self.updateVisibleViews(index: self.currentIndex - 1, scrollToIndex: true)
    }
    
    private func scrollToNext() {
        guard self.currentIndex < self.dataSource.numberOfItems() - 1 else { return }
        
        self.updateVisibleViews(index: self.currentIndex + 1, scrollToIndex: true)
    }
    
    private func scrollToCurrentPage() {
        guard self.currentIndex >= 0 && self.currentIndex <= self.dataSource.numberOfItems() - 1 else { return }

        self.updateVisibleViews(index: self.currentIndex, scrollToIndex: true)
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
        var newIndex = self.currentIndex
        
        // Check which way to move
        let movedX = targetContentOffset.pointee.x - self.mainView.cellOrigin(for: self.currentIndex).x
        if movedX < -halfPageWidth {
            newIndex = self.currentIndex - 1 // Move left
        } else if movedX > halfPageWidth {
            newIndex = self.currentIndex + 1 // Move right
        }
        
        if newIndex != self.currentIndex {
            self.updateVisibleViews(index: newIndex, scrollToIndex: false)
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
    
}
