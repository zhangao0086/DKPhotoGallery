//
//  DKPhotoGalleryItem.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 08/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import Photos

public let DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL: String = "DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL"
public let DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalSize: String = "DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalSize"

@objc
public class DKPhotoGalleryItemConstant: NSObject {
    
    public class func extraInfoKeyRemoteImageOriginalURL() -> String {
        return DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL
    }
    
    public class func extraInfoKeyRemoteImageOriginalSize() -> String {
        return DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalSize
    }
    
}

@objc
open class DKPhotoGalleryItem: NSObject {
    
    open var image: UIImage?
    open var imageURL: NSURL?
    
    open var asset: PHAsset?
    open var assetLocalIdentifier: String?
    
    open var extraInfo: [String: NSObject]?
    
    public class func items(withImageURLs URLs: [NSURL]) -> [DKPhotoGalleryItem] {
        var items: [DKPhotoGalleryItem] = []
        for URL in URLs {
            let item = DKPhotoGalleryItem()
            item.imageURL = URL
            
            items.append(item)
        }
        
        return items
    }
    
    public class func items(withRemoteImageURLStrings URLStrings: [String]) -> [DKPhotoGalleryItem] {
        var items: [DKPhotoGalleryItem] = []
        for URLString in URLStrings {
            let item = DKPhotoGalleryItem()
            item.imageURL = NSURL(string: URLString)
            
            items.append(item)
        }
        
        return items
    }

}

