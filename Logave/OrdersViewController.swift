//
//  OrdersViewController.swift
//  Logave
//
//  Created by Andrew Johnsson on 15.09.15.
//  Copyright © 2015 Alex. All rights reserved.
//

import UIKit

class OrdersViewController:UITableViewController{
    let orders = ["Apples","Trash Bins","Windows","Penguins"]
    let distantions = ["150m","350m","1km","800m"]
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let order = tableView.dequeueReusableCellWithIdentifier("orderCell") as UITableViewCell!
        
        order.textLabel?.text = orders[indexPath.row]
        order.detailTextLabel?.text = distantions[indexPath.row]
        
        return order
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: (NSIndexPath!)) {
        self.performSegueWithIdentifier("showOrderDetails", sender: self)
    }
}
