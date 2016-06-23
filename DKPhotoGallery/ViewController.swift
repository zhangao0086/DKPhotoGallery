//
//  ViewController.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 15/7/17.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func imageClicked(sender: UITapGestureRecognizer) {
		let browser = DKPhotoGallery()
		browser.fromImageView = sender.view as? UIImageView
        self.presentViewController(browser, animated: true, completion: nil)
    }
}

