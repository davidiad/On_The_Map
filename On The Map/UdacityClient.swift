//
//  UdacityClient.swift
//  On The Map
//
//  Created by David Fierstein on 9/3/15.
//  Copyright (c) 2015 David Fierstein. All rights reserved.
//
//  Based on:
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

class UdacityClient : NSObject, FBSDKLoginButtonDelegate {
    
    let loginManager = FBSDKLoginManager()
    
    /* shared data model */
    var model = OnTheMapData.sharedInstance
    
    /* Shared session */
    var session: NSURLSession
    
    /* Configuration object */
    var config = UdacityConfig()
    
    /* Authentication state */
    var sessionID : String? = nil
    var userID : Int? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    //MARK:- Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil) {
            print(error)
        }
        else if result.isCancelled {
            print("Login was cancelled")
        }
        else {
            NSNotificationCenter.defaultCenter().postNotificationName(loginActivityNotificationKey, object: self)
            if result.grantedPermissions.contains("public_profile") {
                // Login to Udacity with Facebook token
                requestWithFacebookToken(result.token.tokenString ) {success, errorString in
                    if  success {
                        print("FB request success!")
                    } else {
                        print("in LB func: \(errorString)")
                    }
                }
            } else {
                print("FB permission not granted")
            }
        }
    }
    
    // Called after logging in with FB, or when app opens and user is already logged in to FB
    func requestWithFacebookToken(fbToken: String, completionHandler: (success: Bool, errorString: String?) -> Void ) {
        NSNotificationCenter.defaultCenter().postNotificationName(loginActivityNotificationKey, object: self)
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = ("{\"facebook_mobile\": {\"access_token\": \"" + fbToken + ";\"}}").dataUsingEncoding(NSUTF8StringEncoding)
        
        //let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print(error)
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print("response: \(response)")
            print("new data: \(NSString(data: newData, encoding: NSUTF8StringEncoding))")
            
            self.extractKey(newData) { success, userKey, errorString in
                if success {
                    self.getAllInfo() { success, errorString in
                        if success {
                            completionHandler(success: success, errorString: nil)
                            NSNotificationCenter.defaultCenter().postNotificationName(segueNotificationKey, object: self)
                        } else {
                            completionHandler(success: success, errorString: "Request for data failed after FB login")
                            NSNotificationCenter.defaultCenter().postNotificationName(facebookErrorNotificationKey, object: self)
                        }
                    }
                } else {
                    print("RWFBT: \(errorString)")
                    completionHandler(success: false, errorString: errorString)
                }
            }
        }
        task.resume()
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        udacityLogout()
    }
    
    func login(sender: UIButton, userName: String, pw: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        self.getUdacityUserKey(sender, userName: userName, pw: pw) { (success, userKey, errorString) in
            
            if success {
                
                self.getAllInfo() { success, errorString in
                    
                    completionHandler(success: success, errorString: errorString)
                }

            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    // Function to call after the Udacity User key has been gotten either from Udacity or through FB login
    func getAllInfo(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        if let userKey = model.studentInfoToPost?.uniqueKey {
            
            self.getUdacityUserInfo(userKey) { (success, errorString) in
                
                if success {
                    
                    self.getParseStudentInfo() {success, errorString in
                        if success {
                            // notify map and table to refresh
                            NSNotificationCenter.defaultCenter().postNotificationName(refreshNotificationKey, object: self)
                            completionHandler(success: success, errorString: errorString)
                        } else {
                            completionHandler(success: false, errorString: errorString)
                        }
                    }
                } else {
                    completionHandler(success: success, errorString: errorString)
                }
            }
        } else {
            completionHandler(success: false, errorString: "The unique user key appears to be incorrect")
        }
    }
        
        // Helper func to extract the key from the JSON results
        func extractKey(data: NSData, completionHandler: (success: Bool, userKey: String?, errorString: String?) -> Void) {
            do {
                let results = try (NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary)
                if let accountDictionary = results!.valueForKey("account") as? NSDictionary {
                    if let key = accountDictionary.valueForKey("key") as? String {
                        self.model.studentInfoToPost?.uniqueKey = key
                        completionHandler(success: true, userKey: key, errorString: nil)
                    } else {
                        completionHandler(success: false, userKey: nil, errorString: "parsing error with key")
                    }
                } else {
                    if let resultsString = (results?.description) {
                        var errorString = "There was an error with this description:\n" + resultsString
                        // clean up error string
                        errorString = errorString.stringByReplacingOccurrencesOfString("{", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        errorString = errorString.stringByReplacingOccurrencesOfString("}", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        completionHandler(success: false, userKey: nil, errorString: errorString)
                    } else {
                        completionHandler(success: false, userKey: nil, errorString: "parsing error with account")
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(doneLogAndLoadNotificationKey, object: self)
                    
                    
                }
            } catch {
                completionHandler(success: false, userKey: nil, errorString: "Could not parse the account info from Udacity")
            }
        }
        
        // Use Parse API to get student data, with completion handler
        func getParseStudentInfo(completionHandler: (success: Bool, errorString: String?) -> Void) {
            let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?order=-updatedAt")!)
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            let task = session.dataTaskWithRequest(request) { data, response, error in
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    let errorString = ("There was an error with the Parse request: \(error)")
                    completionHandler(success: false, errorString: errorString)
                    return
                }
                
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    let invalid = "Your download request for student locations from Parse returned an invalid response!"
                    var errorString = invalid
                    if let response = response as? NSHTTPURLResponse {
                        errorString = "\(invalid) Status code: \(response.statusCode)"
                    } else if let response = response {
                        errorString = "\(invalid) Response: \(response)"
                    }
                    completionHandler(success: false, errorString: errorString)
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    completionHandler(success: false, errorString: "No student location data was returned by the request to Parse!")
                    return
                }
                
                // Store the student data into the model
                self.model.convertJSON(data) {success, errorString in
                    if success {
                        completionHandler(success: success, errorString: errorString)
                    }
                }
                
            }
            task.resume()
        }
    
    //TODO: add completion handler to return any error messages
        func udacityLogout () {
            
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
            request.HTTPMethod = "DELETE"
            var xsrfCookie: NSHTTPCookie? = nil
            let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in sharedCookieStorage.cookies! { //as! [NSHTTPCookie] {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
            let session = NSURLSession.sharedSession()
            //TODO: guard and swift 2.0 error handling
            let task = session.dataTaskWithRequest(request) { data, response, error in
                guard (error == nil) else {
                    _ = ("There was an error with the Udacity logout request: \(error)")
                    //completionHandler(success: false, userKey: nil, errorString: errorString)
                    return
                }
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    let invalid = "Your request to log out from Udacity returned an invalid response!"
                    var errorString = invalid
                    if let response = response as? NSHTTPURLResponse {
                        errorString = "\(invalid) Status code: \(response.statusCode)"
                    } else if let response = response {
                        errorString = "\(invalid) Response: \(response)"
                    }
                    print(errorString)
                    //completionHandler(success: false, userKey: nil, errorString: errorString)
                    return
                }
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    //completionHandler(success: false, userKey: nil, errorString: "No user info data was returned by the request to Udacity!")
                    return
                }
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            }
            task.resume()
            model.studentInfoToPost?.uniqueKey = "default"
            model.studentInfoToPost?.firstName  = "D"
            model.studentInfoToPost?.lastName = "Fault"
        }
    
        // Add pin to the map
        func postOnTheMap (userInfo: StudentInfo, completionHandler: (success: Bool, errorString: String, error: NSError?) -> Void) {
            let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
            request.HTTPMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            var HTTPBodyString = "{\"uniqueKey\": \""
            if let uniqueKey = userInfo.uniqueKey { HTTPBodyString += uniqueKey }
            HTTPBodyString += "\", \"firstName\": \""
            if let firstName = userInfo.firstName { HTTPBodyString += firstName }
            HTTPBodyString += "\", \"lastName\": \""
            if let lastName = userInfo.lastName { HTTPBodyString += lastName }
            HTTPBodyString += "\", \"mapString\": \""
            if let location = userInfo.location { HTTPBodyString += location }
            HTTPBodyString += "\", \"mediaURL\": \""
            if let link = userInfo.link {
                HTTPBodyString += "\(link)"
            }/* else {
            HTTPBodyString += "https://vimeo.com/user39343057" // my vimeo site
            }*/
            HTTPBodyString += "\", \"latitude\": "
            if let lat = userInfo.lat { HTTPBodyString += "\(lat)" }
            HTTPBodyString += ", \"longitude\": "
            if let lon = userInfo.lon { HTTPBodyString += "\(lon)" }
            HTTPBodyString += "}"
            
            request.HTTPBody = HTTPBodyString.dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error…
                    completionHandler(success: false, errorString: "Error in POSTing: The Internet connection appears to be offline", error: error)
                    return
                }
                UdacityClient.parseJSONWithCompletionHandler(data!) {results, error in
                    if error != nil {
                        completionHandler(success: false, errorString: "parsing error", error: error)
                    } else {
                        var messageString = ""
                        if let createdAtString = results.valueForKey("createdAt") as? String {
                            messageString = "Successful POST at " + createdAtString
                            completionHandler(success: true, errorString: messageString, error: error)
                        } else if let eString = results.valueForKey("error") as? String {
                            messageString = "POST failed: " + eString
                            completionHandler(success: false, errorString: messageString, error: error)
                        }
                    }
                }
            }
            task.resume()
        }
        
        func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
            
            /* 1. Set the parameters */
            var mutableParameters = parameters
            mutableParameters[ParameterKeys.ParseApiKey] = Constants.ParseApiKey
            
            /* 2/3. Build the URL and configure the request */
            let urlString = Constants.BaseURLSecure + method + UdacityClient.escapedParameters(mutableParameters)
            let url = NSURL(string: urlString)!
            let request = NSMutableURLRequest(URL: url)
            var jsonifyError: NSError? = nil
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
            } catch let error as NSError {
                jsonifyError = error
                request.HTTPBody = nil
                print("jsonify error: \(jsonifyError)")
            }
            
            /* 4. Make the request */
            let task = session.dataTaskWithRequest(request) {data, response, downloadError in
                
                /* 5/6. Parse the data and use the data (happens in completion handler) */
                if let _ = downloadError {
                    //let newError = UdacityClient.errorForData(data, response: response, error: error)
                    completionHandler(result: nil, error: downloadError)
                } else {
                    UdacityClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
                }
            }
            
            /* 7. Start the request */
            task.resume()
            
            return task
        }
        
        // MARK: - Helpers
        
        /* Helper: Substitute the key for the value that is contained within the method name */
        class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
            if method.rangeOfString("{\(key)}") != nil {
                return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
            } else {
                return nil
            }
        }
        
        /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
        class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
            
            if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String : AnyObject] {
                
                if let errorMessage = parsedResult[UdacityClient.JSONResponseKeys.StatusMessage] as? String {
                    
                    let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                    
                    return NSError(domain: "Udacity Error", code: 1, userInfo: userInfo)
                }
            }
            
            return error
        }
        
        // from MovieMan 2.0
        /* Helper: Given raw JSON, return a usable Foundation object */
        class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
            }
            
            completionHandler(result: parsedResult, error: nil)
        }
        
        /* Helper function: Given a dictionary of parameters, convert to a string for a url */
        class func escapedParameters(parameters: [String : AnyObject]) -> String {
            
            var urlVars = [String]()
            
            for (key, value) in parameters {
                
                /* Make sure that it is a string value */
                let stringValue = "\(value)"
                
                /* Escape it */
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                /* Append it */
                urlVars += [key + "=" + "\(escapedValue!)"]
                
            }
            
            return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
        }
        
        // MARK: - Shared Instance
        
        class func sharedInstance() -> UdacityClient {
            
            struct Singleton {
                static var sharedInstance = UdacityClient()
            }
            
            return Singleton.sharedInstance
        }
}