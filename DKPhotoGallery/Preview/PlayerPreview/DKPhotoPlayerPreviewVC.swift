//
//  DKPhotoPlayerPreviewVC.swift
//  DKPhotoGalleryDemo
//
//  Created by ZhangAo on 15/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import AVKit
import Photos

open class DKPhotoPlayerPreviewVC: DKPhotoBasePreviewVC {

    public var closeBlock: (() -> Void)?
    
    private var playerView: DKPlayerView!
    
    deinit {
        self.playerView.stop()
    }
    
    open override func photoPreviewWillAppear() {
        super.photoPreviewWillAppear()
        
        self.playerView.isControlHidden = true
    }
    
    open override func photoPreviewWillDisappear() {
        super.photoPreviewWillDisappear()
        
        self.playerView.pause()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        self.playerView.reset()
    }
    
    // MARK: - DKPhotoBasePreviewDataSource
    
    open override func createContentView() -> UIView {
        self.playerView = DKPlayerView(controlParentView: self.view)
        return self.playerView
    }
    
    open override func contentSize() -> CGSize {
        return self.view.bounds.size
    }
    
    open override func fetchContent(withProgressBlock progressBlock: @escaping ((Float) -> Void), completeBlock: @escaping ((Any?, Error?) -> Void)) {
        if let videoURL = self.item.videoURL {
            completeBlock(videoURL, nil)
        } else if let asset = self.item.asset {
            let identifier = asset.localIdentifier
            PHImageManager.default().requestAVAsset(forVideo: asset,
                                                    options: nil,
                                                    resultHandler: { [weak self] (avAsset, _, _) in
                                                        if let asset = self?.item.asset, asset.localIdentifier == identifier {
                                                            let URLAsset = avAsset as! AVURLAsset
                                                            completeBlock(URLAsset.url, nil)
                                                        }
            })
        } else {
            assert(false)
        }
    }
    
    open override func updateContentView(with content: Any) {
        guard let contentURL = content as? URL else { return }
        
        self.playerView.closeBlock = self.closeBlock
        
        self.playerView.url = contentURL
    }
    
    open override func enableZoom() -> Bool {
        return false
    }
    
    public override func enableIndicatorView() -> Bool {
        return false
    }
    
    open override var previewType: DKPhotoPreviewType {
        get {
            return .video
        }
    }

}
