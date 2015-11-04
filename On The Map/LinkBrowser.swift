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
    
    @IBAction func returnToPinEditor(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
//        dismissViewControllerAnimated(true) { () in
//            viewControllerForUnwindSegueAction(", fromViewController: self, withSender: linkTextField.text)
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webview.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        // Google will be opened as a default, allowing browsing
        //webview.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.google.com")!))
        // If the user has entered a valid address, that will open
        if let currentLink = link {
            webview.loadRequest(NSURLRequest(URL: NSURL(string: currentLink)!))
           // print(webview.request?.URL?.absoluteString)
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        //print(webview.request?.URL?.absoluteString)
        linkTextField.text = webview.request?.URL?.absoluteString
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}
