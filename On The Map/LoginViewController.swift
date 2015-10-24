//
//  LoginViewController.swift
//  On The Map
//
//  Created by David Fierstein on 9/2/15.
//  Copyright (c) 2015 David Fierstein. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let client = UdacityClient.sharedInstance()
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginInfoLabel: UILabel!
    
    @IBAction func login(sender: AnyObject) {
        loginInfoLabel.text = ""
        if let userName = usernameTextField.text {
            if let pw = passwordTextField.text {
                client.taskPOSTUdacityLogin(userName, pw: pw) {success, key, errorString in
                    if success {
                        // to avoid crash because not on main queue
                        //                        NSOperationQueue.mainQueue().addOperationWithBlock {
                        //                            if let alertString = errorString {
                        //                                self.alert(errorString!)
                        //                            }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.performSegueWithIdentifier("loginSegue", sender: sender)
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            if let alertString = errorString {
                                if alertString == "The Internet connection appears to be offline." {
                                    self.alert(errorString!)
                                } else {
                                    self.loginInfoLabel.text = alertString
                                    if alertString.lowercaseString.rangeOfString("username") != nil {
                                        self.shakeView(self.usernameTextField)
                                    } else if alertString.lowercaseString.rangeOfString("password") != nil {
                                        self.shakeView(self.passwordTextField)
                                    } else {
                                        self.shakeView(self.usernameTextField)
                                        self.shakeView(self.passwordTextField)
                                    }
                                }
                            }
                        }
                    }
                }
                //performSegueWithIdentifier("loginSegue", sender: sender)
            } else {
                // handle error
                println("error with login")
            }
        }
    }
    
    /* old login works
@IBAction func login(sender: AnyObject) {
if let userName = usernameTextField.text {
if let pw = passwordTextField.text {
client.login(userName, pw: pw) {success, errorString in
if success {
// to avoid crash because not on main queue
//                        NSOperationQueue.mainQueue().addOperationWithBlock {
//                            if let alertString = errorString {
//                                self.alert(errorString!)
//                            }
dispatch_async(dispatch_get_main_queue()) {
self.performSegueWithIdentifier("loginSegue", sender: sender)
}
} else {
dispatch_async(dispatch_get_main_queue()) {
if let alertString = errorString {
self.alert(errorString!)
}
}
}
}
//performSegueWithIdentifier("loginSegue", sender: sender)
} else {
// handle error
println("error with login")
}
}
}
*/

    /* already defined in extension
    func alert(alertString: String) {
        let alertController = UIAlertController(title: nil, message: alertString, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
        //return
    }
    */
    
    func shakeView(view: UIView){
        var shake:CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        var from_point:CGPoint = CGPointMake(view.center.x - 5, view.center.y)
        var from_value:NSValue = NSValue(CGPoint: from_point)
        
        var to_point:CGPoint = CGPointMake(view.center.x + 5, view.center.y)
        var to_value:NSValue = NSValue(CGPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        view.layer.addAnimation(shake, forKey: "position")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loginInfoLabel.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
