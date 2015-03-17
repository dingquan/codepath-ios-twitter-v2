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
    var profileViewController: ProfileViewController!
    var mentionsViewController: TimelineViewController!
    var timelineNavController: UINavigationController!
    var menuNavController: UINavigationController!
    var profileNavController: UINavigationController!
    var mentionsNavController: UINavigationController!
    
    var currentNavController: UINavigationController!
    
    var currentNavControllerOriginalCenter: CGPoint!
    
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
        menuNavController = storyBoard.instantiateViewControllerWithIdentifier("MenuNavController") as UINavigationController
        menuViewController = menuNavController.topViewController as MenuViewController
        menuViewController.delegate = self
        
        timelineNavController = storyBoard.instantiateViewControllerWithIdentifier("TimelineNavController") as UINavigationController
        timelineViewController = timelineNavController.topViewController as TimelineViewController
        
        profileViewController = storyBoard.instantiateViewControllerWithIdentifier("ProfileViewController") as ProfileViewController
        profileViewController.user = User.currentUser!
        profileNavController = UINavigationController(rootViewController: profileViewController)
        
        mentionsNavController = storyBoard.instantiateViewControllerWithIdentifier("TimelineNavController") as UINavigationController
        mentionsViewController = mentionsNavController.topViewController as TimelineViewController
        mentionsViewController.isHomeTimeline = false
        
        addTimelineNavController()
        
        let timelineViewPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        timelineNavController.view.addGestureRecognizer(timelineViewPanGestureRecognizer)
        let profileViewPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        profileNavController.view.addGestureRecognizer(profileViewPanGestureRecognizer)
        let mentionsViewPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        mentionsNavController.view.addGestureRecognizer(mentionsViewPanGestureRecognizer)
        
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
            revealMenu()
        } else {
            closeMenu()
        }
    }
    
    func revealMenu() {
        addMenuNavController()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.currentNavController!.view.frame.origin.x = CGRectGetWidth(self.currentNavController.view.frame) - CGFloat(60)
            }, completion: { (finished) -> Void in
                if (finished){
                    self.disableTableViewInteraction()
                    self.menuRevealed = true
                }
            }
        )
    }
    
    func closeMenu() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.currentNavController!.view.frame.origin.x = 0
            }, completion: { (finished) -> Void in
                if (finished){
                    self.removeMenuNavController()
                    self.enableTableViewInteraction()
                    self.menuRevealed = false
                }
            }
        )
    }
    
    func disableTableViewInteraction() {
        timelineViewController.tweetsTable?.userInteractionEnabled = false
        mentionsViewController.tweetsTable?.userInteractionEnabled = false
        profileViewController.profileTableView?.userInteractionEnabled = false
    }
    
    func enableTableViewInteraction(){
        timelineViewController.tweetsTable?.userInteractionEnabled = true
        mentionsViewController.tweetsTable?.userInteractionEnabled = true
        profileViewController.profileTableView?.userInteractionEnabled = true
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
            if self.currentNavController != nil {
                self.timelineNavController.view.frame = self.currentNavController.view.frame
            } else {
                self.timelineNavController.view.frame = self.view.frame // this is the initial load case when none of the nav controller has been loaded to the scene yet
            }
            self.currentNavController = timelineNavController
        }
    }
    
    func removeTimelineNavController(){
        if timelineNavController != nil {
            self.timelineNavController.willMoveToParentViewController(nil)
            self.timelineNavController.view.removeFromSuperview()
            self.timelineNavController.didMoveToParentViewController(nil)
        }
    }
    
    func addPofileNavController() {
        if profileNavController != nil {
            self.addChildViewController(profileNavController)
            self.view.addSubview(profileNavController.view)
            self.profileNavController.didMoveToParentViewController(self)
            self.profileNavController.view.frame = self.currentNavController.view.frame
            self.currentNavController = profileNavController
        }
    }
    
    func removeProfileNavController() {
        if profileNavController != nil {
            self.profileNavController.willMoveToParentViewController(nil)
            self.profileNavController.view.removeFromSuperview()
            self.profileNavController.didMoveToParentViewController(nil)
        }
    }
    
    func addMentionsNavController() {
        if mentionsNavController != nil {
            self.addChildViewController(mentionsNavController)
            self.view.addSubview(mentionsNavController.view)
            self.mentionsNavController.didMoveToParentViewController(self)
            self.mentionsNavController.view.frame = self.currentNavController.view.frame
            self.currentNavController = mentionsNavController
        }
    }
    
    func removeMentionsNavController() {
        if mentionsNavController != nil {
            self.mentionsNavController.willMoveToParentViewController(nil)
            self.mentionsNavController.view.removeFromSuperview()
            self.mentionsNavController.didMoveToParentViewController(nil)
        }
    }
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer){
        let panLeftToRight = recognizer.velocityInView(view).x > 0
        var translation = recognizer.translationInView(view)
        println("panLeftToRight: \(panLeftToRight), translation: \(translation)")
        if recognizer.state == UIGestureRecognizerState.Began {
            addMenuNavController()
            currentNavControllerOriginalCenter = currentNavController.view.center
        } else if recognizer.state == UIGestureRecognizerState.Changed {
            currentNavController.view.center = CGPoint(x: currentNavControllerOriginalCenter.x + translation.x, y: currentNavControllerOriginalCenter.y)
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
        addPofileNavController()
        removeMentionsNavController()
        removeTimelineNavController()
        closeMenu()
    }
    
    func didSelectHomeTimeline() {
        addTimelineNavController()
        removeProfileNavController()
        removeMentionsNavController()
        closeMenu()
    }
    
    func didSelectMentions() {
        addMentionsNavController()
        removeTimelineNavController()
        removeProfileNavController()
        closeMenu()
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
