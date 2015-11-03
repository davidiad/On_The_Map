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
    let loginView : FBSDKLoginButton = FBSDKLoginButton()
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookLoginButtonHolder: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginInfoLabel.text = ""
        
        // Notified when FB login is done and time to segue to Tabs
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "segueToTabController", name: segueNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayFacebookError", name: facebookErrorNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showActivityViewTrue", name: loginActivityNotificationKey, object: nil)
        
        // Facebook login
        
        // set the position of the FB login button relative to a placeholder on the storyboard
        view.addSubview(loginView)
        loginView.readPermissions = ["public_profile"]  //, "email", "user_friends"]
        loginView.delegate = client
        
        // if user is already logged in through FB
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // Code to add a delay, so that user can read msg that already logged in thru FB. Also un/comment the end brace of this, below at bottom of func
            showActivityView(true)
            loginInfoLabel.text = "You are already logged in through Facebook. Please wait..."
            let seconds = 1.5
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                
                // here code perfomed with delay
                
                NSNotificationCenter.defaultCenter().postNotificationName(refreshNotificationKey, object: self)
                // User is already logged in, so go to the next view controller.
                self.client.requestWithFacebookToken(FBSDKAccessToken.currentAccessToken().tokenString)
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.performSegueWithIdentifier("loginSegue", sender: nil)
//                }
                
            }) // end of delay func
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        showActivityView(false)
        loginView.center.x = view.center.x
        loginView.center.y = facebookLoginButtonHolder.center.y
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
        showActivityView(true)
        client.login(sender as! UIButton, userName: userName!, pw: pw!) { success, errorString in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showActivityView(false)
                    self.performSegueWithIdentifier("loginSegue", sender: sender)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showActivityView(false)
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
    
    func segueToTabController() {
        dispatch_async(dispatch_get_main_queue()) {
            self.showActivityView(false)
            self.performSegueWithIdentifier("loginSegue", sender: nil)
        }
    }
    
    //MARK:- UI functions
    
    func displayFacebookError() {
        showActivityView(false)
        loginInfoLabel.text = "You tried to log in through Facebook and there was some kind of problem."
    }
    
    // To show Activity indicator during login and loading
    func showActivityView (showing: Bool) {
        loadingView.hidden = !showing
        if showing {
            loadingActivityIndicator.startAnimating()
        } else {
            loadingActivityIndicator.stopAnimating()
        }
    }
    
    // parameterless version for easier use with NSNotification
    func showActivityViewTrue () {
        loadingView.hidden = false
        loadingActivityIndicator.startAnimating()
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
