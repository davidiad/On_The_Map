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

//MARK: - Enums, Constants, Vars, Outlets, & Actions
    
    let client = UdacityClient.sharedInstance()
    
    enum UIState: Int {
        case Unspecified
        case Find
        case Geocoding
        case GeocodingError
        case Submit
    }
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation?
    var pinAnnotationView:MKPinAnnotationView!
    
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
    
    //TODO:- When Geocoding, animate the find location field transparency up and down, to indicate activity
    
    @IBAction func browseToLink(sender: AnyObject) {
        openLinkBrowser()
    }
    
    func openLinkBrowser() {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let linkBrowser = storyboard.instantiateViewControllerWithIdentifier("LinkBrowser")
        presentViewController(linkBrowser, animated: true, completion: nil)
    }
    
    @IBAction func findOnMap(sender: AnyObject) {

        self.configureUIForState(UIState.Geocoding)
        
        /* Code to add a delay, for testing UIState. Also un/comment the end brace of this, below at bottom of func
        // Wait, for testing
        let seconds = 4.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            // here code perfomed with delay
         */
       
        
        // In case there are any exisiting annotations, remove them
        if self.mapView.annotations.count != 0 {
            self.annotation = self.mapView.annotations[0] 
            self.mapView.removeAnnotation(self.annotation)
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.locationTextField.text!) { (placemarks, error) -> Void in
            if (error != nil) {
                //TODO: make sure the state is configured correctly for Geocode error
                self.configureUIForState(UIState.GeocodingError)
                self.alert("Could not find that place")
                return
            }
            if let placemark = placemarks?[0] {
                let lat = placemark.location?.coordinate.latitude
                let lon = placemark.location?.coordinate.longitude
                let region = placemark.region as! CLCircularRegion
                let mkregion = MKCoordinateRegionMakeWithDistance(
                    region.center,
                    region.radius,
                    region.radius);

                OnTheMapData.sharedInstance.studentInfoToPost?.lat = lat
                OnTheMapData.sharedInstance.studentInfoToPost?.lon = lon
                OnTheMapData.sharedInstance.studentInfoToPost?.location = self.locationTextField.text
                
                self.pointAnnotation = MKPointAnnotation()
                self.pointAnnotation!.title = self.locationTextField.text
                self.pointAnnotation!.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
                self.mapView.centerCoordinate = self.pointAnnotation!.coordinate
                self.mapView.setRegion(mkregion, animated: true)
                self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
                self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
                self.configureUIForState(UIState.Submit)
            }
        }
        
        /* // un/comment this to use wait func to test UIState
        }) // end of wait func
        // END wait for testing
        */
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion:  nil)
    }
    
    @IBAction func submit(sender: AnyObject) {
        if let _ = linkTextField.text {
            OnTheMapData.sharedInstance.studentInfoToPost?.link = NSURL(string: linkTextField.text!)
        }
        client.postOnTheMap(OnTheMapData.sharedInstance.studentInfoToPost!) {success, errorString, error in

            if success {
                /* TODO-To send alert message of success -- better if non-modal
                dispatch_async(dispatch_get_main_queue()) {
                    // Try this? NSNotificationCenter.defaultCenter().postNotificationName(refreshNotificationKey, object: self)
                    self.alert(errorString)
                }
*/
                self.dismissViewControllerAnimated(true) { () in
                    //TODO: after submit, the table is still not refreshing
                    NSNotificationCenter.defaultCenter().postNotificationName(refreshNotificationKey, object: self)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                        self.alert(errorString)
                }
            }
        }
    }
    
//    func notifyForRefresh () -> Void {
//        NSNotificationCenter.defaultCenter().postNotificationName(refreshNotificationKey, object: self)
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    func configureUIForState(state: UIState) {
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
            fadeViewInAndOut(queryLabel)
            fadeViewInAndOut(locationTextField)
            geocodingView.hidden = false
            activityView.startAnimating()
            queryLabel.text = "Searching for you"
            findButton.hidden = false
            submitButton.hidden = true
            mapView.hidden = false
            locationTextField.hidden = false
            linkTextField.hidden = true
        } else if state == UIState.GeocodingError {
            stopTheFade(queryLabel)
            stopTheFade(locationTextField)
            geocodingView.hidden = true
            activityView.stopAnimating()
            queryLabel.text = "Where are you studying today?"
            findButton.hidden = false
            submitButton.hidden = true
            mapView.hidden = false
            locationTextField.hidden = false
            linkTextField.hidden = true
        } else if state == UIState.Submit {
            stopTheFade(queryLabel)
            stopTheFade(locationTextField)
            activityView.stopAnimating()
            geocodingView.hidden = true
            queryLabel.text = "Enter a URL to share"
            findButton.hidden = true
            submitButton.hidden = false
            mapView.hidden = false
            locationTextField.hidden = true
            linkTextField.hidden = false
        }
    }
    
    //MARK: - Text and keyboard function - move to extension-navigation
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
    
    //MARK: Animation
    func fadeViewInAndOut (view: UIView) {
        let fade:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        fade.duration = 0.65
        fade.repeatCount = 1000 // large value, so it goes continuously
        fade.autoreverses = true
    
        fade.fromValue = 1.0
        fade.toValue = 0.2
        view.layer.addAnimation(fade, forKey: "opacity")
    }
    
    func stopTheFade(view: UIView) {
        if let _ = view.layer.animationForKey("opacity") {
            view.layer.removeAnimationForKey("opacity")
        }
    }

}
