//
//  ContainerViewController.swift
//  TwitterV2
//
//  Created by Ding, Quan on 2/26/15.
//  Copyright (c) 2015 Codepath. All rights reserved.
//

import UIKit

let menuTappedNotification = "menuTappedNotification"

class ContainerViewController: UIViewController, MenuViewControllerDelegate {
    var menuRevealed: Bool!
    
    var timelineViewController: TimelineViewController!
    var menuViewController: MenuViewController!
    var timelineNavController: UINavigationController!
    var menuNavController: UINavigationController!
    var profileViewController: ProfileViewController!
    var mentionsViewController: MentionsViewController!
    
    var timelineViewOriginalCenter: CGPoint!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        menuRevealed = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        menuNavController = storyBoard.instantiateViewControllerWithIdentifier("MenuNavController") as! UINavigationController
        menuViewController = menuNavController.topViewController as! MenuViewController
        timelineNavController = storyBoard.instantiateViewControllerWithIdentifier("TimelineNavController") as! UINavigationController
        timelineViewController = timelineNavController.topViewController as! TimelineViewController
        profileViewController = storyBoard.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        mentionsViewController = storyBoard.instantiateViewControllerWithIdentifier("MentionsViewController") as! MentionsViewController
        
//        menuViewController = storyBoard.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
//        timelineViewController = storyBoard.instantiateViewControllerWithIdentifier("TimelineViewController") as! TimelineViewController
//        timelineNavController = UINavigationController(rootViewController: menuViewController)
//        menuNavController = UINavigationController(rootViewController: menuViewController)
        
        menuViewController.delegate = self
        
        self.addChildViewController(timelineNavController)
        self.timelineNavController.view.frame = self.view.frame
        self.view.addSubview(timelineNavController.view)
        self.timelineNavController.didMoveToParentViewController(self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        timelineNavController.view.addGestureRecognizer(panGestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showHideMenu", name: menuTappedNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func showHideMenu(){
        if (menuRevealed == false){
            addMenuNavController()
            revealMenu()
            timelineViewController.tweetsTable.userInteractionEnabled = false

//            self.transitionFromViewController(self, toViewController: self.menuViewController, duration: 0.5, options: nil, animations: { () -> Void in
//                self.menuViewController.view.frame = self.view.frame
//                self.view!.center = CGPointMake(self.view!.center.x + self.screenWidth! - self.screenWidth! / 6, self.view!.center.y)
//            }, completion: { (finished) -> Void in
//                self.menuViewController?.didMoveToParentViewController(self)
//                ();
//            })

        } else {
            closeMenu()
            timelineViewController.tweetsTable.userInteractionEnabled = true
        }
    }
    
    func addMenuNavController() {
        if menuViewController != nil {
            self.addChildViewController(menuNavController)
            self.menuNavController.view.frame = self.view.frame
            self.view.insertSubview(menuNavController.view, atIndex: 0)
            self.menuNavController.didMoveToParentViewController(self)
        }
    }
    
    func removeMenuNavController() {
        if (menuViewController != nil) {
            self.menuNavController?.willMoveToParentViewController(nil)
            self.menuNavController?.view.removeFromSuperview()
            self.menuNavController.didMoveToParentViewController(nil)
        }
    }
    
    func addTimelineNavController(){
        if timelineNavController != nil {
            self.addChildViewController(timelineNavController)
            self.view.addSubview(timelineNavController.view)
            self.timelineNavController.didMoveToParentViewController(self)
        }
    }
    
    func removeTimelineNavController(){
        if timelineNavController != nil {
            self.timelineNavController.willMoveToParentViewController(nil)
            self.timelineNavController.view.removeFromSuperview()
            self.timelineNavController.didMoveToParentViewController(nil)
        }
    }
    
    func addPofileViewController() {
        
    }
    
    func removeProfileViewController() {
        
    }
    
    func revealMenu() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.timelineNavController!.view.frame.origin.x = CGRectGetWidth(self.timelineNavController.view.frame) - CGFloat(60)
        })
        menuRevealed = true
    }
    
    func closeMenu() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.timelineNavController!.view.frame.origin.x = 0
            }, completion: { (finished) -> Void in
                if (finished){
                    self.removeMenuNavController()
                }
            }
        )
        menuRevealed = false
    }
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer){
        let panLeftToRight = recognizer.velocityInView(view).x > 0
        var translation = recognizer.translationInView(view)
        println("panLeftToRight: \(panLeftToRight), translation: \(translation)")
        if recognizer.state == UIGestureRecognizerState.Began {
            addMenuNavController()
            timelineViewOriginalCenter = timelineNavController.view.center
        } else if recognizer.state == UIGestureRecognizerState.Changed {
            timelineNavController.view.center = CGPoint(x: timelineViewOriginalCenter.x + translation.x, y: timelineViewOriginalCenter.y)
        } else if recognizer.state == UIGestureRecognizerState.Ended {
            if panLeftToRight {
                revealMenu()
            } else {
                closeMenu()
            }
        }
    }
    
    // MARK: - MenuViewControllerDelegate
    func didSelectProfile() {
        
    }
    
    func didSelectHomeTimeline() {
        addTimelineNavController()
        closeMenu()
    }
    
    func didSelectMentions() {
        
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
