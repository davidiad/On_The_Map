//
//  ListViewController.swift
//  On The Map
//
//  Created by David Fierstein on 9/29/15.
//  Copyright (c) 2015 David Fierstein. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    /* shared data model */
    var model = OnTheMapData.sharedInstance
    
// MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: refreshNotificationKey, object: nil)
        
//        navigationItem.leftBarButtonItem = editButtonItem()
//        var rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Pin", style: UIBarButtonItemStyle.Plain, target: self, action: "pinTapped")
//        var rightRefreshButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshTapped")
//        self.navigationItem.setRightBarButtonItems([rightRefreshButtonItem,rightAddBarButtonItem], animated: true)
    }
    
//    override func viewDidAppear(animated: Bool) {
//        println("VIEW DID APPEAR")
//        reload()
//    }
    
//    override func viewWillAppear(animated: Bool) {
//        println("view WILL appear")
//        NSNotificationCenter.defaultCenter().postNotificationName(refreshNotificationKey, object: self)
//        tableView.reloadData()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Bar Button actions
    
//    override func refreshTapped() {
//        println("refresh tapped")
//        //TODO:- update the data in the model
//        // reload the table data
//        tableView.reloadData()
//    }
//    
//    override func pinTapped() {
//        println("pin tapped")
//        openPinEditor()
//    }
//    
//    override func openPinEditor() {
//        var storyboard = UIStoryboard (name: "Main", bundle: nil)
//        var pinEditor = storyboard.instantiateViewControllerWithIdentifier("PinEditor") as! PinEditor
//        presentViewController(pinEditor, animated: true, completion: nil)
//    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if let dataCount = OnTheMapData.sharedInstance.studentInfoArray?.count {
            return dataCount
        } else {
            return 7
        }
    }
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 

        // Configure the cell...
        if let _studentInfo = OnTheMapData.sharedInstance.studentInfoArray?[indexPath.row] {
            var name = " "
            if let lastName = _studentInfo.lastName {
                name = name + lastName
            }
            if let firstName = _studentInfo.firstName {
                name = firstName + name
            }
            let location = _studentInfo.location
            cell.detailTextLabel?.text = location
            cell.textLabel?.text = name
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let _studentInfo = OnTheMapData.sharedInstance.studentInfoArray?[indexPath.row] {
            if let url = _studentInfo.link{
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    // helper function for Refresh button
    func reload() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // set bg color here
        // get a sequence of pastel colors
        let hueValue = model.backgroundHue(indexPath.row)
        let color = UIColor(hue: hueValue, saturation: 0.35, brightness: 0.9, alpha: 1)
        cell.backgroundColor = color
//        let gradient = CAGradientLayer().gradientColor(hueValue)
//        gradient.frame = cell.bounds
//        cell.backgroundView = UIView()
//        cell.backgroundView!.layer.insertSublayer(gradient, atIndex: 0)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
