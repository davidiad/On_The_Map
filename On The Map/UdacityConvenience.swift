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


    // MARK: - Authentication (GET) Methods
    /*
    Steps for Authentication...
    https://www.themoviedb.org/documentation/api/sessions
    
    Step 1: Create a new request token
    Step 2a: Ask the user for permission via the website
    Step 3: Create a session ID
    Bonus Step: Go ahead and get the user id 😎!
    */
    
    /*
    func authenticateWithViewController(hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        /* Chain completion handlers for each request so that they run one after the other */
        self.getRequestToken() { (success, requestToken, errorString) in
            
            if success {
                
                self.loginWithToken(requestToken, hostViewController: hostViewController) { (success, errorString) in
                    
                    if success {
                        
                        self.getSessionID(requestToken) { (success, sessionID, errorString) in
                            
                            if success {
                                
                                /* Success! We have the sessionID! */
                                self.sessionID = sessionID
                                
                                self.getUserID() { (success, userID, errorString) in
                                    
                                    if success {
                                        
                                        if let userID = userID {
                                            
                                            /* And the userID 😄! */
                                            self.userID = userID
                                        }
                                    }
                                    
                                    completionHandler(success: success, errorString: errorString)
                                }
                            } else {
                                completionHandler(success: success, errorString: errorString)
                            }
                        }
                    } else {
                        completionHandler(success: success, errorString: errorString)
                    }
                }
            } else {
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
*/
    /*
    func getRequestToken(completionHandler: (success: Bool, requestToken: String?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [String: AnyObject]()
        
        /* 2. Make the request */
        taskForGETMethod(Methods.AuthenticationTokenNew, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, requestToken: nil, errorString: "Login Failed (Request Token).")
            } else {
                if let requestToken = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.RequestToken) as? String {
                    completionHandler(success: true, requestToken: requestToken, errorString: nil)
                } else {
                    completionHandler(success: false, requestToken: nil, errorString: "Login Failed (Request Token).")
                }
            }
        }
    }
    */
    /* This function opens a TMDBAuthViewController to handle Step 2a of the auth flow */
    func loginWithToken(requestToken: String?, hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
//        let authorizationURL = NSURL(string: "\(UdacityClient.Constants.AuthorizationURL)\(requestToken!)")
//        let request = NSURLRequest(URL: authorizationURL!)
//        let webAuthViewController = hostViewController.storyboard!.instantiateViewControllerWithIdentifier("TMDBAuthViewController") as! TMDBAuthViewController
//        webAuthViewController.urlRequest = request
//        webAuthViewController.requestToken = requestToken
//        webAuthViewController.completionHandler = completionHandler
//        
//        let webAuthNavigationController = UINavigationController()
//        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
//        
//        dispatch_async(dispatch_get_main_queue(), {
//            hostViewController.presentViewController(webAuthNavigationController, animated: true, completion: nil)
//        })
    }
    /*
    func getSessionID(requestToken: String?, completionHandler: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [UdacityClient.ParameterKeys.RequestToken : requestToken!]
        
        /* 2. Make the request */
        taskForGETMethod(Methods.AuthenticationSessionNew, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
            } else {
                if let sessionID = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.SessionID) as? String {
                    completionHandler(success: true, sessionID: sessionID, errorString: nil)
                } else {
                    completionHandler(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }
    }
    */
    /*
    func getUserID(completionHandler: (success: Bool, userID: Int?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [UdacityClient.ParameterKeys.SessionID : UdacityClient.sharedInstance().sessionID!]
        
        /* 2. Make the request */
        taskForGETMethod(Methods.Account, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, userID: nil, errorString: "Login Failed (User ID).")
            } else {
                if let userID = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.UserID) as? Int {
                    completionHandler(success: true, userID: userID, errorString: nil)
                } else {
                    completionHandler(success: false, userID: nil, errorString: "Login Failed (User ID).")
                }
            }
        }
    }
    */
    // MARK: - GET Convenience Methods
    
//    func getFavoriteMovies(completionHandler: (result: [TMDBMovie]?, error: NSError?) -> Void) {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [UdacityClient.ParameterKeys.SessionID: UdacityClient.sharedInstance().sessionID!]
//        var mutableMethod : String = Methods.AccountIDFavoriteMovies
//        mutableMethod = UdacityClient.subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance().userID!))!
//        
//        /* 2. Make the request */
//        taskForGETMethod(mutableMethod, parameters: parameters) { JSONResult, error in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                completionHandler(result: nil, error: error)
//            } else {
//                
//                if let results = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.MovieResults) as? [[String : AnyObject]] {
//                    
//                    var movies = TMDBMovie.moviesFromResults(results)
//                    
//                    completionHandler(result: movies, error: nil)
//                } else {
//                    completionHandler(result: nil, error: NSError(domain: "getFavoriteMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getFavoriteMovies"]))
//                }
//            }
//        }
//    }
    
