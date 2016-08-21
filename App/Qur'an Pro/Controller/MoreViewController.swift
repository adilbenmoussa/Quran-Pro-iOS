//
//  MoreViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit
import MessageUI

class MoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var goProButton: UIButton!
    
    var settings: NSDictionary!
    var keys: NSArray!
    var footerView: UILabel?

    
    var tellAFriendMail: MFMailComposeViewController?
    var contactUsdMail: MFMailComposeViewController?
    
    @IBAction func goProButtonTouched(sender: AnyObject) {
        self.askUserForPurchasingProVersion("BuyQuranProButton")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "More".local
        
        //load the table data
        createData()
        tableView.reloadData()
    }
    
    // override the blue section style defined n the extension
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isPro  {
            return nil
        }
        else {
            if section == 0 {
                let cellIdentifier = "ProSectionHeader"
                let headerView = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
                return headerView;
            }
            else{
                return nil
            }
        }
    }
    
    // MARK: intiate the data
    func createData (){
        
        //keys:
        let key1: String = "Actions".local
        let key2: String = "Settings".local
        let key3: String = "More".local
        
        // Settings
        let key1Content = [
            Setting(name: "Search".local, imageName: "search", type: SettingType.SettingTypeSearch),
            Setting(name: "Bookmarks".local, imageName: "bookmark", type: SettingType.SettingTypeBookmark),
            Setting(name: "Audio Downloads".local, imageName: "download_cloud_small", type: SettingType.SettingTypeAudioDownload)
        ]
        
        let key2Content = [
            Setting(name: "Select translation".local, imageName: "geography", type: SettingType.SettingTypeTranslation),
            Setting(name: "Select reciter".local, imageName: "recitator", type: SettingType.SettingTypeRecitator),
            Setting(name: "Search options".local, imageName: "search_setting", type: SettingType.SettingTypeSearchOption),
            Setting(name: "Verse play options".local, imageName: "ayah_play_option", type: SettingType.SettingTypeVersePlayOption),
            Setting(name: "Chapter play options".local, imageName: "surah_play_option", type: SettingType.SettingTypeChapterPlayOption),
            Setting(name: "Chapter view options".local, imageName: "surah_view_option", type: SettingType.SettingTypeChapterViewOption)
        ]
        let key3Content = [
            Setting(name: "Tell a friend".local, imageName: "tell_a_friend", type: SettingType.SettingTypeTellAFriend),
            Setting(name: "Write a review".local, imageName: "write_a_review", type: SettingType.SettingTypeAppReview),
            Setting(name: "Islamic apps".local, imageName: "islamic_apps", type: SettingType.SettingTypeIslamicApps),
            Setting(name: "Contact us".local, imageName: "contact_us", type: SettingType.SettingTypeContactUs)
        ]
        
        self.keys = isPro ? [key1, key2, key3] : ["_", key1, key2, key3]
        self.settings = isPro ? [key1: key1Content, key2: key2Content, key3: key3Content] : ["_": [], key1: key1Content, key2: key2Content, key3: key3Content]
    }
    
    // MARK: Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return keys.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (keys.objectAtIndex(section) as! String).local
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key: String = keys.objectAtIndex(section) as! String
        if let sectionSettings: NSArray = self.settings.objectForKey(key) as? NSArray {
            return sectionSettings.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let key: String = keys.objectAtIndex(indexPath.section) as! String
        let sectionSettings: NSArray = settings.objectForKey(key) as! NSArray
        let setting: Setting = sectionSettings.objectAtIndex(indexPath.row) as! Setting
        
        let cellIdentifier = "MoreCellIdentifier"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = setting.name
        cell.textLabel?.font = kCellTextLabelFont
        cell.imageView?.image = setting.icon
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let key: String = keys.objectAtIndex(indexPath.section) as! String
        let sectionSettings: NSArray = settings.objectForKey(key) as! NSArray
        let setting: Setting = sectionSettings.objectAtIndex(indexPath.row) as! Setting
        
        var viewController: UIViewController!;
        if setting.type == SettingType.SettingTypeBookmark {
            viewController = UIStoryboard.bookMarkViewController()
        }
        else if setting.type == SettingType.SettingTypeAudioDownload {
            viewController = UIStoryboard.downloadViewController()
        }
            //options
        else if setting.type == SettingType.SettingTypeSearchOption{
            viewController = UIStoryboard.searchOptionsViewController()
        }
            
        else if setting.type == SettingType.SettingTypeRecitator{
            viewController = UIStoryboard.recitersViewController()
        }
            
        else if setting.type == SettingType.SettingTypeVersePlayOption{
            viewController = UIStoryboard.versePlayOptionViewController()
        }
            
        else if setting.type == SettingType.SettingTypeChapterPlayOption{
            viewController = UIStoryboard.chapterPlayOptionViewController()
        }
            
        else if setting.type == SettingType.SettingTypeChapterViewOption{
            viewController = UIStoryboard.chapterViewOptionViewController()
        }

        else if setting.type == SettingType.SettingTypeSearch {
            viewController = UIStoryboard.searchViewController()
        }
        
        else if setting.type == SettingType.SettingTypeTranslation {
            viewController = UIStoryboard.translationViewController()
        }
        else if setting.type == SettingType.SettingTypeTellAFriend {
            tellAFriendMail = MFMailComposeViewController()
            tellAFriendMail!.mailComposeDelegate = self
            tellAFriendMail!.setSubject("Tell a friend subject".local)
            let message = "Tell a friend message".local
            tellAFriendMail!.setMessageBody(message.localizeWithFormat($.currentLanguageKey, kAppId), isHTML: true)
            self.presentViewController(tellAFriendMail!, animated: true, completion: nil)
        }
        else if setting.type == SettingType.SettingTypeContactUs {
            contactUsdMail = MFMailComposeViewController()
            contactUsdMail!.mailComposeDelegate = self
            contactUsdMail!.setSubject("Contact us".local)
            contactUsdMail!.setToRecipients([kDevEmail])
            self.presentViewController(contactUsdMail!, animated: true, completion: nil)
        }
        else if setting.type == SettingType.SettingTypeAppReview {
            Flurry.logEvent(FlurryEvent.writeAReview)
            let appUrl = kReviewUrl.localizeWithFormat(kAppId)
            UIApplication.sharedApplication().openURL(NSURL(string: appUrl)!)
        }
        else if setting.type == SettingType.SettingTypeIslamicApps {
            Flurry.logEvent(FlurryEvent.islamicApps)
            UIApplication.sharedApplication().openURL(NSURL(string: kMoreAppsUrl)!)
        }

        if viewController != nil {
            self.navigationContoller().pushViewController(viewController, animated: true)
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    
    func navigationContoller() -> UINavigationController {
        return self.parentViewController as! UINavigationController
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let key: String = keys.objectAtIndex(section) as! String
        let current = keys[keys.count - 1] as! String
        if current as String == key {
            if footerView == nil {
                 footerView = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
            }
  
            let appName = kApplicationDisplayName
            let dev = "by @adilbenmoussa".local
            footerView!.text = "\(appName) - v\(kApplicationVersion) \n \(dev)"
            footerView!.lineBreakMode = .ByWordWrapping
            footerView!.numberOfLines = 0
            footerView!.textAlignment = NSTextAlignment.Center
            footerView!.font = kMoreTableFooterFont
            footerView!.textColor = UIColor.blackColor()
            return footerView
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let key: String = keys.objectAtIndex(section) as! String
        let current = keys[keys.count - 1] as! String
        if current as String == key {
            return 60.0
        }
        //use the default one
        return 0
    }
    
    
    //MARK: MFMailComposeViewController delegate
    func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        if  controller == tellAFriendMail {
            switch result.rawValue {
            case MFMailComposeResultCancelled.rawValue:
                Flurry.logEvent(FlurryEvent.tellAfriendMailCancelled)
            case MFMailComposeResultSaved.rawValue:
                Flurry.logEvent(FlurryEvent.tellAfriendSaved)
            case MFMailComposeResultSent.rawValue:
                Flurry.logEvent(FlurryEvent.tellAfriendMailSent)
            case MFMailComposeResultFailed.rawValue:
                Flurry.logError(FlurryEvent.tellAfriendMailFaild, message: error!.localizedDescription, error: error)
            default:
                break
            }
        }
        self.dismissViewControllerAnimated(false, completion: nil)
    }

}
