//
//  ProfileViewController.swift
//  TwitterV2
//
//  Created by Ding, Quan on 2/26/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, TweetTableViewCellDelegate {

    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var profileTableHeader: UIView!
    @IBOutlet weak var profileBackgroundImage: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileScreenName: UILabel!
    @IBOutlet weak var profileDescription: UILabel!
    @IBOutlet weak var profileFollowingCnt: UILabel!
    @IBOutlet weak var profileFollowersCnt: UILabel!

    @IBOutlet weak var profileImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageHeightConstraint: NSLayoutConstraint!

    private let initialHeaderImageYOffset:CGFloat = -64
    private let initialHeaderImageHeight:CGFloat = 106
    private let stickyHeaderStartOffset:CGFloat = -22
    private let blurBackgroundStartOffset:CGFloat = 36
    private let blurBackgroundEndOffset:CGFloat = 65
    
    private var blurImageView:UIImageView!
    
    var user: User!
    var tweets: [Tweet]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tweets = [Tweet]()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
//        setNavigationBarTransparent()
        
        self.profileTableView.estimatedRowHeight = 260
        self.profileTableView.rowHeight = UITableViewAutomaticDimension
        
        showProfileHeaderView()
        fetchMoreTimeline()
    }
    
    func captureAndAddBlurImageBackground() {
        print("capture image background")
        self.blurImageView = UIImageView(frame: self.profileBackgroundImage.frame)
        self.blurImageView.image = self.profileBackgroundImage.image!.applyBlurWithRadius(12, tintColor: UIColor(white:0.8, alpha:0.4), saturationDeltaFactor: 1.8, maskImage: nil)
        self.blurImageView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.blurImageView.alpha = 0
        self.blurImageView.backgroundColor = UIColor.clearColor()
        self.profileTableHeader.addSubview(blurImageView)
    }

    override func viewWillAppear(animated: Bool) {
        setNavigationBarTransparent()
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
        let tweet = tweets![indexPath.row]
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
        self.profileTableView.deselectRowAtIndexPath(indexPath, animated: true)
//        let cell = self.profileTableView.cellForRowAtIndexPath(indexPath)
//        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        self.performSegueWithIdentifier("showDetailsFromProfile", sender: indexPath)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        print("contentOffset: ")
        print(scrollView.contentOffset);
        var headerRect = CGRect(x: 0, y: initialHeaderImageYOffset, width: self.profileTableView.bounds.width, height: initialHeaderImageHeight)
        let yOffset = scrollView.contentOffset.y
        
        if yOffset < initialHeaderImageYOffset {
            //parallax effect when pulling down the banner image
            headerRect.origin.y = yOffset
            headerRect.size.height = initialHeaderImageHeight + (-yOffset + initialHeaderImageYOffset)
        } else {
            if yOffset >= stickyHeaderStartOffset {
                headerRect.origin.y = -stickyHeaderStartOffset + (yOffset + initialHeaderImageYOffset)
                headerRect.size.height = initialHeaderImageHeight
                
                let tmpFrame = self.profileImageView.frame
                self.profileTableHeader.sendSubviewToBack(self.profileImageView)
                self.profileImageView.frame = tmpFrame
                
                if (user.bannerImageUrl != nil) {
                    if (yOffset >= blurBackgroundStartOffset) {
                        // blur the background image
                        self.blurImageView?.frame = headerRect
                        self.blurImageView?.alpha = min(1, (yOffset - blurBackgroundStartOffset) / (blurBackgroundEndOffset - blurBackgroundStartOffset))
                        print("alpha: \(self.blurImageView.alpha)")
                        //                self.profileBackgroundImage.image = self.profileBackgroundImage.image!.applyLightEffect() // NOTE: doesn't like the effect
                        //NOTE: effect is not what I want
                        //                var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
                        //                visualEffectView.frame = self.profileBackgroundImage.bounds
                        //                self.profileBackgroundImage.addSubview(visualEffectView)
                    } else {
                        self.blurImageView?.alpha = 0 // hide the blur background image
                        
                    }
                }
            } else {
                self.profileTableHeader.bringSubviewToFront(self.profileImageView)
                
                // shrink the profile image (yOffset from -64 to -20, image side length from 66 to 44
                let sideLength = CGFloat(66 - (yOffset + 64) / 2)
                self.profileImageWidthConstraint.constant = sideLength
                self.profileImageHeightConstraint.constant = sideLength
            }
        }
        profileBackgroundImage.frame = headerRect
        print("headerRect: ", terminator: "" )
        print(headerRect)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetailsFromProfile" {
            let indexPath:NSIndexPath = sender as! NSIndexPath
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
                print(error)
            }
        })
    }
    
    func showProfileHeaderView() -> Void {
        if let user = user {
            ImageHelpers
                .roundedCornerWithBoarder(self.profileImageView)
            ImageHelpers.fadeInImage(self.profileImageView, imgUrl: user.profileImageUrl)
            if let bannerImageUrl = user.bannerImageUrl {
//                ImageHelpers.fadeInImage(self.profileBackgroundImage, imgUrl: bannerImageUrl)
                ImageHelpers.fadeInImageWithCompletion(self.profileBackgroundImage, imgUrl: bannerImageUrl, completion: { () -> () in
                    self.captureAndAddBlurImageBackground()
                })
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
