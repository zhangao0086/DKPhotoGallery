//
//  DKPhotoGallery.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 15/7/20.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

@objc
public protocol DKPhotoGalleryDelegate : NSObjectProtocol {
    
    /// Called by the gallery just after it shows the index.
    @objc optional func photoGallery(_ gallery: DKPhotoGallery, didShow index: Int)
    
}

@objc
public enum DKPhotoGallerySingleTapMode : Int {
    case
    dismiss, // Dismiss DKPhotoGallery when user tap on the screen.
    toggleControlView
}

@objc
open class DKPhotoGallery: UINavigationController, UIViewControllerTransitioningDelegate {
	
    open var items: [DKPhotoGalleryItem]?
    
    open var finishedBlock: ((_ index: Int) -> UIImageView?)?
    
    open var presentingFromImageView: UIImageView?
    open var presentationIndex = 0
    
    open var singleTapMode = DKPhotoGallerySingleTapMode.toggleControlView
    
    weak open var galleryDelegate: DKPhotoGalleryDelegate?
    
    open var customLongPressActions: [UIAlertAction]?
    open var customPreviewActions: [Any]? // [UIPreviewActionItem]
    
    open var navigationBarBackgroundColor = UIColor.gray.withAlphaComponent(0.7) {
        willSet {
            self.contentVC?.footerViewContainerColor = newValue
        }
    }
    open var footerView: UIView? {
        didSet {
            self.contentVC?.footerView = self.footerView
            self.updateFooterView()
        }
    }
    
    open var transitionController: DKPhotoGalleryTransitionController?
    
    internal var statusBar: UIView?
    internal weak var contentVC: DKPhotoGalleryContentVC?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        self.navigationBar.setBackgroundImage(DKPhotoGallery.imageFromColor(color: navigationBarBackgroundColor),
                                              for: .default)
        self.navigationBar.isTranslucent = true
        
        let contentVC = DKPhotoGalleryContentVC()
        self.contentVC = contentVC
        self.viewControllers = [contentVC]
        
        contentVC.prepareToShow = { [weak self] previewVC in
            self?.setup(previewVC: previewVC)
        }
        
        contentVC.pageChangeBlock = { [weak self] index in
            guard let strongSelf = self else { return }
            
            strongSelf.updateNavigation()
            strongSelf.galleryDelegate?.photoGallery?(strongSelf, didShow: index)
        }
        
        contentVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel,
                                                                     target: self,
                                                                     action: #selector(DKPhotoGallery.dismissGallery))
        
        contentVC.items = self.items
        contentVC.currentIndex = min(self.presentationIndex, self.items!.count - 1)
        
        contentVC.footerViewContainerColor = self.navigationBarBackgroundColor
        contentVC.footerView = self.footerView
        