//    func getWatchlistMovies(completionHandler: (result: [TMDBMovie]?, error: NSError?) -> Void) {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [UdacityClient.ParameterKeys.SessionID: UdacityClient.sharedInstance().sessionID!]
//        var mutableMethod : String = Methods.AccountIDWatchlistMovies
//        mutableMethod = UdacityClient.subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance().userID!))!
//        
//        /* 2. Make the request */
//        taskForGETMethod(mutableMethod, parameters: parameters) { JSONResult, error in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                completionHandler(result: nil, error: error)
//            } else {
//                
//                if let results = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.MovieResults) as? [[String : AnyObject]] {
//                    
//                    var movies = TMDBMovie.moviesFromResults(results)
//                    
//                    completionHandler(result: movies, error: nil)
//                } else {
//                    completionHandler(result: nil, error: NSError(domain: "getWatchlistMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getWatchlistMovies"]))
//                }
//            }
//        }
//    }
//
//    func getMoviesForSearchString(searchString: String, completionHandler: (result: [TMDBMovie]?, error: NSError?) -> Void) -> NSURLSessionDataTask? {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [UdacityClient.ParameterKeys.Query: searchString]
//        
//        /* 2. Make the request */
//        let task = taskForGETMethod(Methods.SearchMovie, parameters: parameters) { JSONResult, error in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                completionHandler(result: nil, error: error)
//            } else {
//                
//                if let results = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.MovieResults) as? [[String : AnyObject]] {
//                    
//                    var movies = TMDBMovie.moviesFromResults(results)
//                    
//                    completionHandler(result: movies, error: nil)
//                } else {
//                    completionHandler(result: nil, error: NSError(domain: "getMoviesForSearchString parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMoviesForSearchString"]))
//                }
//            }
//        }
//        
//        return task
//    }
    /*
    func getConfig(completionHandler: (didSucceed: Bool, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [String: AnyObject]()
        
        /* 2. Make the request */
        taskForGETMethod(Methods.Config, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(didSucceed: false, error: error)
            } else if let newConfig = UdacityConfig(dictionary: JSONResult as! [String : AnyObject]) {
                self.config = newConfig
                completionHandler(didSucceed: true, error: nil)
            } else {
                completionHandler(didSucceed: false, error: NSError(domain: "getConfig parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getConfig"]))
            }
        }
    }
    */
    // MARK: - POST Convenience Methods
    
//    func postToFavorites(movie: TMDBMovie, favorite: Bool, completionHandler: (result: Int?, error: NSError?) -> Void) {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [UdacityClient.ParameterKeys.SessionID : UdacityClient.sharedInstance().sessionID!]
//        var mutableMethod : String = Methods.AccountIDFavorite
//        mutableMethod = UdacityClient.subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance().userID!))!
//        let jsonBody : [String:AnyObject] = [
//            UdacityClient.JSONBodyKeys.MediaType: "movie",
//            UdacityClient.JSONBodyKeys.MediaID: movie.id as Int,
//            UdacityClient.JSONBodyKeys.Favorite: favorite as Bool
//        ]
//        
//        /* 2. Make the request */
//        let task = taskForPOSTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                completionHandler(result: nil, error: error)
//            } else {
//                if let results = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.StatusCode) as? Int {
//                    completionHandler(result: results, error: nil)
//                } else {
//                    completionHandler(result: nil, error: NSError(domain: "postToFavoritesList parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToFavoritesList"]))
//                }
//            }
//        }
//    }
    
//    func postToWatchlist(movie: TMDBMovie, watchlist: Bool, completionHandler: (result: Int?, error: NSError?) -> Void) {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [UdacityClient.ParameterKeys.SessionID : UdacityClient.sharedInstance().sessionID!]
//        var mutableMethod : String = Methods.AccountIDWatchlist
//        mutableMethod = UdacityClient.subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance().userID!))!
//        let jsonBody : [String:AnyObject] = [
//            UdacityClient.JSONBodyKeys.MediaType: "movie",
//            UdacityClient.JSONBodyKeys.MediaID: movie.id as Int,
//            UdacityClient.JSONBodyKeys.Watchlist: watchlist as Bool
//        ]
//        
//        /* 2. Make the request */
//        let task = taskForPOSTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                completionHandler(result: nil, error: error)
//            } else {
//                if let results = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.StatusCode) as? Int {
//                    completionHandler(result: results, error: nil)
//                } else {
//                    completionHandler(result: nil, error: NSError(domain: "postToWatchlist parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToWatchlist"]))
//                }
//            }
//        }
//    }
}
