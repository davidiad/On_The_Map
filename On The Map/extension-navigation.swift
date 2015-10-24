//
//  extension-navigation.swift
//  On The Map
//
//  Created by David Fierstein on 10/7/15.
//  Copyright (c) 2015 David Fierstein. All rights reserved.


import Foundation
import UIKit

extension UIViewController {
    

    
    func setupNav() {
        
        var leftLogoutBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutTapped")
        
        var rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Pin", style: UIBarButtonItemStyle.Plain, target: self, action: "pinTapped")
        
        var rightRefreshButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshTapped")
        self.navigationItem.setRightBarButtonItems([rightRefreshButtonItem,rightAddBarButtonItem], animated: true)
        navigationItem.setLeftBarButtonItem(leftLogoutBarButtonItem, animated: true)
    }
    
    // MARK: - Bar Button actions
    
    func logoutTapped () {
        let client = UdacityClient.sharedInstance()
        client.udacityLogout()
        // TODO: do I need a dispatch async, or a completion handler here?
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refreshTapped() {
        println("refresh tapped")
        let client = UdacityClient.sharedInstance()
        client.taskGETParseStudentInfo() {parseSuccess, parseError in
            if parseSuccess {
                NSNotificationCenter.defaultCenter().postNotificationName(myNotificationKey, object: self)
            } else {
                self.alert("Download Failed :-(")
            }
        }
    }
    
    func pinTapped() {
        openPinEditor()
    }
    
    func openPinEditor() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var pinEditor = storyboard.instantiateViewControllerWithIdentifier("PinEditor") as! PinEditor
        presentViewController(pinEditor, animated: true, completion: nil)
    }
    
    func alert(alertString: String) {
        let alertController = UIAlertController(title: nil, message: alertString, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        //return
    }
}
