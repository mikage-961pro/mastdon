//
//  ContainerController.swift
//  Ivory
//
//  Created by askosh on 06/28/19.
//  Copyright © 2019 askosh. All rights reserved.
//

import UIKit
import WebKit

class ContainerController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler  {
    
    @IBOutlet var webView: WKWebView!
    var refreshControl = UIRefreshControl()
    var token: String?
    var credentials: [String: String] = [:]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        App().getCredentialsFromStore() { (credentials) in
        
            self.credentials = credentials
            
            App().getTokenFromStore() { (token) in
                
                self.token = token
    
                let disableSelectionScriptString = "document.documentElement.style.webkitUserSelect='none';"
                let disableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"
                let accessTokenScriptString = "document.documentElement.setAttribute('token', '\(token)');"
                let accessInstanceURLScriptString = "document.documentElement.setAttribute('url', '\(credentials["instance_url"] ?? "")');"
                let disableSelectionScript = WKUserScript(source: disableSelectionScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                let disableCalloutScript = WKUserScript(source: disableCalloutScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                let accessTokenScript = WKUserScript(source: accessTokenScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                let accessInstanceURLScript = WKUserScript(source: accessInstanceURLScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                
                let controller = WKUserContentController()
                controller.addUserScript(disableSelectionScript)
                controller.addUserScript(disableCalloutScript)
                controller.addUserScript(accessTokenScript)
                controller.addUserScript(accessInstanceURLScript)
                controller.add(self, name: "ivorySetNewestNotificationId")
                controller.add(self, name: "ivorySetMessage")
    
                let config = WKWebViewConfiguration()
                config.userContentController = controller

                let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "App")!
                
                self.webView = WKWebView(frame: self.view.frame, configuration: config)
                self.webView.navigationDelegate = self
                self.webView.scrollView.delegate = NativeWebViewScrollViewDelegate.shared
                self.webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
                self.webView.scrollView.isScrollEnabled = true
                self.webView.scrollView.bounces = false
                self.webView.allowsBackForwardNavigationGestures = false
                self.webView.contentMode = .scaleToFill
                self.view.addSubview(self.webView)
                self.webView.loadFileURL(url, allowingReadAccessTo: url)
                
                /// Hacky solution to get top area to be with white fill
                let fillerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: UIApplication.shared.statusBarFrame.height))
                fillerView.backgroundColor = .white
                
                self.view.addSubview(fillerView)
                
            }
            
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "ivorySetNewestNotificationId" {
            
            let id = message.body as! String
            
            App().setNewestNotificationIdInStore(id: id)
            
        }
        
        if message.name == "ivorySetMessage" {
            
            let m = message.body
            
            print(m)
            
        }
        
    }
    
    /// responsible for navigation actions (eg opening a link)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url?.absoluteString {
            
            UIApplication.shared.open(URL(string: url)!)
            
        }
        
        decisionHandler(.allow)
        
    }
    
    // Disable zooming in webView
    func viewForZooming(in: UIScrollView) -> UIView? {
        
        return nil;
        
    }
    
}

class NativeWebViewScrollViewDelegate: NSObject, UIScrollViewDelegate {
    
    // MARK: - Shared delegate
    static var shared = NativeWebViewScrollViewDelegate()
    
    // MARK: - UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return nil
        
    }
    
}

extension UIDevice {
    
    var hasNotch: Bool {
        
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        
        return bottom > 0
        
    }
    
}

