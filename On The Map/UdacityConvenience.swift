//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by David Fierstein on 9/3/15.
//  Copyright (c) 2015 David Fierstein. All rights reserved.
//
// Based on:
//
//  TMDBConvenience.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import UIKit
import Foundation

// MARK: - Convenient Resource Methods

extension UdacityClient {
    
    func getUdacityUserKey (userName: String, pw: String, completionHandler: (success: Bool, userKey: String?, errorString: String?) -> Void) {
        //TODO: get url string from constants
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let HTTPBodyString = "{\"udacity\": {\"username\": \"" + userName + "\", \"password\": \"" + pw + "\"}}"
        
        request.HTTPBody = HTTPBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            //TODO: subject to crash if unwrapping an optional (data I guess)
            
            // Guard for errors TODO: if possible, make into a function which can be reused
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                let errorString = ("There was an error with the Udacity User Key request: \(error)")
                completionHandler(success: false, userKey: nil, errorString: errorString)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                let invalid = "Your request to log in to Udacity returned an invalid response!"
                var errorString = invalid
                if let response = response as? NSHTTPURLResponse {
                    errorString = "\(invalid) Status code: \(response.statusCode)"
                } else if let response = response {
                    errorString = "\(invalid) Response: \(response)"
                }
                completionHandler(success: false, userKey: nil, errorString: errorString)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(success: false, userKey: nil, errorString: "No user info data was returned by the request to Udacity!")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            if let results = try! (NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as? NSDictionary) {
                if let accountDictionary = results.valueForKey("account") as? NSDictionary {
                    if let key = accountDictionary.valueForKey("key") as? String {
                        self.model.studentInfoToPost?.uniqueKey = key
                        completionHandler(success: true, userKey: key, errorString: nil)
                    }
                } else {
                    completionHandler(success: false, userKey: nil, errorString: "Could not parse the account info from Udacity")
                }
            } else {
                completionHandler(success: false, userKey: nil, errorString: "Was not able to read the user info from Udacity")
            }
        }
        task.resume()
    }
    
    func getUdacityUserInfo (key: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        //TODO: get url string from constants
        var URLString = "https://www.udacity.com/api/users/"
        if let key = self.model.studentInfoToPost?.uniqueKey {
            URLString += key
            //URLString += "forcedErrorForTesting"
            // Note: If the key were incorrect, there'd be no way of knowing until trying to post with the user info
            // or check when trying to store the data (first name, last name) in the model
            let request = NSMutableURLRequest(URL: NSURL(string: URLString)!)
            let task = self.session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error...
                    print("Error???: \(error)")
                    completionHandler(success: false, errorString: "\(error)")
                    return
                }
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                self.model.storeUserInfo(newData)
                completionHandler(success: true, errorString: nil)
            }
            task.resume()
        }
    }
}
