//
//  TimelineViewController.swift
//  Twitter
//
//  Created by Ding, Quan on 2/17/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetTableViewCellDelegate {
    var tweets: [Tweet]!
    var minId: UInt64!
    var maxId: UInt64!
    
    var refreshControl: UIRefreshControl!
    var tweet: Tweet? { // to hold the newly composed tweet from NewTweetViewController
        didSet {
            if (tweet != nil) {
                tweets.insert(tweet!, atIndex: 0)
                self.tweetsTable.reloadData()
            }
        }
    }
    
    @IBOutlet weak var tweetsTable: UITableView!
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        minId = UINT64_MAX
        maxId = 1 as UInt64
        tweets = [Tweet]()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTweetTableWithNewTweet:", name: newTweetCreatedNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTweetTableWithTweet:", name: tweetUpdatedNotification, object: nil)
        
        self.tweetsTable.estimatedRowHeight = 260
        self.tweetsTable.rowHeight = UITableViewAutomaticDimension
        
        self.tweetsTable.addInfiniteScrollingWithActionHandler({
            println("infinite scroll triggered")
            self.fetchMoreTimeline()
            ();
        })

        // don't like the SVPullToRefresh's default look
//        self.tweetsTable.addPullToRefreshWithActionHandler({
//            println("pull to refresh triggered")
//            self.refreshTimeline()
//            ();
//        })
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshTimeline", forControlEvents: UIControlEvents.ValueChanged)
        self.tweetsTable.insertSubview(refreshControl, atIndex: 0)
        
        // Do any additional setup after loading the view.
        User.currentUser?.homeTimelineWithCompletion(minId, maxId: nil, completion: { (tweets, error) -> () in
            if tweets != nil {
                self.tweets = tweets
                self.tweetsTable.reloadData()
            } else {
                println(error)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            (cell as! TextTableViewCell).tweet = tweet
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! ImageTableViewCell
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
        self.performSegueWithIdentifier("showTweetDetails", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTweetDetails" {
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
        findMinMaxId()
        User.currentUser!.homeTimelineWithCompletion(minId, maxId: nil, completion: { (tweets, error) -> Void in
            if tweets != nil {
                self.tweets! += tweets!
                self.tweetsTable.reloadData()
            } else {
                println(error)
            }
            self.tweetsTable.infiniteScrollingView.stopAnimating()
        })
    }
    
    func refreshTimeline() {
        findMinMaxId()
        User.currentUser!.homeTimelineWithCompletion(nil, maxId: maxId, completion: { (tweets, error) -> Void in
            var newTweets = [Tweet]()
            if tweets != nil {
                newTweets += tweets!
                newTweets += self.tweets!
                self.tweets = newTweets
                self.tweetsTable.reloadData()
            } else {
                println(error)
            }
//            self.tweetsTable.pullToRefreshView.stopAnimating()
            self.refreshControl.endRefreshing()
        })
    }
    
    private func findMinMaxId() -> Void {
        self.minId = UINT64_MAX
        self.maxId = 1 as UInt64
        
        if self.tweets != nil {
            for tweet in tweets! {
                var uid = tweet.id
                if uid < minId {
                    self.minId = uid
                }
                if uid > maxId {
                    self.maxId = uid
                }
            }
        }
    }
    
    func updateTweetTableWithNewTweet(notification: NSNotification){
        let tweet = notification.object
        if ((tweet?.isKindOfClass(Tweet) != nil)){
            tweets.insert(tweet! as! Tweet, atIndex: 0)
            self.tweetsTable.reloadData()
        }
    }
    
    func updateTweetTableWithTweet(notification: NSNotification){
        let obj = (notification.object as! NSDictionary)
        let tweet = obj["tweet"] as! Tweet
        let indexPath = obj["indexPath"] as! NSIndexPath
        self.tweets[indexPath.row] = tweet
        self.tweetsTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func replyTweetFromTableViewCell(tweet: Tweet) {
        self.performSegueWithIdentifier("replyTweetFromTimeline", sender: tweet)
    }
    
    func tweetUpdated(tweet: Tweet, forCell: UITableViewCell) {
        let indexPath:NSIndexPath = self.tweetsTable.indexPathForCell(forCell)!
        self.tweets[indexPath.row] = tweet
        self.tweetsTable.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
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
