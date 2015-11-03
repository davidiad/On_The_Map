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
            // Handle cancellations
        }
        else {
            if result.grantedPermissions.contains("public_profile") {
                // Login to Udacity with Facebook token
                let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
                request.HTTPMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                request.HTTPBody = ("{\"facebook_mobile\": {\"access_token\": \"" + result.token.tokenString + ";\"}}").dataUsingEncoding(NSUTF8StringEncoding)
                
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request) { data, response, error in
                    if error != nil {
                        print(error)
                        return
                    }
                    let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                    
                    self.extractKey(newData) { success, userKey, errorString in
                        if success {
                            self.getAllInfo() { success, errorString in
                                if success {
                                    NSNotificationCenter.defaultCenter().postNotificationName(segueNotificationKey, object: self)
                                } else {
                                    NSNotificationCenter.defaultCenter().postNotificationName(facebookErrorNotificationKey, object: self)
                                }
                            }
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        udacityLogout()
        //alert("Facebook log out")
    }
    
    // MARK: - GET
    
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
    
//    func login(sender: UIButton, userName: String, pw: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
//        
//        self.getUdacityUserKey(sender, userName: userName, pw: pw) { (success, userKey, errorString) in
//            
//            if success {
//                
//                self.getUdacityUserInfo(userKey!) { (success, errorString) in
//                    
//                    if success {
//                        
//                        self.getParseStudentInfo() {success, errorString in
//                            if success {
//                                // notify map and table to refresh
//                                NSNotificationCenter.defaultCenter().postNotificationName(refreshNotificationKey, object: self)
//                                completionHandler(success: success, errorString: errorString)
//                            } else {
//                                completionHandler(success: false, errorString: errorString)
//                            }
//                        }
//                    } else {
//                        completionHandler(success: success, errorString: errorString)
//                    }
//                }
//            } else {
//                completionHandler(success: success, errorString: errorString)
//            }
//        }
//    }
    
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
    
        
        /* JSON response examples
        Optional({"account": {"registered": true, "key": "u41464181"}, "session": {"id": "1476243674S27b30af924994d7bb5296b689449bd93", "expiration": "2015-12-12T03:41:14.728500Z"}})
        Optional({"status": 400, "parameter": "udacity.username", "error": "trails.Error 400: Missing parameter 'username'"})
        Optional({"status": 400, "parameter": "udacity.password", "error": "trails.Error 400: Missing parameter 'password'"})
        Optional({"status": 403, "error": "Account not found or invalid credentials."})
        */
        
        // Helper func to extract the key from the JSON results
        func extractKey(data: NSData, completionHandler: (success: Bool, userKey: String?, errorString: String?) -> Void) {
            do {
                let results = try (NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary)
                if let accountDictionary = results!.valueForKey("account") as? NSDictionary {
                    if let key = accountDictionary.valueForKey("key") as? String {
                        self.model.studentInfoToPost?.uniqueKey = key
                        print("Key has been extracted and stored: \(self.model.studentInfoToPost?.uniqueKey)")
                        completionHandler(success: true, userKey: key, errorString: nil)
                    } else {
                        completionHandler(success: false, userKey: nil, errorString: "parsing error with key")
                    }
                } else {
                    completionHandler(success: false, userKey: nil, errorString: "parsing error with account")
                }
            } catch {
                completionHandler(success: false, userKey: nil, errorString: "Could not parse the account info from Udacity")
            }
        }
        
        // Use Parse API to get student data, with completion handler
        func getParseStudentInfo(completionHandler: (success: Bool, errorString: String?) -> Void) {
            let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?order=-updatedAt")!)
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            // added XXX to end to force an error for testing
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

//                if error != nil { // Handle error…
//                    print("An error has occurred when trying to log out")
//                    //TODO: Notify the user whether logout was successful
//                    return
//                }
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                print(NSString(data: newData, encoding: NSUTF8StringEncoding))
                //TODO:-verify that logout was successful
            }
            task.resume()
            model.studentInfoToPost?.uniqueKey = "default"
            model.studentInfoToPost?.firstName  = "D"
            model.studentInfoToPost?.lastName = "Fault"
        }
        
        /*
        // Attempting to generalize all GET data's. Is it worth it?
        func taskForGETData(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ParseAppID] = Constants.ParseAppID
        mutableParameters[ParameterKeys.ParseApiKey] = Constants.ParseApiKey
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method // + UdacityClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
        
        /* 5/6. Parse the data and use the data (happens in completion handler) */
        if let error = downloadError {
        let newError = UdacityClient.errorForData(data, response: response, error: error)
        completionHandler(result: nil, error: downloadError)
        } else {
        UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
        }
        */
        /*
        func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ParseApiKey] = Constants.ParseApiKey
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method + UdacityClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
        
        /* 5/6. Parse the data and use the data (happens in completion handler) */
        if let error = downloadError {
        let newError = UdacityClient.errorForData(data, response: response, error: error)
        completionHandler(result: nil, error: downloadError)
        } else {
        UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
        }
        
        */
        // MARK: - POST
        
        // Pass in the whole StudentInfo, rather than each parameter separate -- replaces the above
        func postOnTheMap (userInfo: StudentInfo, completionHandler: (success: Bool, errorString: String, error: NSError?) -> Void) {
            //TODO:- add completion handler to pass errorString
            let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
            request.HTTPMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // ?Make an array of strings, and then iterate to add to the string? Checking for nil as we go?
            // <String> += <String>
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
                //TODO:- Check for created at, and not error in data
                UdacityClient.parseJSONWithCompletionHandler(data!) {results, error in
                    if error != nil {
                        completionHandler(success: false, errorString: "parsing error", error: error)
                    } else {
                        var messageString = ""
                        print(results)
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
            /* Examples of data
            Optional({"createdAt":"2015-10-19T03:18:31.647Z","objectId":"ZZkOnFowB5"} // successful POST
            Optional({"error":"method not allowed"} // (when mispelled POST)
            Error when wifi is off:
            Error Domain=NSURLErrorDomain Code=-1009 "The Internet connection appears to be offline." UserInfo=0x7fb69949f0c0 {NSUnderlyingError=0x7fb6a06c9110 "The operation couldn’t be completed. (kCFErrorDomainCFNetwork error -1009.)", NSErrorFailingURLStringKey=https://api.parse.com/1/classes/StudentLocation, NSErrorFailingURLKey=https://api.parse.com/1/classes/StudentLocation, _kCFStreamErrorDomainKey=12, _kCFStreamErrorCodeKey=8, NSLocalizedDescription=The Internet connection appears to be offline.}
            */
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

/* Unused, older code. Delete at some point
func login(userName: String, pw: String, completionHandlerLogin: (success: Bool, errorString: String?) -> Void) {
/*
// Udacity login
let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
request.HTTPMethod = "POST"
request.addValue("application/json", forHTTPHeaderField: "Accept")
request.addValue("application/json", forHTTPHeaderField: "Content-Type")
/* // hardcoded username and pw
request.HTTPBody = "{\"udacity\": {\"username\": \"studio@davidiad.com\", \"password\": \"kimba9\"}}".dataUsingEncoding(NSUTF8StringEncoding)
*/
let HTTPBodyString = "{\"udacity\": {\"username\": \"" + userName + "\", \"password\": \"" + pw + "\"}}"
request.HTTPBody = HTTPBodyString.dataUsingEncoding(NSUTF8StringEncoding)
let session = NSURLSession.sharedSession()
let task = session.dataTaskWithRequest(request) { data, response, error in
if error != nil { // Handle error…
return
}
let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
println("First request from Udacity login")
println(NSString(data: newData, encoding: NSUTF8StringEncoding))
println("**********************")
}
task.resume()
*/
taskPOSTUdacityLogin(userName, pw: pw) {success, key, error in
if success {
var URLString = "https://www.udacity.com/api/users/"
if let key = self.model.studentInfoToPost?.uniqueKey {
URLString += key
//BEGIN//----------request step 2----- Udacity--public user info
let request = NSMutableURLRequest(URL: NSURL(string: URLString)!)
//let session = NSURLSession.sharedSession()
let task = self.session.dataTaskWithRequest(request) { data, response, error in
if error != nil { // Handle error...
print("Error???: \(error)")
completionHandlerLogin(success: false, errorString: "\(error)")
return
}
let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
//println("2nd Request from Udacity")
//println(NSString(data: newData, encoding: NSUTF8StringEncoding))
//println("@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
self.model.storeUserInfo(newData)
if let myName = self.model.studentInfoToPost?.firstName {
print("firstName: \(myName)")
} else {
print("Problem reading User Info")
}
completionHandlerLogin(success: true, errorString: "Login was successful!")

}
task.resume()
//END//----------request step 2----- Udacity--public user info
} else {
print("Problem with key?: ukey retrieved: \(self.model.studentInfoToPost?.uniqueKey)")
print("URLstring: \(URLString)")
print("Error: \(error)")
}
} else {
completionHandlerLogin(success: false, errorString: "Account not found or invalid credentials.")
}
/*  let request2 = NSMutableURLRequest(URL: NSURL(string: URLString)!)
//let session = NSURLSession.sharedSession()
let task2 = session.dataTaskWithRequest(request2) { data, response, error in
if error != nil { // Handle error...
return
}
let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
//println("2nd Request from Udacity")
//println(NSString(data: newData, encoding: NSUTF8StringEncoding))
//println("@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
self.model.readUserInfo(newData)
}
task2.resume()
*/

//            self.taskGETParseStudentInfo()
}
/*
// Use Parse API to get student data
let request3 = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
request3.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
request3.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
//let session = NSURLSession.sharedSession()
let task3 = session.dataTaskWithRequest(request3) { data, response, error in
if error != nil { // Handle error...
return
}
// Store the student data into the model
self.model.convertJSON(data)
}
task3.resume()
*/
}

func taskPOSTUdacityLogin (userName: String, pw: String, completionHandler: (success: Bool, key: String?, errorString: String?) -> Void) {
let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
request.HTTPMethod = "POST"
request.addValue("application/json", forHTTPHeaderField: "Accept")
request.addValue("application/json", forHTTPHeaderField: "Content-Type")
let HTTPBodyString = "{\"udacity\": {\"username\": \"" + userName + "\", \"password\": \"" + pw + "\"}}"

request.HTTPBody = HTTPBodyString.dataUsingEncoding(NSUTF8StringEncoding)

let session = NSURLSession.sharedSession()
//let requestImmutable = request as NSURLRequest
let task = session.dataTaskWithRequest(request) { data, response, error in
//            if error != nil { // Handle error…
//                completionHandler(success: false, key: nil, errorString: "The Internet connection appears to be offline.")
//                return
//            }
let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
print(NSString(data: newData, encoding: NSUTF8StringEncoding))
print("**********************")
//var parsingError: NSError? = nil
if let results = try! (NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as? NSDictionary) {
if let accountDictionary = results.valueForKey("account") as? NSDictionary {
if let key = accountDictionary.valueForKey("key") as? String {
self.model.studentInfoToPost?.uniqueKey = key
completionHandler(success: true, key: key, errorString: "Found the account")

// Step 2 - Using the uniqueKey, get the public user data (firstName, lastName)
var URLString = "https://www.udacity.com/api/users/"
//if let key = self.model.studentInfoToPost?.uniqueKey {
URLString += key
//BEGIN//----------request step 2----- Udacity--public user info
let request2 = NSMutableURLRequest(URL: NSURL(string: URLString)!)
//let session = NSURLSession.sharedSession()
let task2 = self.session.dataTaskWithRequest(request2) { data2, response, error in
if error != nil { // Handle error...
print("Error???: \(error)")
//completionHandlerLogin(success: false, errorString: "\(error)")
return
}
let newData2 = data2!.subdataWithRange(NSMakeRange(5, data2!.length - 5)) /* subset response data! */
//println("2nd Request from Udacity")
//println(NSString(data: newData, encoding: NSUTF8StringEncoding))
//println("@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
self.model.storeUserInfo(newData2)
if let myName = self.model.studentInfoToPost?.firstName {
print("firstName: \(myName)")
} else {
print("Problem reading User Info")
}
//completionHandlerLogin(success: true, errorString: "Login was successful!")

}
task2.resume()
//END//----------request step 2----- Udacity--public user info

//} else {
//completionHandler(success: false, key: nil, errorString: "Parsing error?")
}
} else {
// Parse the JSON further to determine cause of login error
if let status: AnyObject = results.valueForKey("status") {
if status as! NSObject == 403 {
if let error403: AnyObject = results.valueForKey("error") {
completionHandler(success: false, key: nil, errorString: error403 as? String)
}
} else if status as! NSObject == 400 {
if let error400: NSString = results.valueForKey("error") as? NSString {
let trimmedString: String = error400.substringFromIndex(max(error400.length - 28, 0))
completionHandler(success: false, key: nil, errorString: trimmedString)
}
}
} else {
completionHandler(success: false, key: nil, errorString: "Unknown problem with account")
}
}
} else {
completionHandler(success: false, key: nil, errorString: "Parsing error?")
}
}
task.resume()
self.getParseStudentInfo() {parseSuccess, parseError in
if parseSuccess {
NSNotificationCenter.defaultCenter().postNotificationName(refreshNotificationKey, object: self)
} else {
completionHandler(success: false, key: nil, errorString: "Download Failed")
}
}

}

*/