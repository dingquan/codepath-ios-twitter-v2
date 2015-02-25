//
//  TextTableViewCell.swift
//  Twitter
//
//  Created by Ding, Quan on 2/18/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import UIKit

protocol TweetTableViewCellDelegate : class {
    func replyTweetFromTableViewCell(tweet: Tweet)
    func tweetUpdated(tweet: Tweet, forCell: UITableViewCell)
}

class TextTableViewCell: UITableViewCell, TTTAttributedLabelDelegate {
    weak var delegate: TweetTableViewCellDelegate?

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var tweetBody: TTTAttributedLabel!
    @IBOutlet weak var favoriteCount: UILabel!
    @IBOutlet weak var retweetCount: UILabel!

    @IBOutlet weak var replyIcon: UIButton!
    @IBOutlet weak var retweetIcon: UIButton!
    @IBOutlet weak var favoriteIcon: UIButton!
    
    var retweet: Tweet?

    var tweet:Tweet? {
        didSet {
            var user:User = tweet!.user!
            self.name.text = user.name!
            self.screenName.text = "@\(user.screenName!)"
            self.tweetBody.text = tweet!.text!
            self.tweetBody.preferredMaxLayoutWidth = self.tweetBody.frame.size.width
            self.tweetBody.sizeToFit()
            self.favoriteCount.text = "\(tweet!.favoriteCount!)"
            self.favoriteCount.sizeToFit()
            self.retweetCount.text = "\(tweet!.retweetCount!)"
            self.retweetCount.sizeToFit()
            self.createdAt.text = tweet!.createdAt!.shortTimeAgoSinceNow()
            self.createdAt.sizeToFit()
            if tweet!.favorited! {
                self.favoriteIcon.setImage(UIImage(named: "favorite_on"), forState: UIControlState.Normal)
            } else {
                self.favoriteIcon.setImage(UIImage(named: "favorite"), forState: UIControlState.Normal)
            }
            if tweet!.retweeted! {
                self.retweetIcon.setImage(UIImage(named: "retweet_on"), forState: UIControlState.Normal)
            } else {
                self.retweetIcon.setImage(UIImage(named: "retweet"), forState: UIControlState.Normal)
            }
            ImageHelpers.roundedCorner(self.profileImage)
            if tweet?.user?.profileImageUrl! != oldValue?.user?.profileImageUrl! {
                fadeInImage(self.profileImage, imgUrl: tweet?.user?.profileImageUrl)
            }
        }
    }
    
    private func fadeInImage(imageView: UIImageView, imgUrl: String?) -> Void {
        imageView.image = nil
        var urlReq = NSURLRequest(URL: NSURL(string: imgUrl!)!)
        imageView.setImageWithURLRequest(urlReq, placeholderImage: nil, success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image:UIImage!) -> Void in
            imageView.alpha = 0.0
            imageView.image = image
            UIView.animateWithDuration(0.25, animations: { imageView.alpha = 1.0})
            }, failure: { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
                println(error)
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.tweetBody.delegate = self
        self.tweetBody.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onReply(sender: AnyObject) {
        delegate?.replyTweetFromTableViewCell(self.tweet!)
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        var oldRetweetCount = self.tweet!.retweetCount!
        if (self.tweet?.retweeted! == true) {
            User.currentUser?.deleteTweetWithCompletion(self.retweet!.id!, completion: { (tweet, error) -> Void in
                if (tweet != nil) {
                    if oldRetweetCount == tweet!.retweetCount! {
                        tweet!.retweetCount!--
                    }
                    self.retweet = tweet!
                    self.tweet!.retweetCount = tweet!.retweetCount!
                    self.tweet!.retweeted = tweet!.retweeted!
                    self.retweetCount.text = "\(tweet!.retweetCount!)"
                    self.retweetCount.sizeToFit()
                    self.retweetIcon.setImage(UIImage(named: "retweet"), forState: UIControlState.Normal)
                }
                else {
                    println(error)
                }
            })
        } else {
            User.currentUser?.reTweetWithCompletion(self.tweet!.id!, completion: { (tweet, error) -> Void in
                if (tweet != nil) {
                    if oldRetweetCount == tweet!.retweetCount! {
                        tweet!.retweetCount!++
                    }
                    self.retweet = tweet!
                    self.tweet!.retweetCount = tweet!.retweetCount!
                    self.tweet!.retweeted = tweet!.retweeted!
                    self.retweetCount.text = "\(tweet!.retweetCount!)"
                    self.retweetCount.sizeToFit()
                    self.retweetIcon.setImage(UIImage(named: "retweet_on"), forState: UIControlState.Normal)
                }
                else {
                    println(error)
                }
            })
        }
    }

    @IBAction func onFavorite(sender: AnyObject) {
        var oldFavCount = self.tweet!.favoriteCount!
        if (tweet!.favorited! == true) {
            User.currentUser?.unfavoriteTweetWithCompletion(self.tweet!.id!, completion: { (tweet, error) -> Void in
                if (tweet != nil) {
                    if oldFavCount == tweet!.favoriteCount! {
                        tweet!.favoriteCount!--
                    }
                    self.tweet = tweet!
                    self.favoriteIcon.setImage(UIImage(named: "favorite"), forState: UIControlState.Normal)
                    self.favoriteCount.text = "\(tweet!.favoriteCount!)"
                    self.favoriteCount.sizeToFit()
                    self.delegate?.tweetUpdated(tweet!, forCell: self)
                } else {
                    println(error)
                }
            })
        } else {
            User.currentUser?.favoriteTweetWithCompletion(self.tweet!.id!, completion: { (tweet, error) -> Void in
                if (tweet != nil) {
                    if oldFavCount == tweet!.favoriteCount! {
                        tweet!.favoriteCount!++
                    }
                    self.tweet = tweet!
                    self.favoriteIcon.setImage(UIImage(named: "favorite_on"), forState: UIControlState.Normal)
                    self.favoriteCount.text = "\(tweet!.favoriteCount!)"
                    self.favoriteCount.sizeToFit()
                    self.delegate?.tweetUpdated(tweet!, forCell: self)
                } else {
                    println(error)
                }
            })
        }
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        UIApplication.sharedApplication().openURL(url)
    }
}
