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
    
    func getUdacityUserKey (sender: UIButton, userName: String, pw: String, completionHandler: (success: Bool, userKey: String?, errorString: String?) -> Void) {
        // Login is through regular login button
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let HTTPBodyString = "{\"udacity\": {\"username\": \"" + userName + "\", \"password\": \"" + pw + "\"}}"
        
        request.HTTPBody = HTTPBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
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
            
            self.extractKey(newData) { success, userKey, errorString in
                if success {
                    completionHandler(success: success, userKey: userKey, errorString: nil)
                } else {
                    completionHandler(success: success, userKey: nil, errorString: "Error in extracting key")
                }
            }
        }
        task.resume()
    }
    
    func getUdacityUserInfo (key: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        var URLString = "https://www.udacity.com/api/users/"
        if let key = self.model.studentInfoToPost?.uniqueKey {
            URLString += key
            
            let request = NSMutableURLRequest(URL: NSURL(string: URLString)!)
            let task = self.session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error...
                    //print("Error???: \(error)")
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
