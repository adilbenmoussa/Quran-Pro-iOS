//
//  ChapterPlayOptionViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

let chapterPlayOptionCellId = "chapterPlayOptionCellId"
class ChapterPlayOptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
 
    var service: AudioService = AudioService.instance
    @IBOutlet var tableView: UITableView!
    
    //keep the reference to the options
    var options: Array<String>!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: chapterPlayOptionCellId)
        self.options = service.repeats.chapters
        self.title = "Chapter play options".local
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(chapterPlayOptionCellId, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.font = kCellTextLabelFont
        cell.textLabel?.text = options[indexPath.row]
        if isPro {
            if service.repeats.chapterCount == indexPath.row {
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
            service.repeats.chapterCount = indexPath.row
            $.setPersistentObjectForKey(indexPath.row, key: kCurrentRepeatChapterhKey)
            tableView.reloadData()
            Flurry.logEvent(FlurryEvent.chapterPlayOption, withParameters: ["value": indexPath.row])
        }
        else if indexPath.row != 0 {
            self.askUserForPurchasingProVersion(FlurryEvent.chapterPlayOption)
        }
    }
}
