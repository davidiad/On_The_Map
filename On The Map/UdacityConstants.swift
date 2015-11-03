//
//  UdacityConstants.swift
//  On The Map
//
//  Created by David Fierstein on 9/3/15.
//  Copyright (c) 2015 David Fierstein. All rights reserved.
//

//  Based on:
//  TMDBConstants.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright (c) 2015 Jarrod Parkes. All rights reserved.
//

extension UdacityClient {
    
    // MARK: - Constants
    struct Constants {
        
        // MARK: Notifications
        static let refreshNotificationKey = "refresh_notification_key"
        
        // MARK: API Key
        static let ParseApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        // MARK: URLs
        //static let BaseURL : String = "http://api.themoviedb.org/3/"
        static let BaseURLSecure : String = "https://api.parse.com/1/"
    }
    
    // MARK: - Methods
    struct Methods {
        
        // MARK: Account
        // Parse
        static let ParseStudentLocation = "classes/StudentLocation"
        
        // MARK: Authentication
        static let AuthenticationTokenNew = "authentication/token/new"
        static let AuthenticationSessionNew = "authentication/session/new"
        
        // MARK: Config
        static let Config = "configuration"
        
    }
    
    // MARK: - URL Keys
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    // MARK: - Parameter Keys
    struct ParameterKeys {
        
        static let ParseApiKey = "parse_api_key"
        static let ParseAppID = "parse_app_id"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
        
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        static let Username = "username"
        static let Password = "password"
        static let Udacity = "udacity"
        static let Facebook = "facebook_mobile" //Facebook
        static let AccessToken = "access_token" //Facebook
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
        // MARK: Config
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        
    }

}