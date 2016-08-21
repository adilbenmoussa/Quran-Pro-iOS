//
//  BookmarkViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit
let bookmartCellIdentifier = "BookmartCellIdentifier"

class BookmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableView: UITableView!
    
    var contents: NSMutableDictionary!
    var keys: NSMutableArray!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }

    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadData()
        self.tableView.estimatedRowHeight = 64.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bookmarksChangedHandler:", name:kBookmarkChangedNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Bookmarks".local
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: bookmartCellIdentifier)
        //load the table data
        reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return keys.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (keys.objectAtIndex(section) as! String).local
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key: String = keys.objectAtIndex(section) as! String
        if let sectionContents: NSArray = self.contents.objectForKey(key) as? NSArray {
            return sectionContents.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let key: String = keys.objectAtIndex(indexPath.section) as! String
        let sectionContents: NSArray = contents.objectForKey(key) as! NSArray
        let verse: Verse = sectionContents.objectAtIndex(indexPath.row) as! Verse
        let cell = tableView.dequeueReusableCellWithIdentifier(bookmartCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = verse.translationSearch
        cell.textLabel?.font = kLatinSearchAndBookmarkFont
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let key: String = keys.objectAtIndex(indexPath.section) as! String
        let sectionContents: NSArray = contents.objectForKey(key) as! NSArray
        let verse: Verse = sectionContents.objectAtIndex(indexPath.row) as! Verse
        NSNotificationCenter.defaultCenter().postNotificationName(kNewVerseSelectedNotification, object: nil,  userInfo:["verse":verse, "toggle": "right"])
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    @IBAction func removeAllBookmars(sender: AnyObject) {
        
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Remove all bookmarks?".local, message: nil, preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction = UIAlertAction(title: "No".local, style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            //Just dismiss the action sheet
        })
        
        //Create and add the add-bookmark action
        let removeBookmarkAction = UIAlertAction(title: "Yes".local, style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            BookmarkService.instance.clear()
            self.reloadData()
            NSNotificationCenter.defaultCenter().postNotificationName(kBookmarksRemovedNotification, object: nil,  userInfo:nil)
            Flurry.logEvent(FlurryEvent.removeAllBookmarks)
        })
        
        actionSheetController.addAction(removeBookmarkAction)
        actionSheetController.addAction(cancelAction)
        
        //We need to provide a popover sourceView when using it on iPad
        if isIpad {
            let popPresenter: UIPopoverPresentationController = actionSheetController.popoverPresentationController!
            if let v:UIView = sender.view {
                popPresenter.sourceView = v;
                popPresenter.sourceRect = v.bounds
            }
            else{
                popPresenter.sourceView = self.view
                popPresenter.sourceRect = self.view.bounds
            }
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    //MARK: Data
    
    func reloadData(){
        let bookmarktuple = BookmarkService.instance.sortedKeysAndContents()
        self.contents = bookmarktuple.contents
        self.keys = bookmarktuple.keys
        tableView.reloadData()
        self.navigationItem.rightBarButtonItem!.enabled = !BookmarkService.instance.isEmpty()
        Flurry.logEvent(FlurryEvent.totalBookmarks, withParameters: ["value": BookmarkService.instance.bookMarks.count])
    }
    
    // MARK: Notifications
    
    func bookmarksChangedHandler(notification: NSNotification){
        self.reloadData()
    }
}