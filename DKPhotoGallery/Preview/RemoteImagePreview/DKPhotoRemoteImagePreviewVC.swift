//
//  DKPhotoRemoteImagePreviewVC.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 08/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import SDWebImage

class DKPhotoRemoteImagePreviewVC: DKPhotoBaseImagePreviewVC {

    private var downloadURL: NSURL?
    private var reuseIdentifier: String?
    
    private let downloadOriginalImageButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.downloadOriginalImageButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.downloadOriginalImageButton.layer.borderWidth = 1
        self.downloadOriginalImageButton.layer.borderColor = UIColor(red: 0.47, green: 0.45, blue: 0.45, alpha: 1).cgColor
        self.downloadOriginalImageButton.layer.cornerRadius = 2
        self.downloadOriginalImageButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.downloadOriginalImageButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        self.downloadOriginalImageButton.addTarget(self, action: #selector(downloadOriginalImage), for: .touchUpInside)
        self.view.addSubview(self.downloadOriginalImageButton)
    }
    
    @objc
    private func downloadOriginalImage() {
        if let extraInfo = self.item.extraInfo, let originalURL = extraInfo[DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL] as? NSURL {
            self.downloadOriginalImageButton.isEnabled = false
            
            self.downloadImage(with: originalURL, progressBlock: { [weak self] (progress) in
                self?.updateDownloadOriginalButton(with: progress)
            }, completeBlock: { (data, error) in
                if error == nil {
                    self.setNeedsUpdateContent()
                    self.downloadOriginalImageButton.isHidden = true
                } else {
                    self.downloadOriginalImageButton.isEnabled = true
                    self.updateDownloadOriginalButtonTitle()
                }
            })
        }
    }
    
    private func downloadImage(with URL: NSURL, progressBlock: @escaping ((_ progress: Float) -> Void),
                               completeBlock: @escaping ((_ data: Any?, _ error: Error?) -> Void)) {
        let key = URL.absoluteString
        let reuseIdentifier = self.reuseIdentifier!
        
        SDImageCache.shared().queryCacheOperation(forKey: key) { (image, data, cacheType) in
            if image != nil || data != nil {
                completeBlock(image ?? data, nil)
            } else {
                SDWebImageDownloader.shared().downloadImage(with: URL as URL,
                                                            options: SDWebImageDownloaderOptions(rawValue: 0),
                                                            progress: { [weak self] (receivedSize, expectedSize, targetURL) in
                                                                guard let strongSelf = self, reuseIdentifier == strongSelf.reuseIdentifier else { return }
                                                                
                                                                DispatchQueue.main.async {
                                                                    progressBlock(Float(receivedSize) / Float(expectedSize))
                                                                }
                    }, completed: { [weak self] (image, data, error, finished) in
                        var success = false
                        if (image != nil || data != nil) && finished {
                            SDImageCache.shared().store(image, imageData: data, forKey: key, toDisk: true, completion: nil)
                            success = true
                        } else {
                            success = false
                        }
                        
                        guard let strongSelf = self, reuseIdentifier == strongSelf.reuseIdentifier else { return }
                        
                        if success {
                            completeBlock(image ?? data, nil)
                        } else {
                            let error = NSError(domain: Bundle.main.bundleIdentifier!, code: -1, userInfo: [
                                NSLocalizedDescriptionKey : "获取图片失败"
                                ])
                            completeBlock(nil, error)
                        }
                })
            }
        }
    }
    
    private func updateDownloadOriginalButtonTitle() {
        if let extraInfo = self.item.extraInfo, let fileSize = extraInfo[DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalSize] as? NSNumber {
            self.downloadOriginalImageButton.setTitle("下载原图(\(self.formattedFileSize(fileSize.uintValue)))", for: .normal)
        } else {
            self.downloadOriginalImageButton.setTitle("下载原图", for: .normal)
        }
        self.updateDownloadOriginalButtonFrame()
    }
    
    private func updateDownloadOriginalButton(with progress: Float) {
        if progress > 0 {
            self.downloadOriginalImageButton.setTitle(String(format: "%.0f%%", progress * 100), for: .normal)
            self.updateDownloadOriginalButtonFrame()
        }
    }
    
    private func updateDownloadOriginalButtonFrame() {
        self.downloadOriginalImageButton.sizeToFit()
        
        let buttonWidth = max(100, self.downloadOriginalImageButton.bounds.width)
        let buttonHeight = CGFloat(25)
        
        self.downloadOriginalImageButton.frame = CGRect(x: (self.view.bounds.width - buttonWidth) / 2,
                                                        y: self.view.bounds.height - buttonHeight - 20,
                                                        width: buttonWidth,
                                                        height: buttonHeight)
    }
    
    private func formattedFileSize(_ fileSize: UInt) -> String {
        let tokens = ["B", "KB", "MB", "GB", "TB"]
        
        var convertedSize = Double(fileSize)
        var factor = 0
        
        while convertedSize > 1024 {
            convertedSize = convertedSize / 1024
            factor = factor + 1
        }
        
        if factor == 0 {
            return String(format: "%4.0f%@", convertedSize, tokens[factor])
        } else {
            return String(format: "%4.2f%@", convertedSize, tokens[factor])
        }
    }
    
    // MARK: - DKPhotoBasePreviewDataSource
    
    override func photoPreviewWillAppear() {
        super.photoPreviewWillAppear()
        
        self.downloadURL = self.item.imageURL
        self.reuseIdentifier = self.downloadURL?.absoluteString
        
        if let extraInfo = self.item.extraInfo, let originalURL = extraInfo[DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL] as? NSURL {
            if self.downloadURL == originalURL{
                self.downloadOriginalImageButton.isHidden = true
            } else if SDImageCache.shared().imageFromCache(forKey: originalURL.absoluteString) != nil {
                self.downloadOriginalImageButton.isHidden = true
            } else {
                self.updateDownloadOriginalButtonTitle()
                self.downloadOriginalImageButton.isEnabled = true
                self.downloadOriginalImageButton.isHidden = false
            }
        } else {
            self.downloadOriginalImageButton.isHidden = true
        }
    }
    
    override func hasCache() -> Bool {
        if SDImageCache.shared().imageFromCache(forKey: self.downloadURL!.absoluteString) != nil {
            return true
        } else if let extraInfo = self.item.extraInfo, let originalURL = extraInfo[DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL] as? NSURL {
            return SDImageCache.shared().imageFromCache(forKey: originalURL.absoluteString) != nil
        } else {
            return false
        }
    }
    
    override func fetchContent(withProgressBlock progressBlock: @escaping ((_ progress: Float) -> Void), _ completeBlock: @escaping ((_ data: Any?, _ error: Error?) -> Void)) {
        var downloadURL = self.downloadURL
        
        if let extraInfo = self.item.extraInfo, let originalURL = extraInfo[DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL] as? NSURL {
            if SDImageCache.shared().imageFromCache(forKey: originalURL.absoluteString) != nil {
                downloadURL = originalURL
            }
        }
        
        self.downloadImage(with: downloadURL!, progressBlock: progressBlock, completeBlock: completeBlock)
    }
    
}
