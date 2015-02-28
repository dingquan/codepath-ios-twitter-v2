//
//  MenuViewController.swift
//  TwitterV2
//
//  Created by Ding, Quan on 2/25/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate {
    func didSelectProfile()
    func didSelectHomeTimeline()
    func didSelectMentions()
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate: MenuViewControllerDelegate?
    
    @IBOutlet weak var menuTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // only show cells with data (remove empty cells so that it doesn't show the separator for empty cells
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.menuTable.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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
        } else if indexPath.row == 3 {
            cell.menuLabel.text = "Logout"
        }
        cell.menuLabel.sizeToFit()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        if indexPath.row == 0 {
            delegate?.didSelectProfile()
        } else if indexPath.row == 1 {
            delegate?.didSelectHomeTimeline()
        } else if indexPath.row == 2 {
            delegate?.didSelectMentions()
        } else if indexPath.row == 3 {
            User.currentUser?.logout()
        }
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
