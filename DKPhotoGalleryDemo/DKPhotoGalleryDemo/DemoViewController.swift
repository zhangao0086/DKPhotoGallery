//
//  DemoViewController.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 15/7/17.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit
import DKPhotoGallery

class PreviewCell: UITableViewCell {
    
    @IBOutlet var contentImageView: UIImageView!
    @IBOutlet var contentLabel: UILabel!
    
}

class DemoViewController: UIViewController, UIViewControllerPreviewingDelegate, UITableViewDataSource, UITableViewDelegate, DKPhotoGalleryIncrementalDataSource {
    
    var items = [
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Image1")),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Image2")),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Image3")),
        DKPhotoGalleryItem(videoURL: URL(string: "http://192.168.0.2/screenview/7-13.mp4")!),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Image4")),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Website")),
        DKPhotoGalleryItem(image: #imageLiteral(resourceName: "Text")),
        {
            let item = DKPhotoGalleryItem(imageURL: URL(string:"https://sz-preview-new.oss-cn-hangzhou.aliyuncs.com/pics/10003/b29259d837d4aaeef4b33c9dbc964a5b?x-oss-process=image/resize,m_lfit,h_512,w_512/quality,Q_80")!)
            item.extraInfo = [
                DKPhotoGalleryItemExtraInfoKeyRemoteImageOriginalURL: URL(string:"https://sz-preview-new.oss-cn-hangzhou.aliyuncs.com/pics/10003/b29259d837d4aaeef4b33c9dbc964a5b")!
            ]
            return item
        }(),
        DKPhotoGalleryItem(imageURL: URL(string:"https://mandourjr.files.wordpress.com/2014/01/091511-empire-state-building-picture-ext-day.jpg")!),
        DKPhotoGalleryItem(imageURL: URL(string:"http://images.fineartamerica.com/images-medium-large-5/galaxy-road-kevin-palmer.jpg")!),
        DKPhotoGalleryItem(imageURL: URL(string:"http://www.79n.cn/uploads/allimg/150905/error.jpg")!),
        DKPhotoGalleryItem(imageURL: URL(fileURLWithPath: Bundle.main.path(forResource: "empire-state-building-picture-ext-day", ofType: "jpg")!)),
        DKPhotoGalleryItem(videoURL: URL(string:"http://cn-video.shaozi.com/movie.mp4")!),
        DKPhotoGalleryItem(videoURL: URL(fileURLWithPath: Bundle.main.path(forResource: "movie", ofType: "mp4")!)),
        DKPhotoGalleryItem(videoURL: URL(string:"http://cdn.video.shaozi.com/movie1.mp4")!),
        DKPhotoGalleryItem(videoURL: URL(string:"https://s3.amazonaws.com/lookvideos.mp4/t/05093dabec6c9448f7058a4a08f998155b03cc41.mp4")!),
	]

    @IBOutlet var tableView: UITableView!
    @IBOutlet var enableIncrementalSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 9.0, *) {
            self.registerForPreviewing(with: self, sourceView: self.tableView)
        }
        
        if #available(iOS 11.0, *) {
            let pdfItem = DKPhotoGalleryItem(pdfURL: URL(string: "http://www.pdf995.com/samples/pdf.pdf")!)
            items.insert(pdfItem, at: 4)
        }
    }
    
    func createGallery(fromIndexPath indexPath: IndexPath) -> DKPhotoGallery {
        let item = self.items[indexPath.row]
        
        let gallery = DKPhotoGallery()
        gallery.singleTapMode = .dismiss
        gallery.presentationIndex = self.items.index(of: item)!
        
        if self.enableIncrementalSwitch.isOn {
            gallery.items = [item]
            gallery.incrementalDataSource = self
        } else {
            gallery.items = self.items
        }
        
        if let cell = self.tableView.cellForRow(at: indexPath) as? PreviewCell, let imageView = cell.contentImageView {
            gallery.presentingFromImageView = imageView
            
            gallery.finishedBlock = { dismissIndex, dismissItem in
                if item == dismissItem {
                    return imageView
                } else {
                    return nil
                }
            }
        }
        
        return gallery
    }

    // MARK: - UIViewControllerPreviewingDelegate
    
    @available(iOS 9.0, *)
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = self.tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) as? PreviewCell {
            previewingContext.sourceRect = self.tableView.convert(cell.contentImageView.frame, from: cell)
            
            let gallery = self.createGallery(fromIndexPath: indexPath)
            return gallery
        } else {
            return nil
        }
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.present(photoGallery: viewControllerToCommit as! DKPhotoGallery)
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! PreviewCell
        let item = self.items[indexPath.row]
        if let image = item.image {
            cell.contentImageView.image = image
            cell.contentLabel.text = nil
        } else {
            cell.contentImageView.image = nil
            
            if let imageURL = item.imageURL {
                cell.contentLabel.text = imageURL.absoluteString
            } else if let videoURL = item.videoURL {
                cell.contentLabel.text = videoURL.absoluteString
            } else if let pdfURL = item.pdfURL {
                cell.contentLabel.text = pdfURL.absoluteString
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let gallery = self.createGallery(fromIndexPath: indexPath)
        self.present(photoGallery: gallery)
    }
    
    // MARK: - DKPhotoGalleryIncrementalDataSource
    
    func photoGallery(_ gallery: DKPhotoGallery, itemsBefore item: DKPhotoGalleryItem?, resultHandler: @escaping (([DKPhotoGalleryItem]?, Error?) -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let item = item {
                if let index = self.items.index(of: item), index > 0 {
                    resultHandler(Array(self.items[max(0, index - 2)...index - 1]), nil)
                } else {
                    resultHandler([], nil)
                }
            } else {
                resultHandler([], nil)
            }
        }
    }
    
    func photoGallery(_ gallery: DKPhotoGallery, itemsAfter item: DKPhotoGalleryItem?, resultHandler: @escaping (([DKPhotoGalleryItem]?, Error?) -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let item = item {
                if let index = self.items.index(of: item), index < self.items.count - 1 {
                    resultHandler(Array(self.items[index + 1...min(self.items.count - 1, index + 2)]), nil)
                } else {
                    resultHandler([], nil)
                }
            } else {
                resultHandler([], nil)
            }
        }
    }
}
