//
//  MenuController.swift
//  Logave
//
//  Created by Alex on 16.09.15.
//  Copyright © 2015 Logave. All rights reserved.
//

import Foundation
import UIKit

class MenuController:UIViewController {
    
    @IBAction func tapOnSignIn(sender: AnyObject) {
        let coreDataTest = CoreDataController()
        let user = coreDataTest.getUser()
        
        /*if user?.name != ""{
            performSegueWithIdentifier("showMenu", sender: self)
        } else {
            performSegueWithIdentifier("showAuth", sender: self)
        }*/
    }
}