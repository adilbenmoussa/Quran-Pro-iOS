//
//  TranslationViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

let translationCellId = "translationCellId"

class TranslationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: translationCellId)
        self.title = "Select translation".local
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return $.translations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(translationCellId, forIndexPath: indexPath) as UITableViewCell
        let translation = $.translations[indexPath.row]
        cell.textLabel?.font = kCellTextLabelFont
        cell.textLabel?.text = translation.name
        cell.imageView?.image = translation.icon
        if isPro {
            if ($.currentLanguageKey == translation.id){
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        else{
            if $.currentLanguageKey == translation.id {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.unlock()
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
        let translation = $.translations[indexPath.row]
        if isPro {
            $.currentLanguageKey = translation.id
            $.setPersistentObjectForKey(translation.id, key: kCurrentTranslationKey)
            tableView.reloadData()
            $.updateContent()
            Flurry.logEvent(FlurryEvent.translationSelected, withParameters: ["name": translation.name])
        }
        else if $.currentLanguageKey != translation.id {
            self.askUserForPurchasingProVersion(FlurryEvent.translationSelected)
        }
    }
}
