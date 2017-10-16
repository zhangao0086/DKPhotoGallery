//
//  DKPhotoAssetPreviewVC.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 08/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import Photos

class DKPhotoAssetPreviewVC: DKPhotoBasePreviewVC {

    private var asset: PHAsset?
    
    override func photoPreviewWillAppear() {
        super.photoPreviewWillAppear()
        
        if let asset = self.item.asset {
            self.asset = asset
        } else {
            assert(false)
        }
    }
    
    override func hasCache() -> Bool {
        return false
    }
    
    override func fetchContent(withProgressBlock progressBlock: @escaping ((_ progress: Float) -> Void), completeBlock: @escaping ((_ data: Any?, _ error: Error?) -> Void)) {
        let options = PHImageRequestOptions()
        options.progressHandler = { (progress, error, stop, info) in
            if progress > 0 {
                progressBlock(Float(progress))
            }
        }
        
        let localIdentifier = self.asset!.localIdentifier
        
        PHImageManager.default().requestImage(for: self.asset!,
                                              targetSize: CGSize(width: UIScreen.main.bounds.width * UIScreen.main.scale, height:UIScreen.main.bounds.height * UIScreen.main.scale),
                                              contentMode: .default,
                                              options: options) { [weak self] (image, info) in
                                                guard localIdentifier == self?.asset?.localIdentifier else { return }
                                                
                                                if let image = image {
                                                    completeBlock(image, nil)
                                                } else {
                                                    let error = NSError(domain: Bundle.main.bundleIdentifier!, code: -1, userInfo: [
                                                        NSLocalizedDescriptionKey : "获取图片失败"
                                                        ])
                                                    completeBlock(nil, error)
                                                }
        }
    }
}
