//
//  OnTheMapData.swift
//  On The Map
//
//  Created by David Fierstein on 9/12/15.
//  Copyright (c) 2015 David Fierstein. All rights reserved.
//  Reads in raw JSON data as a dictionary and stores it in Swift data structures

import Foundation
//class TheOneAndOnlyKraken {
//    static let sharedInstance = TheOneAndOnlyKraken()
//    private init() {} //This prevents others from using the default '()' initializer for this class.
//}
class OnTheMapData {
    static let sharedInstance = OnTheMapData()
    var studentInfoArray: [StudentInfo]?// = []
    var studentInfoToPost: StudentInfo?
    
    //This prevents others from using the default '()' initializer for this class.
    private init() {
        studentInfoToPost = StudentInfo()
        studentInfoArray = [StudentInfo]()
      //  studentInfoArray : StudentInfo = []
    }
    
    func convertJSON(data: NSData, completionHandler: (success: Bool, error: NSError?) -> Void) {
        //studentInfoArray = [StudentInfo]()
        if studentInfoArray?.count > 0 {
            studentInfoArray?.removeAll(keepCapacity: false)
        }
        // Error object
        let parsingError: NSError? = nil
        
        do {
            let results = try (NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary)
            let arrayOfDictionaries = results!.valueForKey("results") as! [[String:AnyObject]]
            // Put info into student info array
            for dict in arrayOfDictionaries {
                let info = StudentInfo(data: dict)
                studentInfoArray?.append(info)
            }
            completionHandler(success: true, error: parsingError)
            // now, pass on success to completion handler?
        }
        catch {
            print("pppppp")
        }
        
       // studentInfoArray.sort({$0.createdAt &gt; $1.createdAt })
        //studentInfoArray!.sortInPlace({$0.; $1.createdAt })
//        var sortedInfo: [StudentInfo] = studentInfoArray?.sort({ (s1: StudentInfo, s2: StudentInfo) -> Bool in
//            return s1.firstName as NSString > s2.firstName as NSString
//        })
        
        /*
        // seems to work, but can get the sorted array as a return value
        //var sortedInfo: [StudentInfo] =
        studentInfoArray?.sort{ (s1: StudentInfo, s2: StudentInfo) -> Bool in
            let dateOne = s1.timestamp
            let dateTwo = s2.timestamp
            return dateOne?.compare(dateTwo!) == NSComparisonResult.OrderedDescending
        }
        */

//        var sortedByName: [StudentInfo]? = studentInfoArray?.sort( { (s1: StudentInfo, s2: StudentInfo) -> Bool in
//            return s1.firstName as! String > s2.firstName as! String
//        } )
        
        //println("Sorted, first 2: \(sortedInfo[0]) , \(sortedInfo[1])")
        // Sort the array using the "updatedBy" NSDate
        
        // var sortedInfo = studentInfoArray?.sort({$0.timestamp! < $1.timestamp! })
        // events.sort({ $0.date.compare($1.date) == NSComparisonResult.OrderedAscending })
        //meetingsData.sort({ $0.meetingDate.compare($1.meetingDate) == .OrderedAscending })
        //studentInfoArray.sort({ $0.timestamp.compare($1.timestamp) == .OrderedAscending })
        //studentInfoArray = sorted(studentInfoArray) {$0.timestamp > $1.timestamp}
        
      
        //Then you can simply do:
        
        //studentInfoArray?.sort({ $0.lastName < $1.lastName })
        
        
        //studentInfoArray?.sortInPlace({ $0.timestamp!.compare($1.timestamp!) == .OrderedAscending })
        
        
//        studentInfoArray?.sortInPlace({
//            if let ts1: NSDate = $0.timestamp {
//                if let ts2: NSDate = $1.timestamp {
//                    return ts1.compare(ts2) == .OrderedDescending
//                } else {
//                    return false
//                }
//            } else {
//                return false
//            }
//            //$0.timestamp!.compare($1.timestamp!) == .OrderedAscending
//        })
    }
    
    func abc(completion: (s1: StudentInfo?, s2: StudentInfo?) ->  Bool) -> [StudentInfo] {
        let sortedInfo: [StudentInfo] = studentInfoArray!
        return sortedInfo
    }
//
//    func sortByDate (inputArray: [StudentInfo]?, completion: (s1: StudentInfo, s2: StudentInfo) -> Bool) -> [StudentInfo] {
//        inputArray = (s1: StudentInfo, s2: StudentInfo) -> Bool in
//            let dateOne = s1.timestamp
//            let dateTwo = s2.timestamp
//            return dateOne?.compare(dateTwo!) == NSComparisonResult.OrderedDescending
//        }
//        return sortedArray
//    }

        /* example closure
            func taskPOSTUdacityLogin (userName: String, pw: String, completionHandler: (success: Bool, key: String?, errorString: String?) -> Void) {
*/
        
    func storeUserInfo(data: NSData) {
        do {
            let userResults = try (NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary)
            if let userInfo = userResults!.valueForKey("user") as? NSDictionary {
                print("userInfo: \(userInfo)")
                if let firstName = userInfo.valueForKey("first_name") as? String {
                    studentInfoToPost?.firstName = firstName
                }
                if let lastName = userInfo.valueForKey("last_name") as? String {
                    studentInfoToPost?.lastName = lastName
                    print(lastName)
                }
                if let uniqueKey = userInfo.valueForKey("key") as? String {
                    studentInfoToPost?.uniqueKey = uniqueKey
                }
            }
        } catch {
//            // Parse the JSON further to determine cause of login error
//            if let status: AnyObject = userResults.valueForKey("status") {
//                if status as! NSObject == 403 {
//                    if let error403: AnyObject = results.valueForKey("error") {
//                        completionHandler(success: false, key: nil, errorString: error403 as? String)
//                    }
//                } else if status as! NSObject == 400 {
//                    if let error400: NSString = results.valueForKey("error") as? NSString {
//                        let trimmedString: String = error400.substringFromIndex(max(error400.length - 28, 0))
//                        completionHandler(success: false, key: nil, errorString: trimmedString)
//                    }
//                }
//            } else {
//                completionHandler(success: false, key: nil, errorString: "Unknown problem with account")
//            }

        }
    }

//    func createInfoArray (dict: [String:String]) {
//
//    }
    
//
//    init(data: String)
    
    // Example init
//    init(sender: String, recipient: String)
//    {
//        self.sender = sender
//        self.recipient = recipient
//        
//        timeStamp = NSDate()
//    }
    
}


