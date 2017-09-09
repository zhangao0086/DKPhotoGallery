//
//  DKPhotoGalleryItem.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 08/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import Photos

public let DKPhotoGalleryItemExtraInfoKeyRemoteOriginalURL: String = "DKPhotoGalleryItemExtraInfoKeyRemoteOriginalURL"
public let DKPhotoGalleryItemExtraInfoKeyRemoteOriginalSize: String = "DKPhotoGalleryItemExtraInfoKeyRemoteOriginalSize"

@objc
open class DKPhotoGalleryItem: NSObject {
    
    open var image: UIImage?
    
    open var URL: NSURL?
    
    open var asset: PHAsset?
    open var assetLocalIdentifier: String?
    
    open var extraInfo: [String: NSObject]?
}

