//
//  PinEditor.swift
//  On The Map
//
//  Created by David Fierstein on 10/2/15.
//  Copyright (c) 2015 David Fierstein. All rights reserved.
//

import UIKit
import MapKit

class PinEditor: UIViewController, UITextFieldDelegate {

//MARK: - Constants, Enums, Vars, Outlets, & Actions
    
    let client = UdacityClient.sharedInstance()
    
    enum UIState: Int {
        case Unspecified
        case Find
        case Geocoding
        case Submit
    }
    
    //var keyboardHeight: CGFloat?
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation?
    var pinAnnotationView:MKPinAnnotationView!
    
    // activity indicator stuff
//    var messageFrame = UIView()
//    var activityIndicator = UIActivityIndicatorView()
//    var strLabel = UILabel()
    
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewMid: UIView!
    @IBOutlet weak var viewBot: UIView!
    @IBOutlet weak var queryLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var geocodingView: UIView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func viewDidAppear(animated: Bool) {
       // showActivityIndicator("Geocoding", true)
    }
    
    //TODO:- When Geocoding, animate the find location field transparency up and down, to indicate activity
    
    /*func showActivityIndicator(msg:String, _ indicator:Bool ) {
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.whiteColor()
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.55)
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
        if !indicator {
            activityIndicator.stopAnimating()
            messageFrame.removeFromSuperview()
        }
    }*/
    
    @IBAction func findOnMap(sender: AnyObject) {
        //TODO: alert view if geocode fails, and goes to a state for that
        self.configureUIForState(UIState.Geocoding)
        // In case there are any exisiting annotations, remove them
        if self.mapView.annotations.count != 0 {
            annotation = self.mapView.annotations[0] 
            self.mapView.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = locationTextField.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil {
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            } else {
                //info?.location = self.locationTextView.text
                //info.lat = localSearchResponse.boundingRegion.center.latitude
                self.pointAnnotation = MKPointAnnotation()
                self.pointAnnotation!.title = self.locationTextField.text
                self.pointAnnotation!.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
                self.mapView.centerCoordinate = self.pointAnnotation!.coordinate
                self.mapView.setRegion(localSearchResponse!.boundingRegion, animated: true)
                self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
                self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
                
                /*
                let ts = "today"
                let name = "D Fault"
                let loc = "College 42"
                let default_url = NSURL(string: "http://www.kimba.com")
                self.info = StudentInfo(timestamp: ts, name: name, location: loc, link: default_url!)
                //TODO:-?- create a dictionary of the info, and use that dictionary to init the StudentInfo to post object
                self.info?.lat = localSearchResponse.boundingRegion.center.latitude
                self.info?.lon = localSearchResponse.boundingRegion.center.longitude
                self.info?.location = self.locationTextView.text
                OnTheMapData.sharedInstance.studentInfoToPost = self.info
                */
                
                // Why even go thru a locally created StudentInfo? Why not save directly to model? eg:
                OnTheMapData.sharedInstance.studentInfoToPost?.lat = localSearchResponse!.boundingRegion.center.latitude
                OnTheMapData.sharedInstance.studentInfoToPost?.lon = localSearchResponse!.boundingRegion.center.longitude
                OnTheMapData.sharedInstance.studentInfoToPost?.location = self.locationTextField.text
                
                self.configureUIForState(UIState.Submit)
                //TODO:- add first and last names to post
                //TODO:-Add url to info for posting
                //TODO:-add timestamp to post, used for sorting - But isn't this created on the server?
               
                              //OnTheMapData.sharedInstance.studentInfoToPost?.lat = localSearchResponse!.boundingRegion.center.latitude
                
                // Example of a search response:
//                <MKLocalSearchResponse: 0x7f9a491d69d0> {
//                    boundingRegion = "<center:+42.31441587, -70.97015347 span:+0.17292700, +0.44270304>";
//                    mapItems =     (
//                        "<MKMapItem: 0x7f9a44748220> {\n    isCurrentLocation = 0;\n    name = \"Boston, MA\";\n    placemark = \"Boston, MA, Boston, MA, United States @ <+42.35889400,-71.05674200> +/- 0.00m, region CLCircularRegion (identifier:'<+42.31441589,-70.97015350> radius 20581.91', center:<+42.31441589,-70.97015350>, radius:20581.91m)\";\n    url = \"http://en.wikipedia.org/wiki/Boston\";\n}"
//                    );
//                }
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion:  nil)
    }
    
    @IBAction func submit(sender: AnyObject) {
        if let _ = linkTextField.text {
            OnTheMapData.sharedInstance.studentInfoToPost?.link = NSURL(string: linkTextField.text!)
        }
        //client.postOnTheMap(OnTheMapData.sharedInstance.studentInfoToPost!)
        client.postOnTheMap(OnTheMapData.sharedInstance.studentInfoToPost!) {success, errorString, error in
            //TODO: Error Handling
            //        if let lat = OnTheMapData.sharedInstance.studentInfoToPost?.lat {
            //            if let lon = OnTheMapData.sharedInstance.studentInfoToPost?.lon {
            //                println("Lon and Lat looking good!")
            //                client.postOnTheMap(locationTextView.text, lat: lat, lon: lon)
            //            }
            //        } else {
            //            println("error posting lat or lon. Lat: \(OnTheMapData.sharedInstance.studentInfoToPost?.lat)  Lon: OnTheMapData.sharedInstance.studentInfoToPost?.lon) ")
            //        }
            //needs to be in completion handler?
            
            
            //dismissViewControllerAnimated(true, completion:  NSNotificationCenter.defaultCenter().postNotificationName(myNotificationKey, object: self),, -> Void)
            //TODO: refresh map and table AFTER the data has been refreshed
            //notifyForRefresh()
            //dismissViewControllerAnimated(true, completion: <#(() -> Void)?##() -> Void#>)
            //dismissViewControllerAnimated(true, completion: notifyForRefresh())
            //dismissViewControllerAnimated(true, completion: notifyForRefresh())
            if success {
                /* TODO-To send alert message of success -- better if non-modal
                dispatch_async(dispatch_get_main_queue()) {
                    // Try this? NSNotificationCenter.defaultCenter().postNotificationName(myNotificationKey, object: self)
                    self.alert(errorString)
                }
*/
                self.dismissViewControllerAnimated(true) { () in
                    //TODO: after submit, the table is still not refreshing
                    NSNotificationCenter.defaultCenter().postNotificationName(myNotificationKey, object: self)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    //TODO: I guess errorstring should be an optional? and then unwrapped
                    //if let alertString = errorString {
                        self.alert(errorString)
                   // }
                }
            }
        }
        //{ (localSearchResponse, error) -> Void in
    }
    
//    func notifyForRefresh () -> VOid {
//        NSNotificationCenter.defaultCenter().postNotificationName(myNotificationKey, object: self)
//        return
//    }
    
// MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        linkTextField.delegate = self
        geocodingView.layer.cornerRadius = 15
        geocodingView.layer.masksToBounds = true
        configureUIForState(UIState.Find)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        //subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        //unsubscribeToKeyboardNotifications()
    }
    
