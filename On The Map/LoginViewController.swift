//
//  LoginViewController.swift
//  On The Map
//
//  Created by David Fierstein on 9/2/15.
//  Copyright (c) 2015 David Fierstein. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let client = UdacityClient.sharedInstance()
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookLoginButtonHolder: UIView!
    @IBOutlet weak var loginInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginInfoLabel.text = ""
        
        // Notified when FB login is done and time to segue to Tabs
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "segueToTabController", name: segueNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayFacebookError", name: segueNotificationKey, object: nil)
        
        // Facebook login
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // User is already logged in, do work such as go to next view controller.
        } else {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            view.addSubview(loginView)
            // set the position of the FB login button relative to a placeholder on the storyboard
            //TODO: update the FB button position with the device changes orientation
            //TODO: make sure that warning label text won't overlap buttons
            loginView.center.x = view.center.x
            loginView.center.y = facebookLoginButtonHolder.center.y
            
            loginView.readPermissions = ["public_profile"]  //, "email", "user_friends"]
            loginView.delegate = client
        }
    }
    
    @IBAction func login(sender: AnyObject) {
        loginInfoLabel.text = ""
        view.endEditing(true) // touch the button, the keyboard retracts
        let userName = usernameTextField.text
        let pw = passwordTextField.text
        if pw == "" {
            shakeView(passwordTextField)
            loginInfoLabel.text = "Please enter a password"
        }
        if userName == "" {
            shakeView(usernameTextField)
            loginInfoLabel.text = "Please enter a user name"
        }
        if userName == "" {
            shakeView(usernameTextField)
        }
        if userName == "" || pw == "" {
            //Only proceed with login if parameters are not empty
            return
        } else {
            loginInfoLabel.text = ""
        }
        
        client.login(sender as! UIButton, userName: userName!, pw: pw!) { success, errorString in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    //self.client.getAllInfo() {success, errorString in
                       // if success {
                           self.performSegueWithIdentifier("loginSegue", sender: sender) 
                       // }
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
    }
    
//    func completeFBLogin() {
//        client.getAllInfo(){ success, errorString in
//            if success {
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.performSegueWithIdentifier("loginSegue", sender: nil)
//                }
//            }
//        }
//    }
    
    func displayFacebookError() {
        loginInfoLabel.text = "You tried tp log in thru FB and there was some kind of problem."
    }
    
    func segueToTabController() {
        //TODO: (?) add a delay so it doesn't segue too fast?
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("loginSegue", sender: nil)
        }
    }
    
    func shakeView(view: UIView){
        let shake:CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let from_point:CGPoint = CGPointMake(view.center.x - 5, view.center.y)
        let from_value:NSValue = NSValue(CGPoint: from_point)
        
        let to_point:CGPoint = CGPointMake(view.center.x + 5, view.center.y)
        let to_value:NSValue = NSValue(CGPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        view.layer.addAnimation(shake, forKey: "position")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Gesture Recognizer and keyboard functions
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        // Don't let tap GR hide textfields if a textfield is being touched for editing
        if touch.view == usernameTextField || touch.view == passwordTextField {
            return false
        }
        // Anywhere else on the screen, allow the tap gesture recognizer to hideToolBars
        return true
    }
    
    // Cancels textfield editing when user touches outside the textfield
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if usernameTextField.isFirstResponder() || passwordTextField.isFirstResponder() {
            view.endEditing(true)
        }
        super.touchesBegan(touches, withEvent:event)
    }
}
