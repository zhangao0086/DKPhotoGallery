//
//  DKPhotoProgressIndicatorProtocol.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 08/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import Foundation
import UIKit

public protocol DKPhotoProgressIndicatorProtocol : NSObjectProtocol {
    
    init(with view: UIView)
    
    var progress: Float {get set}
    
    func reset()
    
    func start()
    
    func stop()
}

