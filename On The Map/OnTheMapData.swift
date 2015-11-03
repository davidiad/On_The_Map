//
//  OnTheMapData.swift
//  On The Map
//
//  Created by David Fierstein on 9/12/15.
//  Copyright (c) 2015 David Fierstein. All rights reserved.
//  Reads in raw JSON data as a dictionary and stores it in Swift data structures

import Foundation
import UIKit

class OnTheMapData {
    static let sharedInstance = OnTheMapData()
    var studentInfoArray: [StudentInfo]?
    var studentInfoToPost: StudentInfo?
    
    //This prevents others from using the default '()' initializer for this class.
    private init() {
        studentInfoToPost = StudentInfo()
        studentInfoArray = [StudentInfo]()
    }
    
    func convertJSON(data: NSData, completionHandler: (success: Bool, errorString: String?) -> Void) {

        do {
            let results = try (NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary)
            if let arrayOfDictionaries = results!.valueForKey("results") as? [[String:AnyObject]] {
                // Put info into student info array
                if studentInfoArray?.count > 0 {
                    studentInfoArray?.removeAll(keepCapacity: false)
                }
                for dict in arrayOfDictionaries {
                    let info = StudentInfo(data: dict)
                    studentInfoArray?.append(info)
                }
                completionHandler(success: true, errorString: nil)
            } else {
                // There must have been a problem reading results from the JSON
                completionHandler(success: false, errorString: "Could not read JSON results")
            }
        }
        catch {
            completionHandler(success: false, errorString: "JSON could not be fetched")
        }
    }
    
    //TODO: add completion handler, so can send back success and errors to the calling function. For instance, what if the user key is incorrect?
    func storeUserInfo(data: NSData) {
        do {
            let userResults = try (NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary)
            if let userInfo = userResults!.valueForKey("user") as? NSDictionary {
                if let firstName = userInfo.valueForKey("first_name") as? String {
                    studentInfoToPost?.firstName = firstName
                }
                if let lastName = userInfo.valueForKey("last_name") as? String {
                    studentInfoToPost?.lastName = lastName
                }
                if let uniqueKey = userInfo.valueForKey("key") as? String {
                    studentInfoToPost?.uniqueKey = uniqueKey
                }
            }
        } catch {
            
        }
        
    }
    
    // Calculate hue values for use in ListViewController
    func backgroundHue(indexValue: Int) -> CGFloat {
        var hueValue = (CGFloat(indexValue) * 0.083  * CGFloat(indexValue) * 0.05) + 0.03
        while hueValue > 1 {
            hueValue -= 0.98
        }
        return hueValue
    }
}


