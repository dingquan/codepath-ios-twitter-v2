//
//  TwitterClient.swift
//  Twitter
//
//  Created by Ding, Quan on 2/17/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import Foundation

private let TwitterConsumerKey = "YC69DFPYNxkoNDDiBDG5oLqrC"
private let TwitterConsumerSecret = "5PbpQpKyEwbBPDOQBYIV1cT66dDZoYrcOzBt6IQMwyb3dBTpY7"
private let TwitterApiBaseUrl = "https://api.twitter.com"
private let _singletonInstance = TwitterClient()

let newTweetCreatedNotification = "NewTweetCreatedNotification"
let tweetUpdatedNotification = "TweetUpdatedNotification"

class TwitterClient: BDBOAuth1RequestOperationManager {
    class var sharedInstance :TwitterClient {
        return _singletonInstance
    }
    
    var completionFunc: ((user: User?, error: NSError?) -> Void)?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        var baseUrl = NSURL(string: TwitterApiBaseUrl)
        super.init(baseURL: baseUrl, consumerKey: TwitterConsumerKey, consumerSecret: TwitterConsumerSecret)
    }
    
    
    func loginWithCompletion(complete: (user:User?, error: NSError?) -> Void) {
        self.completionFunc = complete
        self.requestSerializer.removeAccessToken()
        self.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterclient://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
                println("Got the request token")
                
                var authUrl = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
                var application = UIApplication.sharedApplication()
                application.openURL(authUrl!)
            }, failure: { (error: NSError!) -> Void in
                println(error)
                if (self.completionFunc != nil){
                    self.completionFunc!(user: nil, error: error)
                }
            }
        )
    }
    
    func openUrl(url: NSURL) -> Void {
        self.fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (credential: BDBOAuth1Credential!) -> Void in
                println("got access token")
                self.requestSerializer.saveAccessToken(credential)
                self.getUserProfile()
            }, failure: { (error: NSError!) -> Void in
                println(error)
                if (self.completionFunc != nil){
                    self.completionFunc!(user:nil, error: error)
                }
            })
    }
    
    func getUserProfile() -> Void {
        super.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) -> Void in
                println(response)
                var user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                if (self.completionFunc != nil){
                    self.completionFunc!(user:user, error: nil)
                }
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error)
                if (self.completionFunc != nil){
                    self.completionFunc!(user:nil, error: error)
                }
            })
    }
    
    func homeTimelineWithCompletion(minId: UInt64?, maxId: UInt64?, completion: (tweets: [Tweet]?, error: NSError?) -> ()){
        var params:NSDictionary = NSMutableDictionary()
        
        if (minId != nil) {
            if (minId != UINT64_MAX) {
                params.setValue(String(minId! - 1), forKey: "max_id")
            } else {
                params.setValue("1", forKey: "since_id")
            }
        }
        if (maxId != nil){
            params.setValue(String(maxId!), forKey: "since_id")
        }
        
        super.GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
//            println(response)
            var tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            completion(tweets: nil, error: error)
        })
    }
    
    func postTweet(originalTweet: Tweet?, tweetText: String?, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params:NSDictionary = NSMutableDictionary()
        if tweetText == nil {
            return
        }

        // handle the reply tweet case
//        var newTweetText = (originalTweet == nil ? tweetText : "@\(originalTweet!.user!.name!) \(tweetText)")
//        params.setValue(newTweetText, forKey: "status")
        params.setValue(tweetText, forKey: "status")
        if (originalTweet != nil) {
            params.setValue(String(originalTweet!.id!), forKey: "in_reply_to_status_id")
        }
        
        super.POST("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                println(response)
                var tweet:Tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(tweet: nil, error: error)
        })
    }
    
    func favoriteTweet(id: UInt64, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params:NSDictionary = NSMutableDictionary()
        params.setValue(String(id), forKey: "id")
        super.POST("1.1/favorites/create.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                println(response)
                var tweet:Tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(tweet: nil, error: error)
        })
    }
    
    func unfavoriteTweet(id: UInt64, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params:NSDictionary = NSMutableDictionary()
        params.setValue(String(id), forKey: "id")
        super.POST("1.1/favorites/destroy.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println(response)
            var tweet:Tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(tweet: nil, error: error)
        })
    }
    
    func reTweet(id: UInt64, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params:NSDictionary = NSMutableDictionary()
        params.setValue(String(id), forKey: "id")
        super.POST("1.1/statuses/retweet/\(id).json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println(response)
            var tweet:Tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(tweet: nil, error: error)
        })
    }
    
    func deleteTweet(id: UInt64, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        var params:NSDictionary = NSMutableDictionary()
        params.setValue(String(id), forKey: "id")
        super.POST("1.1/statuses/destroy/\(id).json", parameters: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            println(response)
            var tweet:Tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(tweet: nil, error: error)
        })
    }

}