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
public class DKPhotoGalleryItemConstant: NSObject {
    
    public class func extraInfoKeyRemoteOriginalURL() -> String {
        return DKPhotoGalleryItemExtraInfoKeyRemoteOriginalURL
    }
    
    public class func extraInfoKeyRemoteOriginalSize() -> String {
        return DKPhotoGalleryItemExtraInfoKeyRemoteOriginalSize
    }
    
}

@objc
open class DKPhotoGalleryItem: NSObject {
    
    open var image: UIImage?
    
    open var URL: NSURL?
    
    open var asset: PHAsset?
    open var assetLocalIdentifier: String?
    
    open var extraInfo: [String: NSObject]?
    
    public class func items(withURLs URLs: [NSURL]) -> [DKPhotoGalleryItem] {
        var items: [DKPhotoGalleryItem] = []
        for URL in URLs {
            let item = DKPhotoGalleryItem()
            item.URL = URL
            
            items.append(item)
        }
        
        return items
    }
    
    public class func items(withRemoteURLStrings URLStrings: [String]) -> [DKPhotoGalleryItem] {
        var items: [DKPhotoGalleryItem] = []
        for URLString in URLStrings {
            let item = DKPhotoGalleryItem()
            item.URL = NSURL(string: URLString)
            
            items.append(item)
        }
        
        return items
    }

}

