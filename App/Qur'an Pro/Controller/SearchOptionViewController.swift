//
//  SearchOptionViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit
let searchOptionCellId = "SearchOptionCell"
class SearchOptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    //keep the reference to the options
    var options: Array<String>!
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: searchOptionCellId)
        self.options = ["Search in translation".local, "Search in Arabic".local, "Search in transliteration".local]
        self.title = "Search options".local
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(searchOptionCellId, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.font = kCellTextLabelFont
        cell.textLabel?.text = options[indexPath.row]
        if isPro {
            if indexPath.row != $.searchOption.rawValue {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
        }
        else{
            if indexPath.row == 0 {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
            else{
                cell.lock()
            }
        }
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if isPro {
            $.searchOption = SearchOption(rawValue: indexPath.row)!
            $.setPersistentObjectForKey(indexPath.row, key: kCurrentSearchOptionKey)
            tableView.reloadData()
            NSNotificationCenter.defaultCenter().postNotificationName(kSearchOptionChangedNotification, object: nil,  userInfo: nil)
            Flurry.logEvent(FlurryEvent.searchOption, withParameters: ["value": $.searchOption.rawValue])
        }
        else if indexPath.row != 0 {
            self.askUserForPurchasingProVersion(FlurryEvent.searchOption)
        }
    }
}