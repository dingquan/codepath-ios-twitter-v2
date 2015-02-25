//
//  NewTweetViewController.swift
//  Twitter
//
//  Created by Ding, Quan on 2/18/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import UIKit

private let placeHolderText = "What's happening?"

class NewTweetViewController: UIViewController, UITextViewDelegate {

    var inReplyToTweet: Tweet?
    var tweetCountBarItem: UIBarButtonItem!
    
    @IBOutlet weak var navItems: UINavigationItem!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var tweetBody: UITextView!
    
    @IBAction func onTweet(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if tweetBody.text != "" {
            User.currentUser?.postTweetWithCompletion(inReplyToTweet, tweetText: tweetBody.text, completion: { (tweet, error) -> () in
                NSNotificationCenter.defaultCenter().postNotificationName(newTweetCreatedNotification, object: tweet)
            })
        }
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tweetCountBarItem = UIBarButtonItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tweetBody.delegate = self
        if inReplyToTweet == nil {
            tweetBody.text = placeHolderText
        } else {
            tweetBody.text = "@\(inReplyToTweet!.user!.screenName!) "
            tweetBody.selectedRange = NSRange(location: count(tweetBody!.text!.utf16), length: 0)
        }
        tweetBody.textColor = UIColor.grayColor()
        
        if User.currentUser != nil {
            name.text = User.currentUser!.name
            screenName.text = User.currentUser!.screenName
            ImageHelpers.roundedCorner(profileImage)
            ImageHelpers.fadeInImage(profileImage, imgUrl: User.currentUser!.profileImageUrl)
        }
        
        tweetCountBarItem.title = "140"
        tweetCountBarItem.tintColor = UIColor.grayColor()
        self.navItems.rightBarButtonItems?.append(tweetCountBarItem)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        tweetBody.textColor = UIColor.blackColor()
        
        if(self.tweetBody.text == placeHolderText) {
            self.tweetBody.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if(textView.text == "") {
            tweetBody.text = placeHolderText
            tweetBody.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        let remaining = 140 - count(tweetBody.text.utf16)
        UIView.setAnimationsEnabled(false)
        if remaining < 20 {
            tweetCountBarItem.tintColor = UIColor.redColor()
        }
        else {
            tweetCountBarItem.tintColor = UIColor.grayColor()
        }
        tweetCountBarItem.title = String(remaining)
        UIView.setAnimationsEnabled(true)
    }

    // closes soft keyboard when user taps outside of text view
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
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
