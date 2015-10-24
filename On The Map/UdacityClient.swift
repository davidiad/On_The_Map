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

class UdacityClient : NSObject {
    
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
    
    // MARK: - GET
    
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
                            println("Error???: \(error)")
                            completionHandlerLogin(success: false, errorString: "\(error)")
                            return
                        }
                        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                        //println("2nd Request from Udacity")
                        //println(NSString(data: newData, encoding: NSUTF8StringEncoding))
                        //println("@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
                        self.model.readUserInfo(newData)
                        if let myName = self.model.studentInfoToPost?.firstName {
                            println("firstName: \(myName)")
                        } else {
                            println("Problem reading User Info")
                        }
                        completionHandlerLogin(success: true, errorString: "Login was successful!")
                        
                    }
                    task.resume()
                    //END//----------request step 2----- Udacity--public user info
                } else {
                    println("Problem with key?: ukey retrieved: \(self.model.studentInfoToPost?.uniqueKey)")
                    println("URLstring: \(URLString)")
                    println("Error: \(error)")
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
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(success: false, key: nil, errorString: "The Internet connection appears to be offline.")
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            println("**********************")
            var parsingError: NSError? = nil
            if let results = (NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments, error: &parsingError) as? NSDictionary) {
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
                                    println("Error???: \(error)")
                                    //completionHandlerLogin(success: false, errorString: "\(error)")
                                    return
                                }
                                let newData2 = data2.subdataWithRange(NSMakeRange(5, data2.length - 5)) /* subset response data! */
                                //println("2nd Request from Udacity")
                                //println(NSString(data: newData, encoding: NSUTF8StringEncoding))
                                //println("@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
                                self.model.readUserInfo(newData2)
                                if let myName = self.model.studentInfoToPost?.firstName {
                                    println("firstName: \(myName)")
                                } else {
                                    println("Problem reading User Info")
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
        self.taskGETParseStudentInfo() {parseSuccess, parseError in
            if parseSuccess {
                NSNotificationCenter.defaultCenter().postNotificationName(myNotificationKey, object: self)
            } else {
                completionHandler(success: false, key: nil, errorString: "Download Failed")
            }
        }

    }
    
    /* JSON response examples
    Optional({"account": {"registered": true, "key": "u41464181"}, "session": {"id": "1476243674S27b30af924994d7bb5296b689449bd93", "expiration": "2015-12-12T03:41:14.728500Z"}})
    Optional({"status": 400, "parameter": "udacity.username", "error": "trails.Error 400: Missing parameter 'username'"})
    Optional({"status": 400, "parameter": "udacity.password", "error": "trails.Error 400: Missing parameter 'password'"})
    Optional({"status": 403, "error": "Account not found or invalid credentials."})
    */
    
    
    // Helper func to extract the key from the JSON
    func extractKey(data: NSData) {
        //var key: String?
        var parsingError: NSError? = nil
        if let results = (NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &parsingError) as? NSDictionary) {
            if let accountDictionary = results.valueForKey("account") as? NSDictionary {
                println("acct dict: \(accountDictionary)")
                if let key = accountDictionary.valueForKey("key") as? String {
                    println("key Extract: \(key)")
                    //key = keyString
                    self.model.studentInfoToPost?.uniqueKey = key
                    println("Key has been extracted and stored: \(self.model.studentInfoToPost?.uniqueKey)")
                } else {
                    println("parsing error with key")
                }
            } else {
                println("parsing error with account")
            }
            //let keyString = ...
            // put the key into the userInfo in the Model
            //else login error -- invalid user id?
        }
        //return key! // TODO: Need to handle errors where we don't get a key
    }
    
    
    func taskGETUdacityUserInfo (key: String) {
        
    }
    
    /*
    // Use Parse API to get student data
    func taskGETParseStudentInfo() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        //let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            // Store the student data into the model
            self.model.convertJSON(data) {success, error in
                if success {
                    //completionHandler(success: success, error: error)
                }
        }
        task.resume()
    }
    */
    
    // Use Parse API to get student data, with completion handler
    func taskGETParseStudentInfo(completionHandler: (parseSuccess: Bool, parseError: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        //let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                //println("Parse Download error: \(error)")
                completionHandler(parseSuccess: false, parseError: error)
                return
            }
            // Store the student data into the model
            self.model.convertJSON(data) {success, error in
                if success {
                    completionHandler(parseSuccess: success, parseError: error)
                }
            }
            // if above has success, then pass success on
        }
        task.resume()
    }
    
    func udacityLogout () {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                println("An error has occurred when trying to log out")
                //TODO: Notify the user whether logout was successful
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            //TODO:-verify that logout was successful
        }
        task.resume()
        model.studentInfoToPost?.uniqueKey = "default"
        model.studentInfoToPost?.firstName  = "D"
        model.studentInfoToPost?.lastName = "Fault"
        //TODO: delete the user info, so it really is logged out
    }
    /*
    func taskGETParseData () -> NSURLSessionDataTask {
        /* 1. Set the parameters */
        // Not needed: parameters are hard coded into HTTPHeaderField's, and don't change
        
        /* 2/3. Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + Methods.ParseStudentLocation
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
//        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
//        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue(Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
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
    
    func taskForGETImage(size: String, filePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
        /* 1. Set the parameters */
        // There are none...
        
        /* 2/3. Build the URL and configure the request */
        let urlComponents = [size, filePath]
        let baseURL = NSURL(string: config.baseImageURLString)!
        let url = baseURL.URLByAppendingPathComponent(size).URLByAppendingPathComponent(filePath)
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let error = downloadError {
                let newError = UdacityClient.errorForData(data, response: response, error: downloadError)
                completionHandler(imageData: nil, error: newError)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    */
    // MARK: - POST 
    /*
    func postOnTheMap (locationText: String, lat: Double, lon: Double) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Got this error: "Expression was too complex to be solved in reasonable time; consider breaking up the expression into distinct sub-expressions."
        // Therefore, breaking up the string, although it seems it ought to be a temporary shortcoming in Swift 1.2
        /*
        let HTTPBodyString = "{\"uniqueKey\": \"1234\", \"firstName\": \"Kelly\", \"lastName\": \"Marie\",\"mapString\": \"" + locationText + "\", \"mediaURL\": \"http://www.craigslist.com\",\"latitude\":  \"" + String(lat) + "\", \"longitude\":  \"" + lon + "\"}"
        */
        

        let HTTPBodyString_A = "{\"uniqueKey\": \"1234\", \"firstName\": \"KM\", \"lastName\": \"P\",\"mapString\": \"" + locationText + "\", \"mediaURL\": \"http://www.scienceanimated.com\",\"latitude\": "
        let HTTPBodyString_B = "\(lat)"
        let HTTPBodyString_C = ", \"longitude\": \(lon)}"
        let HTTPBodyString = HTTPBodyString_A + HTTPBodyString_B + HTTPBodyString_C
        println("HTTPBodyString: \(HTTPBodyString)")
        request.HTTPBody = HTTPBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                    println("Error in POSTing")
                return
            }
            println(locationText)
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            println("Response: \(response)")
        }
        task.resume()
    }
    */
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
                //println("Error in POSTing: The Internet connection appears to be offline")
                //println(error)
                return
            }
            //TODO:- Check for created at, and not error in data
            UdacityClient.parseJSONWithCompletionHandler(data) {results, error in
//                println("KKKKK")
//                println(NSString(data: data, encoding: NSUTF8StringEncoding))
//                println("Response: \(response)")
                if error != nil {
                    completionHandler(success: false, errorString: "parsing error", error: error)
                } else {
                    var messageString = ""
                    println(results)
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
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
        
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
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[UdacityClient.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Udacity Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
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
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}