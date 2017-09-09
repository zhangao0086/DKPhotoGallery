//
//  DKPhotoProgressIndicator.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 08/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit

class DKPhotoProgressIndicator: UIActivityIndicatorView, DKPhotoProgressIndicatorProtocol {

    required init(with view: UIView) {
        super.init(activityIndicatorStyle: .gray)
        
        view.addSubview(self)
        self.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        self.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        self.hidesWhenStopped = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var progress: Float = 0

    func reset() {
        self.progress = 0
    }
    
    func start() {
        self.startAnimating()
    }
    
    func stop() {
        self.stopAnimating()
    }

}