    func configureUIForState(state: UIState) {
        //TODO: Add a state for when GEOcoding fails, and an alert view pops up
        if state == UIState.Find {
            activityView.stopAnimating()
            geocodingView.hidden = true
            queryLabel.text = "Where are you studying today?"
            findButton.hidden = false
            mapView.hidden = true
            submitButton.hidden = true
            locationTextField.hidden = false
            linkTextField.hidden = true
        } else if state == UIState.Geocoding {
            geocodingView.hidden = false
            activityView.startAnimating()
            //showActivityIndicator("Geocoding", true)
            queryLabel.text = "Searching for you"
            findButton.hidden = false
            submitButton.hidden = true
            mapView.hidden = false
            locationTextField.hidden = false
            linkTextField.hidden = false
        } else if state == UIState.Submit {
            activityView.stopAnimating()
            geocodingView.hidden = true
            //showActivityIndicator("Found you!", false)
            queryLabel.text = "Enter a URL to share"
            findButton.hidden = true
            submitButton.hidden = false
            mapView.hidden = false
            locationTextField.hidden = true
            linkTextField.hidden = false
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK:- POST data (//TODO:-move outside the view controller)
    
//    func postOnTheMap () {
//        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
//        request.HTTPMethod = "POST"
//        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
//        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"David\", \"lastName\": \"Pettit\",\"mapString\": \"Black Rock City, NV\", \"mediaURL\": \"http://www.burningman.org\",\"latitude\": 30.0104, \"longitude\": -112.07417}".dataUsingEncoding(NSUTF8StringEncoding)
//        let session = NSURLSession.sharedSession()
//        let task = session.dataTaskWithRequest(request) { data, response, error in
//            if error != nil { // Handle error…
//                return
//            }
//            println(NSString(data: data, encoding: NSUTF8StringEncoding))
//        }
//        task.resume()
//    }
    
    //MARK: - Keyboard
   /*
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if locationTextField.isFirstResponder() {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardHeight != nil && locationTextField.isFirstResponder() {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboardHeight = keyboardSize.CGRectValue().height
        return keyboardHeight!
    }
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK:- Gesture Recognizer functions
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        // Don't let tap GR hide textfields if a textfield is being touched for editing
        if touch.view == locationTextField || touch.view == linkTextField {
            return false
        }
        // Anywhere else on the screen, allow the tap gesture recognizer to hideToolBars
        return true
    }
    
    // Cancels textfield editing when user touches outside the textfield
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if locationTextField.isFirstResponder() || linkTextField.isFirstResponder() {
            view.endEditing(true)
        }
        super.touchesBegan(touches, withEvent:event)
    }
}
