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
        
        if let results = (NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary) {
//            if error != nil {
//                return
//            }
            let arrayOfDictionaries = results.valueForKey("results") as! [[String:AnyObject]]
            // Put info into student info array
            for dict in arrayOfDictionaries {
                let info = StudentInfo(data: dict)
                studentInfoArray?.append(info)
            }
            completionHandler(success: true, error: parsingError)
            // now, pass on success to completion handler?
        }
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
        //studentInfoArray?.sort({ $0.timestamp!.compare($1.timestamp!) == .OrderedAscending })
//        studentInfoArray?.sort({
//            if let ts1: NSDate = $0.timestamp {
//                if let ts2: NSDate = $1.timestamp {
//                    return ts1.compare(ts2) == .OrderedAscending
//                } else {
//                    return false
//                }
//            } else {
//                return false
//            }
//            return false
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
        
    func readUserInfo(data: NSData) {
        // Error object
        var parsingError: NSError? = nil
        
        // Repeating the JSON parsing code
        //TODO: DRY out JSON parsing code
        if let userResults = (NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary) {
            if let userInfo = userResults.valueForKey("user") as? NSDictionary { //[String:AnyObject]
                print("userInfo: \(userInfo)")
                if let firstName = userInfo.valueForKey("first_name") as? String {
                    studentInfoToPost?.firstName = firstName
                    print("first: \(studentInfoToPost?.firstName)")
                } else {
                    print("where's the first name?")
                    //TODO: handle error properly
                }
                if let lastName = userInfo.valueForKey("last_name") as? String {
                    studentInfoToPost?.lastName = lastName
                    print("last: \(studentInfoToPost?.lastName)")
                    print(lastName)
                }
                // already have key, in order to get the rest of the info for the student logged in
                if let uniqueKey = userInfo.valueForKey("key") as? String {
                    studentInfoToPost?.uniqueKey = uniqueKey
                }
            } else {
                print("Could not parse userInfo")
            }
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


