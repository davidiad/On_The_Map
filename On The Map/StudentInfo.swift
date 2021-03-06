//
//  StudentInfo.swift
//  On The Map
//
//  Created by David Fierstein on 9/11/15.
//  Copyright (c) 2015 David Fierstein. All rights reserved.
//

import Foundation

struct StudentInfo {
    var timestamp: NSDate? // may convert to NSDate // do we even need this one? for sorting?
//    var name: String?
    var firstName: String?
    var lastName: String?
    var uniqueKey: String?
    var location: String?
    var lon: Double?
    var lat: Double?
    var link: NSURL?
    
    init() {
        // property values default to nil
    }
    
    init(data: NSDictionary) {

        if let timestampString = data.valueForKey("updatedAt") as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let timestamp = dateFormatter.dateFromString(timestampString)
            self.timestamp = timestamp
        }

        
        firstName = (data.valueForKey("firstName") as! String)
        lastName = (data.valueForKey("lastName") as! String)

        if let mapString = data.valueForKey("mapString") as? String {
            location = mapString
        }
        if let lonString = (data.valueForKey("longitude") as? NSNumber) {
            lon = lonString.doubleValue
        }
        if let latString = (data.valueForKey("latitude") as? NSNumber) {
            lat = latString.doubleValue
        }
        let linkString = data.valueForKey("mediaURL") as! String

        if let url = NSURL(string: linkString) {
            link = url
        }
    }
}