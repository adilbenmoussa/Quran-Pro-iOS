//
//  ContainerViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

enum SlideOutState {
    case BothCollapsed
    case ChaptersPanelExpanded
    case MorePanelExpanded
}

import UIKit

class ContainerViewController: UIViewController, CenterViewControllerDelegate, UIGestureRecognizerDelegate, SKStoreProductViewControllerDelegate {
    
    var centerNavigationController: UINavigationController!
    var centerViewController: CenterViewController!
    
    var chaptersNavigationController: UINavigationController!
    var chaptersViewController:ChaptersViewController?
    
    var moreNavigationController: UINavigationController!
    var moreViewController:MoreViewController?
    var whatIsNewViewController: WhatIsNewViewController?
    var currentState:SlideOutState = SlideOutState.BothCollapsed {
        didSet {
            let shouldShowShadow = currentState != SlideOutState.BothCollapsed
            self.showShadowForCenterViewController(shouldShowShadow)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "exitWhatIsNewVCdHandler:", name:kExitWhatIsNewVCNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "openSKControllerHandler:", name:kOpenSKControllerNotification, object: nil)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let currentVersion = Double(kApplicationVersion as String)
        if isPro {
            //what is new in 1.4
            if currentVersion == 1.4  && defaults.stringForKey(kWhatIsNew1dot4) == nil {
                whatIsNewViewController = WhatIsNewViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
                whatIsNewViewController?.version = 1.4
                view.addSubview(whatIsNewViewController!.view)
                addChildViewController(whatIsNewViewController!)
                defaults.setObject("new_in_1.4", forKey: kWhatIsNew1dot4)
            }
            else{
                initCenterViewControllers()
            }
        }
        else{
            initCenterViewControllers()
        }
    }
    
    func initCenterViewControllers() {
        
        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMoveToParentViewController(self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)

    }
    
    func exitWhatIsNewVCdHandler(notification: NSNotification){
        if whatIsNewViewController != nil {
            whatIsNewViewController!.view.removeFromSuperview()
            whatIsNewViewController!.removeFromParentViewController()
            whatIsNewViewController = nil
        }
        initCenterViewControllers()
    }
    
    /*func openSKControllerHandler(notification: NSNotification){
        let storeViewController:SKStoreProductViewController = SKStoreProductViewController()
        storeViewController.delegate = self;
        let someitunesid:String = kQuranProId;
        let productparameters = [SKStoreProductParameterITunesItemIdentifier:someitunesid];
        storeViewController.loadProductWithParameters(productparameters, completionBlock: {success, error in
            if success {
                print(success)
                //self.presentViewController(storeViewController, animated: true, completion: nil);
                //self.view.addSubview(storeViewController.view)
                //self.addChildViewController(storeViewController)
                self.centerNavigationController.presentViewController(storeViewController, animated: false, completion: {
                    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
                })
            } else {
                print(error)
            }
        })
    }*/
    
    
    // this is SKStoreProductViewControllerDelegate implementation
    override func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        viewController.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: CenterViewController delegate methods
    
    func toggleChaptersPanel() {
        let notAlreadyExpanded = (currentState != SlideOutState.ChaptersPanelExpanded)
        if notAlreadyExpanded {
            addCategoriesPanelViewController()
        }
        
        animateCategoriesPanel(shouldExpand: notAlreadyExpanded, duration: 0.5)
    }
    
    func toggleMorePanel() {
        
        let notAlreadyExpanded = (currentState != SlideOutState.MorePanelExpanded)
        if notAlreadyExpanded {
            addMorePanelViewController()
        }
        
        animateMoretPanel(shouldExpand: notAlreadyExpanded, duration: 0.5)
    }
    
    func addCategoriesPanelViewController() {
        
        if(chaptersViewController == nil){
            chaptersViewController = UIStoryboard.chaptersViewController()
            chaptersNavigationController = UINavigationController(rootViewController: chaptersViewController!)
        }
        if chaptersNavigationController.view.superview == nil {
            view.insertSubview(chaptersNavigationController!.view, atIndex: 0)
            addChildViewController(chaptersNavigationController!)
        }
        chaptersNavigationController!.didMoveToParentViewController(self)
    }
    