        let keyData = Data(bytes: [0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72])
        let key = String(data: keyData, encoding: String.Encoding.ascii)!
        if let statusBar = UIApplication.shared.value(forKey: key) as? UIView {
            self.statusBar = statusBar
        }
    }
    
    private lazy var doSetupOnce: () -> Void = {
        self.isNavigationBarHidden = true
        self.setFooterViewHidden(true, animated: false)
        
        if self.singleTapMode == .toggleControlView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                self.setNavigationBarHidden(false, animated: true)
                self.setFooterViewHidden(false, animated: true)
                self.showsControlView()
            })
            self.statusBar?.alpha = 1
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                self.setFooterViewHidden(false, animated: true)
            })
            self.statusBar?.alpha = 0
        }

        return {}
    }()
    
    private let defaultStatusBarStyle = UIApplication.shared.statusBarStyle
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.doSetupOnce()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.modalPresentationCapturesStatusBarAppearance = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarStyle = self.defaultStatusBarStyle
        
        self.modalPresentationCapturesStatusBarAppearance = false
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.statusBar?.alpha = 1
    }
    
    @objc open func dismissGallery() {
        self.dismiss(animated: true) {
            if self.view.window == nil {
                self.transitionController = nil
            }
        }
    }
    
    open func currentContentView() -> UIView {
        return self.contentVC!.currentContentView
    }
    
    open func currentContentVC() -> DKPhotoBasePreviewVC {
        return self.contentVC!.currentVC
    }
    
    open func currentIndex() -> Int {
        return self.contentVC!.currentIndex
    }
    
    open func updateNavigation() {
        self.contentVC!.navigationItem.title = "\(self.contentVC!.currentIndex + 1)/\(self.items!.count)"
    }
    
    open func handleSingleTap() {
        switch self.singleTapMode {
        case .toggleControlView:
            self.toggleControlView()
        case .dismiss:
            self.dismissGallery()
        }
    }
    
    open func toggleControlView() {
        if self.isNavigationBarHidden {
            self.showsControlView()
        } else {
            self.hidesControlView()
        }
    }
    
    open func showsControlView () {
        self.isNavigationBarHidden = false
        self.statusBar?.alpha = 1
        self.contentVC?.setFooterViewHidden(false, animated: false)
        
        if let videoPreviewVCs = self.contentVC?.filterVisibleVCs(with: DKPhotoPlayerPreviewVC.self) {
            let _ = videoPreviewVCs.map { $0.isControlHidden = false }
        }
    }
    
    open func hidesControlView () {
        self.isNavigationBarHidden = true
        self.statusBar?.alpha = 0
        self.contentVC?.setFooterViewHidden(true, animated: false)
        
        if let videoPreviewVCs = self.contentVC?.filterVisibleVCs(with: DKPhotoPlayerPreviewVC.self) {
            let _ = videoPreviewVCs.map { $0.isControlHidden = true }
        }
    }
    
    @available(iOS 9.0, *)
    open override var previewActionItems: [UIPreviewActionItem] {
        return self.contentVC!.currentVC.previewActionItems
    }
    
    // MARK: - Private, internal
    
    private func updateFooterView() {
        if self.footerView != nil {
            if self.singleTapMode == .toggleControlView && self.isNavigationBarHidden {
                self.contentVC?.setFooterViewHidden(true, animated: false)
            }
        }
    }
    
    private func setup(previewVC: DKPhotoBasePreviewVC) {
        previewVC.customLongPressActions = self.customLongPressActions
        previewVC.customPreviewActions = self.customPreviewActions
        previewVC.singleTapBlock = { [weak self] in
            self?.handleSingleTap()
        }
        
        if previewVC.previewType == .video, let videoPreviewVC = previewVC as? DKPhotoPlayerPreviewVC {
            if self.singleTapMode == .dismiss {
                videoPreviewVC.closeBlock = { [weak self] in
                    self?.dismissGallery()
                }
                videoPreviewVC.isControlHidden = true
                videoPreviewVC.autoHidesControlView = true
                videoPreviewVC.tapToToggleControlView = true
            } else {
                videoPreviewVC.isControlHidden = self.isNavigationBarHidden
                videoPreviewVC.autoHidesControlView = false
                videoPreviewVC.tapToToggleControlView = false
                
                videoPreviewVC.beginPlayBlock = { [weak self] in
                    self?.hidesControlView()
                }
            }
        }
    }
    
    internal func updateContextBackground(alpha: CGFloat, animated: Bool) {
        let block = {
            self.currentContentVC().updateContextBackground(alpha: alpha)
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: alpha)
            
            if self.isNavigationBarHidden {
                self.statusBar?.alpha = 1 - alpha
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.1, animations: block)
        } else {
            block()
        }
    }
    
    internal func setFooterViewHidden(_ hidden: Bool, animated: Bool) {
        self.contentVC?.setFooterViewHidden(hidden, animated: animated)
    }
    
    // MARK: - UINavigationController
    
    private var _isNavigationBarHidden: Bool = false
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        if self.viewControllers.count == 2 {
            if self.isNavigationBarHidden {
                self._isNavigationBarHidden = true
                
                self.setNavigationBarHidden(false, animated: true)
                
                UIView.animate(withDuration: 0.1, animations: {
                    self.statusBar?.alpha = 1
                })
            }
        }
    }
    
    open override func popViewController(animated: Bool) -> UIViewController? {
        let vc = super.popViewController(animated: animated)
        
        if self.viewControllers.count == 1 {
            if self._isNavigationBarHidden {
                self._isNavigationBarHidden = false
                
                self.setNavigationBarHidden(true, animated: true)
                
                UIView.animate(withDuration: 0.1, animations: {
                    self.statusBar?.alpha = 0
                })
            }
        }
        
        return vc
    }
    
    // MARK: - Utilities
        
    internal class func imageFromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        // create a 1 by 1 pixel context
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }

}

//////////////////////////////////////////////////////////////////////////////////////////

public extension UIViewController {
    
    public func present(photoGallery gallery: DKPhotoGallery, completion: (() -> Swift.Void)? = nil) {
        gallery.modalPresentationStyle = .custom
        
        gallery.transitionController = DKPhotoGalleryTransitionController(gallery: gallery,
                                                                          presentedViewController: gallery,
                                                                          presenting: self)
        gallery.transitioningDelegate = gallery.transitionController
        
        gallery.transitionController!.prepareInteractiveGesture()
        
        self.present(gallery, animated: true, completion: completion)
    }
}
