//
//  LinkBrowser.swift
//  On The Map
//
//  Created by David Fierstein on 11/3/15.
//  Copyright © 2015 David Fierstein. All rights reserved.
//

import UIKit

class LinkBrowser: UIViewController, UIWebViewDelegate {
    
    var link: String?
    
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var linkTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        // Google will be opened as a default, allowing browsing
        // If the user has entered a valid address, that will open
        if let currentLink = link {
            webview.loadRequest(NSURLRequest(URL: NSURL(string: currentLink)!))
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        linkTextField.text = webview.request?.URL?.absoluteString
    }
}
