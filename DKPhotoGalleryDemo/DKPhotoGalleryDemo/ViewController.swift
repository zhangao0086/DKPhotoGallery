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

	var images = [
		#imageLiteral(resourceName: "Image1"),
		#imageLiteral(resourceName: "Image2"),
		#imageLiteral(resourceName: "Image3"),
		#imageLiteral(resourceName: "Image4")
	]
	
	var URLs: [URL] = []
	
	var items: [DKPhotoGalleryItem] = []
    
    @IBOutlet var imageView: UIImageView?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		
		for (_, image) in self.images.enumerated() {
            let item = DKPhotoGalleryItem()
            item.image = image
            
			self.items.append(item)
		}

    }

	@IBAction func imageClicked(_ sender: UITapGestureRecognizer) {
		let gallery = DKPhotoGallery()
        gallery.singleTapMode = .dismiss
		gallery.items = self.items
		gallery.presentingFromImageView = sender.view as? UIImageView
        gallery.presentationIndex = self.images.index(of: self.imageView!.image!)!
        
        gallery.dismissImageViewBlock = { [weak self] dismissIndex in
            if self?.imageView?.image == self?.images[dismissIndex] {
                return self?.imageView
            } else {
                return nil
            }
        }
        
        self.present(photoGallery: gallery)
    }
}

