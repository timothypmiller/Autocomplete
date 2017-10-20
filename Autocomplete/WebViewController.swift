//
//  WebViewController.swift
//  Autocomplete
//
//  Created by Timothy P Miller on 2/20/15.
//  Copyright (c) 2015 Timothy P Miller. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    var urlPath: String?
    @IBOutlet var webView: UIWebView!
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Webview fail load with error \(error)");
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true;
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        print("Webview did start loading")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        indicatorView.isHidden = true
        indicatorView.stopAnimating()
        print("Webview did finish loading")
    }
    
    func loadPage() {
        if let url = urlPath {
            print("URL: \(url)")

            webView.delegate = self
            if let url = URL(string: url) {
                let request = URLRequest(url: url);
                webView.loadRequest(request)
            }
        }
    }
}
