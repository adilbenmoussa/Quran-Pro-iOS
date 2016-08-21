//
//  VersePlayOptionViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

let versePlayOptionCellId = "versePlayOptionCellId"
class VersePlayOptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var service: AudioService = AudioService.instance
    @IBOutlet var tableView: UITableView!
    
    //keep the reference to the options
    var options: Array<String>!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }

    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: versePlayOptionCellId)
        self.options = service.repeats.verses
        self.title = "Verse play options".local
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "repatCoutChangedHandler:", name:kRepatCountChangedNotification, object: nil)
    }
    
    func repatCoutChangedHandler (notification: NSNotification){
        self.tableView.reloadData()
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(versePlayOptionCellId, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.font = kCellTextLabelFont
        cell.textLabel?.text = options[indexPath.row]
        if isPro {
            if (service.repeats.verseCount == indexPath.row) || (service.repeats.verses.count-1 ==  indexPath.row && service.repeats.verseCount == -1){
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryType.None
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
            let index = indexPath.row == service.repeats.verses.count-1 ? -1 : indexPath.row
            service.repeats.verseCount = index
            $.setPersistentObjectForKey(index, key: kCurrentRepeatVerseKey)
            tableView.reloadData()
            Flurry.logEvent(FlurryEvent.versePlayOption, withParameters: ["value": index])
        }
        else if indexPath.row != 0 {
            self.askUserForPurchasingProVersion(FlurryEvent.versePlayOption)
        }
    }
}
