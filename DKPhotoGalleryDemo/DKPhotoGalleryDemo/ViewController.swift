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
        DKPhotoGalleryItem(imageURL: NSURL(string:"https://mandourjr.files.wordpress.com/2014/01/091511-empire-state-building-picture-ext-day.jpg")!),
        DKPhotoGalleryItem(imageURL: NSURL(string:"http://images.fineartamerica.com/images-medium-large-5/galaxy-road-kevin-palmer.jpg")!),
        DKPhotoGalleryItem(imageURL: NSURL(string:"http://www.79n.cn/uploads/allimg/150905/error.jpg")!),
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