    func addMorePanelViewController() {
        if(moreViewController == nil){
            moreViewController = UIStoryboard.moreViewController()
            moreNavigationController = UINavigationController(rootViewController: moreViewController!)
        }
        
        if moreNavigationController.view.superview == nil {
            view.insertSubview(moreNavigationController!.view, atIndex: 0)
            addChildViewController(moreNavigationController!)
        }
        moreNavigationController!.didMoveToParentViewController(self)
    }
    
    func animateCategoriesPanel(shouldExpand shouldExpand: Bool, duration: NSTimeInterval) {
        if shouldExpand {
            currentState = SlideOutState.ChaptersPanelExpanded
            self.chaptersNavigationController.view.frame.size.width = CGRectGetWidth(centerNavigationController.view.frame) - kCenterPanelExpandedOffset
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - kCenterPanelExpandedOffset, duration: duration)
        }
        else{
            animateCenterPanelXPosition(targetPosition: 0, duration: duration) { finished in
                self.currentState = SlideOutState.BothCollapsed
                
                self.chaptersViewController?.view.removeFromSuperview()
                self.chaptersNavigationController?.view.removeFromSuperview()
                //self.chaptersViewController = nil
               // self.chaptersNavigationController = nil
            }
        }
    }
    
    func animateMoretPanel(shouldExpand shouldExpand: Bool, duration: NSTimeInterval) {
        if shouldExpand {
            currentState = SlideOutState.MorePanelExpanded
            self.moreNavigationController.view.frame.origin.x = kCenterPanelExpandedOffset
            self.moreNavigationController.view.frame.size.width = CGRectGetWidth(centerNavigationController.view.frame) - kCenterPanelExpandedOffset
            self.moreNavigationController.view.frame.size.height = CGRectGetHeight(centerNavigationController.view.frame)
            animateCenterPanelXPosition(targetPosition: -CGRectGetWidth(centerNavigationController.view.frame) + kCenterPanelExpandedOffset, duration: duration)
        }
        else{
            animateCenterPanelXPosition(targetPosition: 0, duration: 0.5) { item in
                self.currentState = SlideOutState.BothCollapsed
                
                self.moreViewController!.view.removeFromSuperview()
                self.moreNavigationController?.view.removeFromSuperview()
                //self.moreViewController = nil
                //self.moreNavigationController = nil
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, duration: NSTimeInterval, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    func collapseSidePanels() {
        switch (currentState) {
        case SlideOutState.MorePanelExpanded:
            toggleMorePanel()
        case SlideOutState.ChaptersPanelExpanded:
            toggleChaptersPanel()
        default:
            break
        }
    }
    
    // MARK: Gesture recognizer
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        switch(recognizer.state) {
        case .Began:
            if (currentState == SlideOutState.BothCollapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addCategoriesPanelViewController()
                } else {
                    addMorePanelViewController()
                }
                showShadowForCenterViewController(true)
            }
        case .Changed:
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            if(chaptersNavigationController != nil && chaptersNavigationController.view.superview != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateCategoriesPanel(shouldExpand: hasMovedGreaterThanHalfway, duration: 0.5)
            }
            else if (moreNavigationController != nil && moreNavigationController.view.superview != nil) {
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x < 0
                animateMoretPanel(shouldExpand: hasMovedGreaterThanHalfway, duration: 0.5)
            }
        default:
            break
        }
    }
    
    //MARK: Orientation change
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator){
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
            if self.currentState == SlideOutState.MorePanelExpanded{
                self.animateMoretPanel(shouldExpand: true, duration: 0.0)
            }
            else if self.currentState == SlideOutState.ChaptersPanelExpanded{
                self.animateCategoriesPanel(shouldExpand: true, duration: 0.0)
            }
            }, completion: { (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
        })
    }
}
