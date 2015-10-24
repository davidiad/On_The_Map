//
//  MapViewController.swift
//  On The Map
//
//  Created by David Fierstein on 9/30/15.
//  Copyright (c) 2015 David Fierstein. All rights reserved.
//

import UIKit
import MapKit

/**
* This view controller demonstrates the objects involved in displaying pins on a map.
*
* The map is a MKMapView.
* The pins are represented by MKPointAnnotation instances.
*
* The view controller conforms to the MKMapViewDelegate so that it can receive a method
* invocation when a pin annotation is tapped. It accomplishes this using two delegate
* methods: one to put a small "info" button on the right side of each pin, and one to
* respond when the "info" button is tapped.
*/

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //var _studentInfo: [StudentInfo]?
    
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        setupNav()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "readAndDisplayAnnotations", name: myNotificationKey, object: nil)
        navigationController?.title = "On The Map"
//        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
//        navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewDidAppear(animated: Bool) {
        readAndDisplayAnnotations()
        //    override func viewDidLoad() {
        //super.viewDidLoad()
        //TODO: unwrapping correctly?
    /*    if let _studentInfoArray = OnTheMapData.sharedInstance.studentInfoArray {
            // The "locations" array is an array of dictionary objects that are similar to the JSON
            // data that you can download from parse.
            //let locations = hardCodedLocationData()
            
            // We will create an MKPointAnnotation for each dictionary in "locations". The
            // point annotations will be stored in this array, and then provided to the map view.
            var annotations = [MKPointAnnotation]()
            
            // The "locations" array is loaded with the sample data below. We are using the dictionaries
            // to create map annotations. This would be more stylish if the dictionaries were being
            // used to create custom structs. Perhaps StudentLocation structs.
            
            for studentInfo in _studentInfoArray {
                
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                let lat = CLLocationDegrees(studentInfo.lat!)
                let lon = CLLocationDegrees(studentInfo.lon!)
                
                //let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
                //let long = CLLocationDegrees(dictionary["longitude"] as! Double)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let name = studentInfo.name
                //let first = dictionary["firstName"] as! String
                //let last = dictionary["lastName"] as! String
                //let mediaURL = "\(studentInfo.link)"  //dictionary["mediaURL"] as! String
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                var annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title =  name //"\(first) \(last)"
                if let linkString = studentInfo.link {
                    let mediaURL = "\(linkString)"
                    annotation.subtitle = mediaURL
                }
                
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
            
            // When the array is complete, we add the annotations to the map.
            self.mapView.addAnnotations(annotations)
        } else {
            println("studentInfo nil?")
        }*/
    }
    
    func readAndDisplayAnnotations() {
        if let _studentInfoArray = OnTheMapData.sharedInstance.studentInfoArray {
            // The "locations" array is an array of dictionary objects that are similar to the JSON
            // data that you can download from parse.
            //let locations = hardCodedLocationData()
            
            // We will create an MKPointAnnotation for each dictionary in "locations". The
            // point annotations will be stored in this array, and then provided to the map view.
            var annotations = [MKPointAnnotation]()
            
            // The "locations" array is loaded with the sample data below. We are using the dictionaries
            // to create map annotations. This would be more stylish if the dictionaries were being
            // used to create custom structs. Perhaps StudentLocation structs.
            
            for studentInfo in _studentInfoArray {
                
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                let lat = CLLocationDegrees(studentInfo.lat!)
                let lon = CLLocationDegrees(studentInfo.lon!)
                
                //let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
                //let long = CLLocationDegrees(dictionary["longitude"] as! Double)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let name = studentInfo.name
                //let first = dictionary["firstName"] as! String
                //let last = dictionary["lastName"] as! String
                //let mediaURL = "\(studentInfo.link)"  //dictionary["mediaURL"] as! String
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                var annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title =  name //"\(first) \(last)"
                if let linkString = studentInfo.link {
                    let mediaURL = "\(linkString)"
                    annotation.subtitle = mediaURL
                }
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
            }
            
            // When the array is complete, we add the annotations to the map.
            self.mapView.addAnnotations(annotations)
        } else {
            println("studentInfo nil?")
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
    
    // MARK: - Sample Data
    
    // Some sample data. This is a dictionary that is more or less similar to the
    // JSON data that you will download from Parse.
/*
    func hardCodedLocationData() -> [[String : AnyObject]] {
        return  [
            [
                "createdAt" : "2015-02-24T22:27:14.456Z",
                "firstName" : "Jessica",
                "lastName" : "Uelmen",
                "latitude" : 28.1461248,
                "longitude" : -82.75676799999999,
                "mapString" : "Tarpon Springs, FL",
                "mediaURL" : "www.linkedin.com/in/jessicauelmen/en",
                "objectId" : "kj18GEaWD8",
                "uniqueKey" : 872458750,
                "updatedAt" : "2015-03-09T22:07:09.593Z"
            ], [
                "createdAt" : "2015-02-24T22:35:30.639Z",
                "firstName" : "Gabrielle",
                "lastName" : "Miller-Messner",
                "latitude" : 35.1740471,
                "longitude" : -79.3922539,
                "mapString" : "Southern Pines, NC",
                "mediaURL" : "http://www.linkedin.com/pub/gabrielle-miller-messner/11/557/60/en",
                "objectId" : "8ZEuHF5uX8",
                "uniqueKey" : 2256298598,
                "updatedAt" : "2015-03-11T03:23:49.582Z"
            ], [
                "createdAt" : "2015-02-24T22:30:54.442Z",
                "firstName" : "Jason",
                "lastName" : "Schatz",
                "latitude" : 37.7617,
                "longitude" : -122.4216,
                "mapString" : "18th and Valencia, San Francisco, CA",
                "mediaURL" : "http://en.wikipedia.org/wiki/Swift_%28programming_language%29",
                "objectId" : "hiz0vOTmrL",
                "uniqueKey" : 2362758535,
                "updatedAt" : "2015-03-10T17:20:31.828Z"
            ], [
                "createdAt" : "2015-03-11T02:48:18.321Z",
                "firstName" : "Jarrod",
                "lastName" : "Parkes",
                "latitude" : 34.73037,
                "longitude" : -86.58611000000001,
                "mapString" : "Huntsville, Alabama",
                "mediaURL" : "https://linkedin.com/in/jarrodparkes",
                "objectId" : "CDHfAy8sdp",
                "uniqueKey" : 996618664,
                "updatedAt" : "2015-03-13T03:37:58.389Z"
            ]
        ]
    }*/
}
