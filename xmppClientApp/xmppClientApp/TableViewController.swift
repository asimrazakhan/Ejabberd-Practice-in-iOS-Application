//
//  TableViewController.swift
//  xmppClientApp
//
//  Created by Higher Visibility on 9/17/16.
//  Copyright © 2016 Buzy Beez. All rights reserved.
//

import UIKit
import XMPPFramework

class TableViewController: UITableViewController, ChatDelegate {

    var onlineBuddies = NSMutableArray()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        appDelegate.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        if (NSUserDefaults.standardUserDefaults().objectForKey("userID") != nil) {
            if appDelegate.connect() {
                self.title = appDelegate.xmppStream.myJID.bare()
                appDelegate.xmppRoster.fetchRoster()
            }
        } else {
            performSegueWithIdentifier("Home.To.Login", sender: self)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return onlineBuddies.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = onlineBuddies[indexPath.row] as? String

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let alertController = UIAlertController(title: "Warning!", message: "It will send Yo! to the recipient, continue ?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let message = "Yo!"
            let senderJID = XMPPJID.jidWithString(self.onlineBuddies[indexPath.row] as? String)
            let msg = XMPPMessage(type: "chat", to: senderJID)
            
            msg.addBody(message)
            self.appDelegate.xmppStream.sendElement(msg)
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Chat delegates
    func buddyWentOnline(name: String) {
        if !onlineBuddies.containsObject(name) {
            onlineBuddies.addObject(name)
            tableView.reloadData()
        }
    }
    
    func buddyWentOffline(name: String) {
        onlineBuddies.removeObject(name)
        tableView.reloadData()
    }
    
    func didDisconnect() {
        onlineBuddies.removeAllObjects()
        tableView.reloadData()
    }

}
