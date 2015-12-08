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
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print("Webview fail load with error \(error)");
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true;
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        indicatorView.startAnimating()
        indicatorView.hidden = false
        print("Webview did start loading")
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        indicatorView.hidden = true
        indicatorView.stopAnimating()
        print("Webview did finish loading")
    }
    
    func loadPage() {
        if let url = urlPath {
            print("URL: \(url)")

            webView.delegate = self
            if let url = NSURL(string: url) {
                let request = NSURLRequest(URL: url);
                webView.loadRequest(request)
            }
        }
    }
}
