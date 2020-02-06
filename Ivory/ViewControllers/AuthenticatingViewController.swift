//
//  AuthenticatingViewController.swift
//  Ivory
//
//  Created by Asko Nomm on 17/07/2019.
//  Copyright © 2019 Asko Nomm. All rights reserved.
//

import UIKit
import WebKit

class AuthenticatingViewController: UIViewController, WKNavigationDelegate {
    
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set WebView
        App().getCredentialsFromStore() { (credentials) in
            
            self.navigationItem.title = credentials["instance_url"]
            
            let webView = WKWebView(frame: self.view.bounds)
            
            var components = URLComponents()
                components.scheme = "https"
                components.host = credentials["instance_url"]
                components.path = "/oauth/authorize"
                components.queryItems = [
                    URLQueryItem(name: "response_type", value: "code"),
                    URLQueryItem(name: "client_id", value: credentials["client_id"]),
                    URLQueryItem(name: "client_secret", value: credentials["client_secret"]),
                    URLQueryItem(name: "redirect_uri", value: "http://localhost:8000"),
                    URLQueryItem(name: "scope", value: "write read follow")
                ]

            let url = components.url
            
            let request = URLRequest(url: url!)
            
            webView.navigationDelegate = self
            webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
            
            self.view.addSubview(webView)
            
            // Loading indicator
            self.activityIndicator = UIActivityIndicatorView()
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.style = UIActivityIndicatorView.Style.gray
            
            self.view.addSubview(self.activityIndicator)
            
            // Load page
            webView.load(request)

        
            
        }

        // Set back button
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backAction))
    
    }
    
    func showActivityIndicator(show: Bool) {
        
        if show {
            
            activityIndicator.startAnimating()
            
        } else {
            
            activityIndicator.stopAnimating()
            
        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        showActivityIndicator(show: false)
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        showActivityIndicator(show: true)
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        showActivityIndicator(show: false)
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url?.absoluteString {
            
            // We use localhost as a redirect URL which we then capture, to get the token from it
            // And then we show the app as usual
            if(url.starts(with: "http://localhost")) {
                
                let code = String(url.split(separator: "?")[1].split(separator: "=")[1])
            
                if(code.contains("access_denied")) {
                    
                    let vc = AuthenticateViewController()
                    let navigationController = UINavigationController()
                    
                    navigationController.modalPresentationStyle = .fullScreen
                    navigationController.viewControllers = [vc]
                    
                    self.present(navigationController, animated: false, completion: nil)
                    
                    
                } else {
                    
                    App().setCode(code: code)
                    
                    App().getCredentialsFromStore() { (credentials) in
                        
                        App().getCodeFromStore() { (code) in
                            
                            App().getToken(credentials: credentials, code: code) { (token) in
                                
                                OperationQueue.main.addOperation {
                                    
                                    let vc = ContainerController()
                                    let navigationController = UINavigationController()
                                    
                                    navigationController.modalPresentationStyle = .fullScreen
                                    navigationController.viewControllers = [vc]
                                    
                                    self.present(navigationController, animated: false, completion: nil)
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        decisionHandler(.allow)
        
    }
    
    @objc private func backAction(sender: UIButton!) {
        
        dismiss(animated: false, completion: nil)
        
    }
    
    
}
