//
//  DKPhotoLocalImagePreviewVC.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 08/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

class DKPhotoLocalImagePreviewVC: DKPhotoBasePreviewVC {

    private var image: UIImage?
    
    override func photoPreivewWillAppear() {
        super.photoPreivewWillAppear()
        
        if let image = self.item.image {
            self.image = image
        } else if let URL = self.item.URL {
            try! self.image = UIImage(data: Data(contentsOf: URL as URL))
        } else {
            assert(false)
        }
    }
    
    override func hasCache() -> Bool {
        return true
    }
    
    override func fetchImage(withProgressBlock progressBlock: @escaping ((_ progress: Float) -> Void), _ completeBlock: @escaping ((_ image: UIImage?, _ data: Data?, _ error: Error?) -> Void)) {
        completeBlock(self.image, nil, nil)
    }
}
