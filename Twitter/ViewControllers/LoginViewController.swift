//
//  LoginViewController.swift
//  Twitter
//
//  Created by Ding, Quan on 2/17/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    var twitterClient = TwitterClient.sharedInstance

    @IBAction func twitterLogin(sender: AnyObject) {
        User.loginWithCompletion( {(user: User?, error: NSError?) -> Void in
            if (user != nil){
                self.performSegueWithIdentifier("loginSegue", sender: self)
            } else {
                println(error)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
