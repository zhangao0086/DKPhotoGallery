//
//  ViewController.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 15/7/17.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit
import DKPhotoGallery

class ViewController: UIViewController {

	let items = [
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Image1")),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Image2")),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Image3")),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Image4")),
        DKPhotoGalleryItem(videoURL: NSURL(string:"http://cdn.video.shaozi.com/movie.mp4")!),
        DKPhotoGalleryItem(videoURL: NSURL(fileURLWithPath: Bundle.main.path(forResource: "movie", ofType: "mp4")!)),
        DKPhotoGalleryItem(videoURL: NSURL(string:"http://cdn.video.shaozi.com/movie1.mp4")!),
        DKPhotoGalleryItem(videoURL: NSURL(string:"https://s3.amazonaws.com/lookvideos.mp4/t/05093dabec6c9448f7058a4a08f998155b03cc41.mp4")!),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Website")),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Text")),
	]
    
    @IBOutlet var imageView: UIImageView?

	@IBAction func imageClicked(_ sender: UITapGestureRecognizer) {
		let gallery = DKPhotoGallery()
        gallery.singleTapMode = .dismiss
		gallery.items = self.items
		gallery.presentingFromImageView = sender.view as? UIImageView
        gallery.presentationIndex = 0
        
        gallery.dismissImageViewBlock = { [weak self] dismissIndex in
            if dismissIndex == 0 {
                return self?.imageView
            } else {
                return nil
            }
        }
        
        self.present(photoGallery: gallery)
    }
}

