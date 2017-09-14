//
//  DKPhotoBasePreviewVC.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 08/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import Photos
import MBProgressHUD
import SDWebImage
import AssetsLibrary

public protocol DKPhotoBasePreviewDataSource : NSObjectProtocol {
    
    func fetchImage(withProgressBlock progressBlock: @escaping ((_ progress: Float) -> Void), _ completeBlock: @escaping ((_ image: UIImage?, _ data: Data?, _ error: Error?) -> Void))
    
    func hasCache() -> Bool
}

//////////////////////////////////////////////////////////////////////////////////////////

open class DKPhotoBasePreviewVC: UIViewController, UIScrollViewDelegate, DKPhotoBasePreviewDataSource {
    
    open fileprivate(set) var item: DKPhotoGalleryItem!
    
    open private(set) var imageView: FLAnimatedImageView!
    
    open var customLongPressActions: [UIAlertAction]?
    open var customPreviewActions: [Any]?
    open var singleTapBlock: (() -> Void)?
    
    @available(iOS 9.0, *)
    private var _customPreviewActions: [UIPreviewActionItem]? {
        return self.customPreviewActions as! [UIPreviewActionItem]?
    }
    
    private var scrollView: UIScrollView!
    
    fileprivate var image: UIImage? {
        didSet {
            guard self.image != self.imageView.image else { return }
            
            self.imageView.image = self.image
            self.animatedImage = nil
            self.centerImageView()
        }
    }
    
    fileprivate var animatedImage: FLAnimatedImage? {
        didSet {
            guard self.animatedImage != self.imageView.animatedImage else { return }
            
            self.imageView.animatedImage = self.animatedImage
            self.image = nil
            self.centerImageView()
        }
    }
    
    private var indicatorView: DKPhotoProgressIndicatorProtocol!
    
    open override func loadView() {
        super.loadView()
        
        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.view.addSubview(self.scrollView)
        
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 4
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView.backgroundColor = UIColor.clear
        self.scrollView.delegate = self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        self.imageView = FLAnimatedImageView(frame: self.view.bounds)
        self.imageView.isUserInteractionEnabled = true
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.imageView.backgroundColor = UIColor.clear
        self.scrollView.addSubview(self.imageView)
        
        self.setupGestures()
        
        self.indicatorView = DKPhotoProgressIndicator(with: self.view)
        
        self.photoPreivewWillAppear()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startFetchImage()
    }
    
    open func photoPreivewWillAppear() {
        
    }
    
    internal func resetScale() {
        self.scrollView.zoomScale = 1.0
        self.scrollView.contentSize = CGSize.zero
    }
    
