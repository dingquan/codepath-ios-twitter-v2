//
//  User.swift
//  Twitter
//
//  Created by Ding, Quan on 2/17/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import Foundation
private let currentUserKey = "kCurrentUserKey"
private var _currentUser: User?

let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User {
    var name:String?
    var screenName: String?
    var profileImageUrl: String?
    var tagLine: String?
    var id: UInt64?
    var dictionary: NSDictionary
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        self.name = dictionary["name"] as? String
        self.screenName = dictionary["screen_name"] as? String
        self.profileImageUrl = dictionary["profile_image_url"] as? String
        self.tagLine = dictionary["description"] as? String
        self.id = (dictionary["id"] as! NSNumber).unsignedLongLongValue
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                var data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if data != nil {
                    var dictionary = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        set(user){
            _currentUser = user
            if _currentUser != nil {
                var data = NSJSONSerialization.dataWithJSONObject(_currentUser!.dictionary, options: nil, error: nil)
                NSUserDefaults.standardUserDefaults().setObject(data , forKey: currentUserKey)
                NSUserDefaults.standardUserDefaults().synchronize()
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil , forKey: currentUserKey)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    func logout() -> Void {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLoginNotification, object: nil)
    }
    
    class func loginWithCompletion(completion: (user: User?, error: NSError?) -> Void){
        TwitterClient.sharedInstance.loginWithCompletion({(user: User?, error: NSError?) in
            completion(user:user, error:error)
        })
    }
    
    func homeTimelineWithCompletion(minId: UInt64?, maxId: UInt64?, completion: (tweets: [Tweet]?, error: NSError?) -> Void){
        TwitterClient.sharedInstance.homeTimelineWithCompletion(minId, maxId: maxId, completion: { (tweets, error) -> () in
            completion(tweets: tweets, error: error)
        })
    }
    
    func postTweetWithCompletion(originalTweet: Tweet?, tweetText: String, completion: (tweet: Tweet?, error: NSError?) -> Void){
        TwitterClient.sharedInstance.postTweet(originalTweet, tweetText: tweetText, completion: { (tweet, error) -> () in
            completion(tweet: tweet, error: error)
        })
    }
    
    func favoriteTweetWithCompletion(id: UInt64, completion: (tweet: Tweet?, error: NSError?) -> Void) {
        TwitterClient.sharedInstance.favoriteTweet(id, completion: { (tweet, error) -> () in
            completion(tweet: tweet, error: error)
        })
    }
    
    func unfavoriteTweetWithCompletion(id: UInt64, completion: (tweet: Tweet?, error: NSError?) -> Void) {
        TwitterClient.sharedInstance.unfavoriteTweet(id, completion: { (tweet, error) -> () in
            completion(tweet: tweet, error: error)
        })
    }
    
    func reTweetWithCompletion(id: UInt64, completion: (tweet: Tweet?, error: NSError?) -> Void) {
        TwitterClient.sharedInstance.reTweet(id, completion: { (tweet, error) -> () in
            completion(tweet: tweet, error: error)
        })
    }
    
    func deleteTweetWithCompletion(id: UInt64, completion: (tweet: Tweet?, error: NSError?) -> Void) {
        TwitterClient.sharedInstance.deleteTweet(id, completion: { (tweet, error) -> () in
            completion(tweet: tweet, error: error)
        })
    }
}