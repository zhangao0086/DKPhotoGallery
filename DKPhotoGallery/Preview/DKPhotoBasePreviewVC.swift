//
//  DKPhotoBasePreviewVC.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 08/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import AVFoundation
import MBProgressHUD

public protocol DKPhotoBasePreviewDataSource : NSObjectProtocol {
    
    func createContentView() -> UIView
    
    func updateContentView(with content: Any)
    
    func contentSize() -> CGSize
    
    func fetchContent(withProgressBlock progressBlock: @escaping ((_ progress: Float) -> Void), _ completeBlock: @escaping ((_ data: Any?, _ error: Error?) -> Void))
    
    func hasCache() -> Bool
    
    func createErrorView() -> UIView
    
    @available(iOS 9.0, *)
    func defaultPreviewActions() -> [UIPreviewAction]
    
    func defaultLongPressActions() -> [UIAlertAction]
}

//////////////////////////////////////////////////////////////////////////////////////////

open class DKPhotoBasePreviewVC: UIViewController, UIScrollViewDelegate, DKPhotoBasePreviewDataSource {
    
    open internal(set) var item: DKPhotoGalleryItem!
    
    open private(set) var contentView: UIView!
    open private(set) var errorView: UIView!
    
    open var customLongPressActions: [UIAlertAction]?
    open var customPreviewActions: [Any]?
    open var singleTapBlock: (() -> Void)?
    
    @available(iOS 9.0, *)
    private var _customPreviewActions: [UIPreviewActionItem]? {
        return self.customPreviewActions as! [UIPreviewActionItem]?
    }
    
    private var scrollView: UIScrollView!
    
    private var indicatorView: DKPhotoProgressIndicatorProtocol!
    
    open override func loadView() {
        super.loadView()
        
        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.view.addSubview(self.scrollView)
        
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        if self.enableZoom() {
            self.scrollView.minimumZoomScale = 1
            self.scrollView.maximumZoomScale = 4
        }
        
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView.backgroundColor = UIColor.clear
        self.scrollView.delegate = self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        self.contentView = self.createContentView()
        self.contentView.frame = self.view.bounds
        self.contentView.isUserInteractionEnabled = true
        self.contentView.contentMode = .scaleAspectFit
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.backgroundColor = UIColor.clear
        self.scrollView.addSubview(self.contentView)
        
        self.errorView = self.createErrorView()
        self.errorView.frame = self.view.bounds
        self.errorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.errorView.isHidden = true
        self.scrollView.addSubview(self.errorView)
        
        self.setupGestures()
        
        self.indicatorView = DKPhotoProgressIndicator(with: self.view)
        
        self.photoPreivewWillAppear()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startFetchContent()
    }
    
    open func photoPreviewWillAppear() {
        
    }
    
    open func photoPreviewWillDisappear() {
        
    }
    
    open func resetScale() {
        self.scrollView.zoomScale = 1.0
        self.scrollView.contentSize = CGSize.zero
    }
    
    open func showTips(_ tips: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .text
        hud.label.text = tips
        hud.hide(animated: true, afterDelay: 2)
    }
    
    internal func setNeedsUpdateContent() {
        self.startFetchContent()
    }
    
    // MARK: - Private
    
