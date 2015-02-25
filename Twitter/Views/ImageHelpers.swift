//
//  AnimationUtils.swift
//  Twitter
//
//  Created by Ding, Quan on 2/19/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import Foundation

class ImageHelpers {
    class func fadeInImage(imageView: UIImageView, imgUrl: String?) -> Void {
        imageView.image = nil
        var urlReq = NSURLRequest(URL: NSURL(string: imgUrl!)!)
        imageView.setImageWithURLRequest(urlReq, placeholderImage: nil, success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image:UIImage!) -> Void in
            imageView.alpha = 0.0
            imageView.image = image
//            imageView.sizeToFit()
            UIView.animateWithDuration(0.25, animations: { imageView.alpha = 1.0})
            }, failure: { (request:NSURLRequest!, response:NSHTTPURLResponse!, error:NSError!) -> Void in
                println(error)
        })
    }
    
    class func roundedCorner(imageView: UIImageView) -> Void {
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
    }
}