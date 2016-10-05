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
            print("Connected to the Server")
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loginTextField.text = "ali@desktop-j9lkhke"
        passwordTextField.text = "ali"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

