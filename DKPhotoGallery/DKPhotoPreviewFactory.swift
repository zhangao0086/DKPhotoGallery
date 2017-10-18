//
//  DKPhotoPreviewFactory.swift
//  DKPhotoGalleryDemo
//
//  Created by ZhangAo on 15/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import Foundation
import Photos

extension DKPhotoBasePreviewVC {
    
    public class func photoPreviewClass(with item: DKPhotoGalleryItem) -> DKPhotoBasePreviewVC.Type {
        if let _ = item.image {
            
            return DKPhotoLocalImagePreviewVC.self
            
        } else if let URL = item.imageURL {
            
            if URL.isFileURL {
                return DKPhotoLocalImagePreviewVC.self
            } else {
                return DKPhotoRemoteImagePreviewVC.self
            }
            
        } else if let asset = item.asset {
            
            if asset.mediaType == .video {
                return DKPhotoPlayerPreviewVC.self
            } else {
                return DKPhotoAssetPreviewVC.self
            }
            
        } else if let assetLocalIdentifier = item.assetLocalIdentifier {
            item.asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetLocalIdentifier], options: nil).firstObject
            item.assetLocalIdentifier = nil
            
            return self.photoPreviewClass(with: item)
        } else if let _ = item.videoURL {
            return DKPhotoPlayerPreviewVC.self
        } else {
            assert(false)
            return DKPhotoBasePreviewVC.self
        }
    }
    
    public class func photoPreviewVC(with item: DKPhotoGalleryItem) -> DKPhotoBasePreviewVC {
        let previewVC = self.photoPreviewClass(with: item).init()
        previewVC.item = item
        
        return previewVC
    }
}
