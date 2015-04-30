//
//  Tweet.swift
//  Twitter
//
//  Created by Ding, Quan on 2/17/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import Foundation

class Tweet {
    var text:String?
    var createdAt:NSDate?
    var user:User?
    var retweetCount:Int?
    var retweeted:Bool?
    var retweetId:UInt64?
    var favoriteCount:Int?
    var favorited:Bool?
    var imageUrl:String?
    var id:UInt64?
    
    init(dictionary: NSDictionary){
        self.text = dictionary["text"] as? String
        self.user = User(dictionary: dictionary["user"] as! NSDictionary)
        self.id = (dictionary["id"] as! NSNumber).unsignedLongLongValue
        
        var createdAtStr = dictionary["created_at"] as? String
        var dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        self.createdAt = dateFormatter.dateFromString(createdAtStr!)
        
        self.favorited = dictionary["favorited"] as? Bool
        self.favoriteCount = dictionary["favorite_count"] as? Int
        self.retweeted = dictionary["retweeted"] as? Bool
        self.retweetCount = dictionary["retweet_count"] as? Int
        
        var entities = dictionary["entities"] as? NSDictionary
        if entities != nil {
            var media = entities!["media"] as? NSArray
            if media != nil {
                for aMedia in media! {
                    var type = (aMedia as! NSDictionary)["type"] as? NSString
                    if type == "photo" {
                        self.imageUrl = (aMedia as! NSDictionary)["media_url"] as? String
                    }
                }
            }
        }
    }
    
    class func tweetsWithArray(array:[NSDictionary]) -> [Tweet] {
        var tweets:[Tweet] = [Tweet]()
        
        for dictionary in array {
            var tweet:Tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        return tweets
    }
}