    internal func setNeedsUpdateImage() {
        self.startFetchImage()
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
    
    private func showTips(_ tips: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .text
        hud.label.text = tips
        hud.hide(animated: true, afterDelay: 2)
    }
    
    private func startFetchImage() {
        if self.hasCache() {
            self.hidesIndicator()
        } else {
            self.showsIndicator()
        }
        
        self.fetchImage(withProgressBlock: { [weak self] (progress) in
            if progress > 0 {
                self?.setIndicatorProgress(progress)
            }
        }) { (image, data, error) in
            if error == nil {
                if let data = data {
                    let imageFormat = NSData.sd_imageFormat(forImageData: data)
                    if imageFormat == .GIF {
                        self.animatedImage = FLAnimatedImage(gifData: data)
                    } else {
                        self.image = UIImage(data: data)
                    }
                } else if let image = image {
                    self.image = image
                } else {
                    assert(false)
                }
                self.imageView.contentMode = .scaleAspectFit
            } else {
                self.image = DKPhotoGalleryResource.downloadFailedImage()
                self.imageView.contentMode = .center
            }
            
            self.hidesIndicator()
        }
    }
    
    private func centerImageView() {
        if let image = self.imageView.image {
            var frame = CGRect.zero
            
            if self.scrollView.contentSize.equalTo(CGSize.zero) {
                frame = AVMakeRect(aspectRatio: image.size, insideRect: self.scrollView.bounds)
            } else {
                frame = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(x: 0, y: 0,
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
            
            self.imageView.frame = frameToCenter
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
            zoomRect = self.scrollView.convert(zoomRect, to: self.imageView)
            self.scrollView.zoom(to: zoomRect, animated: true)
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        }
    }
    
    @objc
    private func longPressAction(gesture: UIGestureRecognizer) {
        guard gesture.state == .began, self.scrollView.maximumZoomScale > self.scrollView.minimumZoomScale else {
            return
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let QRCodeResult = self.detectStringFromImage() {
            let detectQRCodeAction = UIAlertAction(title: "识别图中二维码", style: .default, handler: { [weak self] (action) in
                self?.previewQRCode(with: QRCodeResult)
            })
            alertController.addAction(detectQRCodeAction)
        }
        
        let saveImageAction = UIAlertAction(title: "保存图片", style: .default) { [weak self] (action) in
            self?.saveImageToAlbum()
        }
        alertController.addAction(saveImageAction)
        
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
    
    // MARK: - QR Code
    
    private func detectStringFromImage() -> String? {
        guard let targetImage = self.image ?? self.animatedImage?.posterImage else {
            return nil
        }
        
        if let result = self.detectStringFromCIImage(image: CIImage(image: targetImage)!) {
            return result
        } else {
            return nil
        }
    }
    
    private func detectStringFromCIImage(image: CIImage) -> String? {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [
            CIDetectorAccuracy : CIDetectorAccuracyHigh
        ])
        
        if let detector = detector {
            let features = detector.features(in: image)
            if let feature = features.first as? CIQRCodeFeature {
                return feature.messageString
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func previewQRCode(with result: String) {
        if let _ = NSURL(string: result) {
            let resultVC = DKWebVC()
            resultVC.urlString = result
            self.navigationController?.pushViewController(resultVC, animated: true)
        } else {
            let resultVC = DKPhotoQRCodeResultVC(result: result)
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
    }
    
    // MARK: - Save Image
    
    private func saveImageToAlbum() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                if let image = self.image {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                } else if let animatedImage = self.animatedImage {
                    ALAssetsLibrary().writeImageData(toSavedPhotosAlbum: animatedImage.data, metadata: nil, completionBlock: { (newURL, error) in
                        DispatchQueue.main.async(execute: {
                            if let _ = error {
                                self.showTips("图片保存失败")
                            } else {
                                self.showTips("图片保存成功")
                            }
                        })
                    })
                }
            case .restricted:
                self.showTips("图片保存权限无法开启")
            case .denied:
                self.showTips("获取图片保存权限失败")
            default:
                break
            }
        }
    }
    
    @objc
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            self.showTips("图片保存成功")
        } else {
            self.showTips("图片保存失败")
        }
    }
    
    // MARK: - Touch 3D
    
    @available(iOS 9.0, *)
    open override var previewActionItems: [UIPreviewActionItem] {
        let saveActionItem = UIPreviewAction(title: "保存", style: .default) { [weak self] (action, previewViewController) in
            self?.saveImageToAlbum()
        }
        
        if var customPreviewActions = self._customPreviewActions {
            customPreviewActions.append(saveActionItem)
            return customPreviewActions
        } else {
            return [saveActionItem]
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
        return self.imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImageView()
    }
    
    // MARK: - DKPhotoBasePreviewDataSource
    
    public func fetchImage(withProgressBlock progressBlock: @escaping ((_ progress: Float) -> Void), _ completeBlock: @escaping ((_ image: UIImage?, _ data: Data?, _ error: Error?) -> Void)) {
        assert(false)
    }
    
    public func hasCache() -> Bool {
        return false
    }

}

//////////////////////////////////////////////////////////////////////////////////////////

extension DKPhotoBasePreviewVC {
    
    internal func prepareReuse(with item: DKPhotoGalleryItem) {
        self.resetScale()
        self.image = nil
        self.animatedImage = nil
        
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

extension DKPhotoBasePreviewVC {
    
    public class func photoPreviewVC(with item: DKPhotoGalleryItem) -> DKPhotoBasePreviewVC {
        var previewVC: DKPhotoBasePreviewVC!
        if let _ = item.image {
            previewVC = DKPhotoLocalImagePreviewVC()
        } else if let URL = item.imageURL {
            if URL.isFileURL {
                previewVC = DKPhotoLocalImagePreviewVC()
            } else {
                previewVC = DKPhotoRemoteImagePreviewVC()
            }
        } else if let _ = item.asset {
            previewVC = DKPhotoAssetPreviewVC()
        } else if let assetLocalIdentifier = item.assetLocalIdentifier {
            item.asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetLocalIdentifier], options: nil).firstObject
            item.assetLocalIdentifier = nil
            previewVC = self.photoPreviewVC(with: item)
        } else {
            assert(false)
            return DKPhotoBasePreviewVC()
        }
        
        previewVC.item = item
        return previewVC
    }
}
