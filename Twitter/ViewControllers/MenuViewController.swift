//
//  MenuViewController.swift
//  TwitterV2
//
//  Created by Ding, Quan on 2/25/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var menuTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // only show cells with data (remove empty cells so that it doesn't show the separator for empty cells
        self.menuTable.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuTableViewCell
        
        if indexPath.row == 0 {
            cell.icon.image = UIImage(named: "profile")
            cell.menuLabel.text = "My Profile"
        } else if indexPath.row == 1 {
            cell.icon.image = UIImage(named: "home")
            cell.menuLabel.text = "Home Timeline"
        } else if indexPath.row == 2 {
            cell.icon.image = UIImage(named: "at")
            cell.menuLabel.text = "Mentions Timeline"
        }
        cell.menuLabel.sizeToFit()
        
        return cell
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
