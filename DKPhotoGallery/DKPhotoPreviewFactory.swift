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
