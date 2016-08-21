//
//  SearchViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

let searchCellId = "SearchCellId"

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    var searchController: UISearchController!
    let service: SearchService = SearchService.instance

    //keep the reference to the options
    var contents: NSMutableDictionary!
    var keys: NSMutableArray!
    var searchContents: NSMutableDictionary!
    var searchKeys: NSMutableArray!
    var resultPredicate: NSPredicate?
    var searchQueue:NSOperationQueue!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchQueue = NSOperationQueue()
        self.searchQueue.maxConcurrentOperationCount = 1
        
        let tuple = service.initialKeysAndContents()
        contents = tuple.contents
        keys = tuple.keys
        
        //init the search values
        searchContents = tuple.contents
        searchKeys = tuple.keys

        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: searchCellId)

        // init the seach controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Default
        searchController.searchBar.placeholder = "e.g. 6:88, الله, hizb 8 or Allah".local
        //tableView.tableHeaderView = searchController.searchBar
        navigationItem.titleView = searchController.searchBar
        
        //self.tableView.sectionIndexTrackingBackgroundColor = kAppColor
        //self.tableView.sectionIndexBackgroundColor = kAppColorLight
        //tableView.sectionIndexColor = kAppColor

        
        // By default the navigation bar hides when presenting the
        // search interface.  Obviously we don't want this to happen if
        // our search bar is inside the navigation bar.
        searchController.hidesNavigationBarDuringPresentation = false
        
        self.definesPresentationContext = true
        
        // The search bar does not seem to set its size automatically
        // which causes it to have zero height when there is no scope
        // bar. If you remove the scopeButtonTitles above and the
        // search bar is no longer visible make sure you force the
        // search bar to size itself (make sure you do this after
        // you add it to the view hierarchy).
        self.searchController.searchBar.sizeToFit();
        
        // style the searchdisplay contoller
        searchController.searchBar.setBackgroundImage(UIImage(named: kUINavigationBarBackgroundImage), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        //Sets the cancel text color to white
        //UIBarButtonItem.appearance().tintColor = UIColor.blackColor()
        
        let searchBarView: UIView = searchController.searchBar.subviews[0] as UIView
        //set the blinking cursor for the search field
        for subView: UIView in searchBarView.subviews {
            if subView.isKindOfClass(UITextField){
                subView.tintColor = kAppColor
            }
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "searchOptionChangedHandler:", name:kSearchOptionChangedNotification, object: nil)
        
        if $.searchOption != SearchOption.SearchOptionArabic {
            self.tableView.estimatedRowHeight = 64.0;
            self.tableView.rowHeight = UITableViewAutomaticDimension;
        }
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.searchController.active {
            return searchKeys.count
        }
        else{
            return keys.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.searchController.active {
            return (searchKeys.objectAtIndex(section) as! String)
        }
        else{
            return (keys.objectAtIndex(section) as! String)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.active {
            let key: String = searchKeys.objectAtIndex(section) as! String
            if let sectionContents: NSArray = self.searchContents.objectForKey(key) as? NSArray {
                return sectionContents.count
            }
        }
        else{
            let key: String = keys.objectAtIndex(section) as! String
            if let sectionContents: NSArray = self.contents.objectForKey(key) as? NSArray {
                return sectionContents.count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(searchCellId, forIndexPath: indexPath) as UITableViewCell
        var verse: Verse
        var key: String
        var sectionContents: NSArray
        if self.searchController.active {
            key = searchKeys.objectAtIndex(indexPath.section) as! String
            sectionContents = searchContents.objectForKey(key) as! NSArray
        }
        else{
            key = keys.objectAtIndex(indexPath.section) as! String
            sectionContents = contents.objectForKey(key) as! NSArray
        }
        
        verse = sectionContents.objectAtIndex(indexPath.row) as! Verse
        if $.searchOption == SearchOption.SearchOptionArabic {
            cell.textLabel?.text = verse.nonVocalArabicSearch
        }
        else if $.searchOption == SearchOption.SearchOptionTraslation {
            cell.textLabel?.text = verse.translationSearch
        }
        else if $.searchOption == SearchOption.SearchOptionTrasliteration {
            cell.textLabel?.text = verse.transcriptionSearch
        }
        if $.searchOption == SearchOption.SearchOptionArabic {
            if $.arabicFont == ArabicFontType.UseMEQuranicFont {
                cell.textLabel?.font = kMEArabicSearchFont
            }
            else if $.arabicFont == ArabicFontType.UsePDMSQuranicFont {
                cell.textLabel?.font = kPDMSArabicSearchFont
            }
            else{
                cell.textLabel?.font = kPDMSArabicSearchFont
            }
        }
        else{
            cell.textLabel?.font = kLatinSearchAndBookmarkFont
        }
        return cell
    }
    
    /*func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        if !self.searchController.active {
            let indeces: NSMutableArray = NSMutableArray(array: [])
            for i in 1...114 {
                indeces.addObject("\(i)")
            }
            return indeces as [AnyObject];
        }
        return nil;
    }*/
    
    // MARK:  UITableViewDelegate Metoverride hods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var sectionContents: NSArray
        var key: String
        var verse: Verse
        if self.searchController.active {
            key = searchKeys.objectAtIndex(indexPath.section) as! String
            sectionContents = searchContents.objectForKey(key) as! NSArray
        }
        else{
            key = keys.objectAtIndex(indexPath.section) as! String
            sectionContents = contents.objectForKey(key) as! NSArray
        }
        
        verse = sectionContents.objectAtIndex(indexPath.row) as! Verse
        
        var notDict = [String:NSObject]()
        notDict["verse"] = verse
        notDict["toggle"] = "right"
        
        if let text = searchController.searchBar.text {
            notDict["searchText"] = text
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kNewVerseSelectedNotification, object: nil,  userInfo:notDict as [NSObject : AnyObject])
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    // MARK: Notifications
    func searchOptionChangedHandler(notification: NSNotification){
        
    }
    
    // MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchQueue.cancelAllOperations()
    }
    
    // MARK: UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController){
        let searchText: String = searchController.searchBar.text!
        if searchText == "" {
            return
        }
        
        self.searchQueue.cancelAllOperations()
        
        //defines in which property will be searched
        var searchAttribute: String = "translationSearch" //default
        if $.searchOption == SearchOption.SearchOptionArabic {
            searchAttribute = "nonVocalArabicSearch"
        }
        else if $.searchOption == SearchOption.SearchOptionTrasliteration {
            searchAttribute = "transcriptionSearch"
        }
        
        //create the predicate format, the typed query should be
        //contained in the searchAttribute on the verse instance
        let predicateFormat: String = "%K contains[c] %@"
        let predicate: NSPredicate = NSPredicate(format: predicateFormat, searchAttribute, searchText)
        
        //grap a copy of the verses as a NSArray
        let verses = $.verses as NSArray
        
        //see: https://deeperdesign.wordpress.com/2011/05/30/cancellable-asynchronous-searching-with-uisearchdisplaycontroller/
        self.searchQueue.addOperationWithBlock { () -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                //apply the predicate to search for the verses containing the query
                let searchVesers:NSArray = verses.filteredArrayUsingPredicate(predicate) as NSArray
                if searchVesers.count == 0 {
                    self.view.makeToast(message: "No results".local, duration: 2, position: HRToastPositionTop)
                    self.searchContents = NSMutableDictionary()
                    self.searchKeys = NSMutableArray()
                }
                else{
                    //gets the hierarchical representation of the filtred versers
                    let tuple = self.service.sortedKeysAndContents(NSMutableArray(array: searchVesers))
                    self.searchContents = tuple.contents
                    self.searchKeys = tuple.keys
                    if let existToast = objc_getAssociatedObject(self.view, &HRToastView) as? UIView {
                        self.view.hideToast(toast: existToast, force: true)
                    }
                }
                self.tableView.reloadData()
                Flurry.logEvent(FlurryEvent.searchQuery, withParameters: ["value": searchText])
            }
        }
    }
}