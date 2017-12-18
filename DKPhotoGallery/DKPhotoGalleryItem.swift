//
//  DKPhotoGalleryItem.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 08/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import Photos

public let DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL: String = "DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL"    // URL.
public let DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalSize: String = "DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalSize"  // (Optional)UInt. The number of bytes of the image.

@objc
public class DKPhotoGalleryItemConstant: NSObject {
    
    public class func extraInfoKeyRemoteImageOriginalURL() -> String {
        return DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL
    }
    
    public class func extraInfoKeyRemoteImageOriginalSize() -> String {
        return DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalSize
    }
    
}

//////////////////////////////////////////////////////////////////

@objc
open class DKPhotoGalleryItem: NSObject {
    
    /// The image to be set initially, until the image request finishes.
    open var thumbnail: UIImage?
    
    open var image: UIImage?
    open var imageURL: URL?
    
    open var videoURL: URL?
    
    /**
     DKPhotoGallery will automatically decide whether to create ImagePreview or PlayerPreview via mediaType of the asset.
     
     See more: DKPhotoPreviewFactory.swift
     */
    open var asset: PHAsset?
    open var assetLocalIdentifier: String?
    
    /**
     Used for some optional features.
     
     For ImagePreview, you can enable the original image download feature with a key named DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL.
     */
    open var extraInfo: [String: Any]?
    
    convenience public init(image: UIImage) {
        self.init()
        
        self.image = image
    }
    
    convenience public init(imageURL: URL) {
        self.init()
        
        self.imageURL = imageURL
    }
    
    convenience public init(videoURL: URL) {
        self.init()
        
        self.videoURL = videoURL
    }
    
    convenience public init(asset: PHAsset) {
        self.init()
        
        self.asset = asset
    }
    
    public class func items(withImageURLs URLs: [URL]) -> [DKPhotoGalleryItem] {
        var items: [DKPhotoGalleryItem] = []
        for URL in URLs {
            let item = DKPhotoGalleryItem()
            item.imageURL = URL
            
            items.append(item)
        }
        
        return items
    }
    
    public class func items(withImageURLStrings URLStrings: [String]) -> [DKPhotoGalleryItem] {
        var items: [DKPhotoGalleryItem] = []
        for URLString in URLStrings {
            let item = DKPhotoGalleryItem()
            item.imageURL = URL(string: URLString)
            
            items.append(item)
        }
        
        return items
    }

}