    private func setupGestures() {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(gesture:)))
        singleTapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        self.view.addGestureRecognizer(longPressGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
    }
    
    private func startFetchContent() {
        if self.hasCache() {
            self.hidesIndicator()
        } else {
            self.showsIndicator()
        }
        
        self.fetchContent(withProgressBlock: { [weak self] (progress) in
            if progress > 0 {
                self?.setIndicatorProgress(progress)
            }
        }) { (data, error) in
            if error == nil {
                self.updateContentView(with: data!)
                self.centerContentView()
                self.contentView.contentMode = .scaleAspectFit
                self.contentView.isHidden = false
                self.errorView.isHidden = true
            } else {
                self.contentView.isHidden = true
                self.errorView.isHidden = false
            }
            
            self.hidesIndicator()
        }
    }
    
    private func centerContentView() {
        let contentSize = self.contentSize()
        if !contentSize.equalTo(CGSize.zero) {
            var frame = CGRect.zero
            
            if self.scrollView.contentSize.equalTo(CGSize.zero) {
                frame = AVMakeRect(aspectRatio: contentSize, insideRect: self.scrollView.bounds)
            } else {
                frame = AVMakeRect(aspectRatio: contentSize, insideRect: CGRect(x: 0, y: 0,
                                                                                width: self.scrollView.contentSize.width,
                                                                                height: self.scrollView.contentSize.height))
            }
            
            let boundsSize = self.scrollView.bounds.size
            
            var frameToCenter = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            
            if frameToCenter.width < boundsSize.width {
                frameToCenter.origin.x = (boundsSize.width - frameToCenter.width) / 2
            } else {
                frameToCenter.origin.x = 0
            }
            
            if frameToCenter.height < boundsSize.height {
                frameToCenter.origin.y = (boundsSize.height - frameToCenter.height) / 2
            } else {
                frameToCenter.origin.y = 0
            }
            
            self.contentView.frame = frameToCenter
        }
    }
    
    // MARK: - Indicator
    
    private func hidesIndicator() {
        self.indicatorView.stopIndicator()
    }
    
    private func showsIndicator() {
        self.indicatorView.startIndicator()
    }
    
    private func setIndicatorProgress(_ progress: Float) {
        self.indicatorView.setIndicatorProgress(progress)
    }
    
    // MARK: - Gestures
    
    @objc
    private func singleTapAction(gesture: UIGestureRecognizer) {
        guard let singleTapBlock = self.singleTapBlock, gesture.state == .recognized else {
            return
        }
        
        singleTapBlock()
    }
    
    @objc
    private func doubleTapAction(gesture: UIGestureRecognizer) {
        guard gesture.state == .recognized, self.scrollView.maximumZoomScale > self.scrollView.minimumZoomScale else {
            return
        }
        
        if self.scrollView.zoomScale > self.scrollView.minimumZoomScale {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else {
            var zoomRect = self.zoomRect(for: self.scrollView.maximumZoomScale, point: gesture.location(in: gesture.view))
            zoomRect = self.scrollView.convert(zoomRect, to: self.contentView)
            self.scrollView.zoom(to: zoomRect, animated: true)
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        }
    }
    
    @objc
    private func longPressAction(gesture: UIGestureRecognizer) {
        guard gesture.state == .began, self.scrollView.maximumZoomScale > self.scrollView.minimumZoomScale else {
            return
        }
        
        let defaultLongPressActions = self.defaultLongPressActions()
        
        if defaultLongPressActions.count + (self.customLongPressActions?.count ?? 0) == 0 {
            return
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for defaultLongPressAction in defaultLongPressActions {
            alertController.addAction(defaultLongPressAction)
        }
        
        if let customLongPressActions = self.customLongPressActions {
            for customLongPressAction in customLongPressActions {
                alertController.addAction(customLongPressAction)
            }
        }

        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func zoomRect(for scale: CGFloat, point: CGPoint) -> CGRect {
        var zoomRect = CGRect(x: 0, y: 0,
                              width: self.scrollView.frame.width / scale, height: self.scrollView.frame.height / scale)
        if scale != 1 {
            zoomRect.origin = CGPoint(x: point.x * (1 - 1 / scale),
                                      y: point.y * (1 - 1 / scale))
        }
        
        return zoomRect
    }
    
    // MARK: - Touch 3D
    
    @available(iOS 9.0, *)
    open override var previewActionItems: [UIPreviewActionItem] {
        let defaultPreviewActions = self.defaultPreviewActions()
        
        if let customPreviewActions = self._customPreviewActions {
            return customPreviewActions + defaultPreviewActions
        } else {
            return defaultPreviewActions
        }
    }
    
    // MARK: - Orientations & Status Bar
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    // MARK: - UIScrollViewDelegate
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerContentView()
    }
    
    // MARK: - DKPhotoBasePreviewDataSource
    
    public func createContentView() -> UIView {
        assert(false)
        return UIView()
    }
    
    public func updateContentView(with content: Any) {
        assert(false)
    }
    
    public func contentSize() -> CGSize {
        assert(false)
        return CGSize.zero
    }
    
    public func fetchContent(withProgressBlock progressBlock: @escaping ((_ progress: Float) -> Void), _ completeBlock: @escaping ((_ data: Any?, _ error: Error?) -> Void)) {
        assert(false)
    }
    
    public func hasCache() -> Bool {
        return false
    }
    
    public func createErrorView() -> UIView {
        let errorView = UIImageView(image: DKPhotoGalleryResource.downloadFailedImage())
        errorView.contentMode = .center
        return errorView
    }
    
    @available(iOS 9.0, *)
    public func defaultPreviewActions() -> [UIPreviewAction] {
        return []
    }
    
    public func defaultLongPressActions() -> [UIAlertAction] {
        return []
    }

}

//////////////////////////////////////////////////////////////////////////////////////////

extension DKPhotoBasePreviewVC {
    
    internal func prepareReuse(with item: DKPhotoGalleryItem) {
        self.resetScale()
        self.contentView.isHidden = true
        self.errorView.isHidden = true
        
        self.item = item
        
        self.photoPreivewWillAppear()
    }
    
    private func dataSource(with item: DKPhotoGalleryItem) -> NSObject {
        if let image = item.image {
            return image
        } else if let URL = item.imageURL {
            return URL
        } else if let asset = item.asset {
            return asset
        } else {
            assert(false)
            return NSObject()
        }
    }
    
}
