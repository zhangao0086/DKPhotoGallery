//
//  ViewController.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 15/7/17.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit
import DKPhotoGallery

class ViewController: UIViewController, UIViewControllerPreviewingDelegate {

	let items = [
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Image1")),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Image2")),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Image3")),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Image4")),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Website")),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Text")),
        {
            let item = DKPhotoGalleryItem(imageURL: URL(string:"https://sz-preview.oss-cn-hangzhou.aliyuncs.com/pics/10003/b29259d837d4aaeef4b33c9dbc964a5b?x-oss-process=image/resize,m_lfit,h_512,w_512/quality,Q_80")!)
            item.extraInfo = [
                DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL: URL(string:"https://sz-preview.oss-cn-hangzhou.aliyuncs.com/pics/10003/b29259d837d4aaeef4b33c9dbc964a5b")!
            ]
            return item
        }(),
        DKPhotoGalleryItem(imageURL: URL(string:"https://sz-preview.oss-cn-hangzhou.aliyuncs.com/pics/10003/f09a6f2a93ce0a7ec0f65d74ecd672c6")!),
        DKPhotoGalleryItem(imageURL: URL(string:"https://sz-preview.oss-cn-hangzhou.aliyuncs.com/pics/10003/3e72f1044a5fe30fda44823a587ca6e3")!),
        DKPhotoGalleryItem(imageURL: URL(string:"https://sz-preview.oss-cn-hangzhou.aliyuncs.com/pics/10003/48a2e5b67b57e7dc6e9df81b9069c8f0")!),
        DKPhotoGalleryItem(imageURL: URL(string:"https://sz-preview.oss-cn-hangzhou.aliyuncs.com/pics/10003/d95f6c69c7d0dde2cd1872fd0d541f60")!),
        DKPhotoGalleryItem(imageURL: URL(string:"https://sz-preview.oss-cn-hangzhou.aliyuncs.com/pics/10003/0133eac2899d801b417807b6a281341d")!),
        DKPhotoGalleryItem(imageURL: URL(string:"https://sz-preview.oss-cn-hangzhou.aliyuncs.com/pics/10003/3c25c16c562d8aabee665122c72875ea")!),
        DKPhotoGalleryItem(imageURL: URL(string:"https://sz-preview.oss-cn-hangzhou.aliyuncs.com/pics/10003/96b59884abbc9e529c58cff35335b4c2")!),
        DKPhotoGalleryItem(imageURL: URL(string:"https://sz-preview.oss-cn-hangzhou.aliyuncs.com/pics/10003/4efb791d9a3579d4983ed36076531d76")!),
        DKPhotoGalleryItem(imageURL: URL(string:"https://sz-preview.oss-cn-hangzhou.aliyuncs.com/pics/10003/684446b02eed178fbeaa362524a1ccea")!),
        DKPhotoGalleryItem(imageURL: URL(string:"https://mandourjr.files.wordpress.com/2014/01/091511-empire-state-building-picture-ext-day.jpg")!),
        DKPhotoGalleryItem(imageURL: URL(string:"http://images.fineartamerica.com/images-medium-large-5/galaxy-road-kevin-palmer.jpg")!),
        DKPhotoGalleryItem(imageURL: URL(string:"http://www.79n.cn/uploads/allimg/150905/error.jpg")!),
        DKPhotoGalleryItem(imageURL: URL(fileURLWithPath: Bundle.main.path(forResource: "empire-state-building-picture-ext-day", ofType: "jpg")!)),
        DKPhotoGalleryItem(videoURL: URL(string:"http://cn-video.shaozi.com/movie.mp4")!),
        DKPhotoGalleryItem(videoURL: URL(fileURLWithPath: Bundle.main.path(forResource: "movie", ofType: "mp4")!)),
        DKPhotoGalleryItem(videoURL: URL(string:"http://cdn.video.shaozi.com/movie1.mp4")!),
        DKPhotoGalleryItem(videoURL: URL(string:"https://s3.amazonaws.com/lookvideos.mp4/t/05093dabec6c9448f7058a4a08f998155b03cc41.mp4")!),
	]

    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 9.0, *) {
            self.registerForPreviewing(with: self, sourceView: self.imageView)
        }
    }

    @IBAction func imageClicked(_ sender: UITapGestureRecognizer) {
        let gallery = self.createGallery()
        self.present(photoGallery: gallery)
    }
    
    func createGallery() -> DKPhotoGallery {
        let gallery = DKPhotoGallery()
        gallery.singleTapMode = .dismiss
        gallery.items = self.items
        gallery.presentingFromImageView = self.imageView
        gallery.presentationIndex = 0
        
        gallery.finishedBlock = { [weak self] dismissIndex in
            if dismissIndex == 0 {
                return self?.imageView
            } else {
                return nil
            }
        }
        
        return gallery
    }
    
    // MARK: - UIViewControllerPreviewingDelegate
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return self.createGallery()
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.present(photoGallery: viewControllerToCommit as! DKPhotoGallery)
    }
}

