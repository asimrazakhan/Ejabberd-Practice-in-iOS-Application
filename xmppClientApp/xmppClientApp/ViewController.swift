//
//  ViewController.swift
//  xmppClientApp
//
//  Created by Higher Visibility on 9/10/16.
//  Copyright © 2016 Buzy Beez. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var loginTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBAction func login(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(loginTextField.text!, forKey: "userID")
        NSUserDefaults.standardUserDefaults().setObject(passwordTextField.text!, forKey: "userPassword")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if appDelegate.connect() {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loginTextField.text = "asim@desktop-j9lkhke"
        passwordTextField.text = "visibility"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

