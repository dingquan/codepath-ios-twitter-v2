//
//  ProfileViewController.swift
//  TwitterV2
//
//  Created by Ding, Quan on 2/26/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetTableViewCellDelegate {

    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var profileTableHeader: UIView!
    @IBOutlet weak var profileBackgroundImage: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileScreenName: UILabel!
    @IBOutlet weak var profileDescription: UILabel!
    @IBOutlet weak var profileFollowingCnt: UILabel!
    @IBOutlet weak var profileFollowersCnt: UILabel!
    
    var user: User!
    var tweets: [Tweet]!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tweets = [Tweet]()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        setNavigationBarTransparent()
        
        self.profileTableView.estimatedRowHeight = 260
        self.profileTableView.rowHeight = UITableViewAutomaticDimension
        
        showProfileHeaderView()
        fetchMoreTimeline()
    }

    override func viewWillDisappear(animated: Bool) {
        restoreNavigationBarColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setNavigationBarTransparent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true;
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    }
    
    private func restoreNavigationBarColor() {
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var tweet = tweets![indexPath.row]
        var cell:UITableViewCell
        if tweet.imageUrl == nil {
            cell = tableView.dequeueReusableCellWithIdentifier("textCell", forIndexPath: indexPath) as! TextTableViewCell
            (cell as! TextTableViewCell).delegate = self
            (cell as! TextTableViewCell).tweet = tweet
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! ImageTableViewCell
            (cell as! ImageTableViewCell).delegate = self
            (cell as! ImageTableViewCell).tweet = tweet
        }
        
        // change the default margin of the table divider length
        if (cell.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:"))){
            cell.preservesSuperviewLayoutMargins = false
        }
        
        if (cell.respondsToSelector(Selector("setSeparatorInset:"))){
            cell.separatorInset = UIEdgeInsetsMake(0, 4, 0, 0)
        }
        
        if (cell.respondsToSelector(Selector("setLayoutMargins:"))){
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let tweet = self.tweets[indexPath.row]
        self.performSegueWithIdentifier("showDetailsFromProfile", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailsFromProfile" {
            var indexPath:NSIndexPath = sender as! NSIndexPath
            let tweet = self.tweets[indexPath.row]
            let tweetDetailVC = segue.destinationViewController as! TweetDetailViewController
            tweetDetailVC.tweet = tweet
            tweetDetailVC.forIndexPath = indexPath
        } else if segue.identifier == "replyTweetFromTimeline" {
            let newTweetVC = segue.destinationViewController as! NewTweetViewController
            newTweetVC.inReplyToTweet = sender as? Tweet
        }
    }
    
    private func fetchMoreTimeline() -> Void {
        User.userTimelineWithCompletion(user.id!, completion: { (tweets, error) -> Void in
            if tweets != nil {
                self.tweets! += tweets!
                self.profileTableView.reloadData()
            } else {
                println(error)
            }
        })
    }
    
    func showProfileHeaderView() -> Void {
        if let user = user {
            ImageHelpers
                .roundedCornerWithBoarder(self.profileImageView)
            ImageHelpers.fadeInImage(self.profileImageView, imgUrl: user.profileImageUrl)
            if let bannerImageUrl = user.bannerImageUrl {
                ImageHelpers.fadeInImage(self.profileBackgroundImage, imgUrl: bannerImageUrl)
            }
            
            self.profileName.text = user.name!
            self.profileScreenName.text = "@\(user.screenName!)"
            self.profileDescription.text = user.description
            self.profileDescription.preferredMaxLayoutWidth = self.profileDescription.frame.size.width
            self.profileDescription.sizeToFit()
            self.profileFollowersCnt.text = "\(user.numFollowers!)"
            self.profileFollowersCnt.sizeToFit()
            self.profileFollowingCnt.text = "\(user.numFollowing!)"
            self.profileFollowingCnt.sizeToFit()
            
        }
    }
    
//    func refreshTimeline() {
//        findMinMaxId()
//        User.currentUser!.homeTimelineWithCompletion(nil, maxId: maxId, completion: { (tweets, error) -> Void in
//            var newTweets = [Tweet]()
//            if tweets != nil {
//                newTweets += tweets!
//                newTweets += self.tweets!
//                self.tweets = newTweets
//                self.profileTableView.reloadData()
//            } else {
//                println(error)
//            }
//        })
//    }
    
    // MARK: - TweetTableViewCellDelegate functions

    func replyTweetFromTableViewCell(tweet: Tweet) {
        self.performSegueWithIdentifier("replyTweetFromTimeline", sender: tweet)
    }
    
    func tweetUpdated(tweet: Tweet, forCell: UITableViewCell) {
        let indexPath:NSIndexPath = self.profileTableView.indexPathForCell(forCell)!
        self.tweets[indexPath.row] = tweet
        self.profileTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func profileImageTapped(tweet: Tweet, forCell: UITableViewCell) {
        // noop
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
