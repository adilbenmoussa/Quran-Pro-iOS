//
//  RecitersViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

let recitersCellId = "recitersCellId"
class RecitersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    //keep the reference to the options
    var options: Array<Reciter>!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: recitersCellId)
        self.options = $.reciters
        self.title = "Select reciter".local
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reciter: Reciter = options[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(recitersCellId, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.font = kCellTextLabelFont
        cell.textLabel?.text = reciter.name
        if isPro {
            if reciter == $.currentReciter {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        else {
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
            let reciter: Reciter = options[indexPath.row]
            $.currentReciter = reciter
            $.setPersistentObjectForKey(indexPath.row, key: kCurrentReciterKey)
            tableView.reloadData()
            NSNotificationCenter.defaultCenter().postNotificationName(kReciterChangedNotification, object: nil,  userInfo: nil)
            Flurry.logEvent(FlurryEvent.reciterSelected, withParameters: ["value": $.currentReciter.name])
        }
        else if indexPath.row != 0 {
            self.askUserForPurchasingProVersion(FlurryEvent.reciterSelected)
        }
    }
}