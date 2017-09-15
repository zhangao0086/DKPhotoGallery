//
//  DKPhotoWebVC.swift
//  DKPhotoGallery
//
//  Created by ZhangAo on 08/09/2017.
//  Copyright © 2017 ZhangAo. All rights reserved.
//

import UIKit
import WebKit

class DKPhotoWebVC: UIViewController, WKNavigationDelegate {
    
    var urlString: String!
    
    private var webView: WKWebView!
    private var spinner: UIActivityIndicatorView!
    private var errorLabel: UILabel!
    
    private var hasFinished: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.view.backgroundColor = UIColor.white
        
        self.webView = self.createWebView()
        self.webView.navigationDelegate = self
        self.webView.frame = CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height)
        self.webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.webView)
        
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.spinner.hidesWhenStopped = true
        self.spinner.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
        self.spinner.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        self.view.addSubview(self.spinner)
        
        self.errorLabel = UILabel(frame: self.view.bounds)
        self.errorLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.errorLabel.textAlignment = .center
        self.errorLabel.isHidden = true
        self.errorLabel.numberOfLines = 0
        self.view.addSubview(self.errorLabel)
        
        self.spinner.startAnimating()
        
        let request = URLRequest(url: URL(string: self.urlString)!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 0)
        self.webView.load(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if let photoGallery = self.navigationController as? DKPhotoGallery {
            UIView.animate(withDuration: 0.1, animations: { 
                photoGallery.statusBar?.alpha = 1
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if let photoGallery = self.navigationController as? DKPhotoGallery {
            UIView.animate(withDuration: 0.1, animations: {
                photoGallery.statusBar?.alpha = 0
            })
        }
    }
    
    func createWebView() -> WKWebView {
        let jsScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jsScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = contentController
        
        return WKWebView(frame: CGRect.zero, configuration: webConfig)
    }
    
    func markAsFinished() {
        self.hasFinished = true
        self.errorLabel.text = nil
        if !self.errorLabel.isHidden {
            self.errorLabel.isHidden = true
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.spinner.stopAnimating()
        
        webView.evaluateJavaScript("document.title") { [weak self] (result, error) in
            self?.title = result as? String
            
            self?.markAsFinished()
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.spinner.stopAnimating()
        let _error = error as NSError
        if _error.code == NSURLErrorCancelled {
            return
        }
        
        if !self.hasFinished {
            self.errorLabel.isHidden = false
            self.errorLabel.text = error.localizedDescription
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other {
            if navigationAction.request.url?.scheme == "itms-appss" {
                self.spinner.stopAnimating()
            }
        }
        
        decisionHandler(.allow)
    }
}
