//
//  ChapterViewOptionViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

let chapterViewOptionCellId = "chapterViewOptionCellId"
class VerseViewClass {
    var name: String!
    var type:VerseViewType!
    var value: Int!
    init(name: String, type: VerseViewType, value: Int){
        self.name = name
        self.type = type
        self.value = value
        
    }
}

class ArabicFont {
    var name: String!
    var type:ArabicFontType!
    init(name: String, type: ArabicFontType){
        self.name = name
        self.type = type
    }
}

class FontSizeClass {
    var name: String!
    var type:FontSizeType!
    init(name: String, type: FontSizeType){
        self.name = name
        self.type = type
    }
}

class ChapterViewOptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    
    var contents: NSMutableDictionary!
    var keys: NSArray!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Chapter view options".local
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: chapterViewOptionCellId)
        //load the table data
        createData()
        tableView.reloadData()
    }

    
    // MARK: intiate the data
    func createData (){
        
        //keys:
        let key1: String = "Verse view".local
        let key2: String = "Arabic font".local
        let key3: String = "Font size".local
        
        // Settings
        let key1Content = [
            VerseViewClass(name: "No Translation".local, type: VerseViewType.NoTranslation, value: $.showTranslation ? 0 : 1),
            VerseViewClass(name: "No Transliteration".local, type: VerseViewType.NoTransliteration, value: $.showTransliteration ? 0 : 1)
        ]
        
        let key2Content = [
            ArabicFont(name: "Use ME Quranic font".local, type: ArabicFontType.UseMEQuranicFont),
            ArabicFont(name: "Use PDMS Quranic font".local, type: ArabicFontType.UsePDMSQuranicFont),
            ArabicFont(name: "Use Normal Arabic font".local, type: ArabicFontType.UseNormalArabicFont)
        ]
        
        let key3Content = [
            FontSizeClass(name: "Medium".local, type: FontSizeType.Medium),
            FontSizeClass(name: "Large".local, type: FontSizeType.Large),
            FontSizeClass(name: "Extra Large".local, type: FontSizeType.ExtraLarge)
        ]
        
        self.keys = [key1, key2, key3]
        self.contents = [key1: key1Content, key2: key2Content, key3: key3Content]
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
        if let sectionContents: NSArray = self.contents.objectForKey(key) as? NSArray {
            return sectionContents.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let key: String = keys.objectAtIndex(indexPath.section) as! String
        let sectionContents: NSArray = contents.objectForKey(key) as! NSArray
        
        let cell = tableView.dequeueReusableCellWithIdentifier(chapterViewOptionCellId, forIndexPath: indexPath) as UITableViewCell
        if let verseView: VerseViewClass = sectionContents.objectAtIndex(indexPath.row) as? VerseViewClass {
            if verseView.type == VerseViewType.NoTranslation {
                cell.accessoryType = $.showTranslation ? UITableViewCellAccessoryType.None :  UITableViewCellAccessoryType.Checkmark
            }
            else if verseView.type == VerseViewType.NoTransliteration {
                cell.accessoryType = $.showTransliteration ? UITableViewCellAccessoryType.None :  UITableViewCellAccessoryType.Checkmark
            }
            cell.textLabel?.text = verseView.name
        }
        else if let arabicFont: ArabicFont = sectionContents.objectAtIndex(indexPath.row) as? ArabicFont {
            //cell.accessoryType = $.useQuranicFont ? UITableViewCellAccessoryType.Checkmark :  UITableViewCellAccessoryType.None
            if arabicFont.type == ArabicFontType.UseMEQuranicFont {
                cell.accessoryType = $.arabicFont == ArabicFontType.UseMEQuranicFont ? UITableViewCellAccessoryType.Checkmark :  UITableViewCellAccessoryType.None
                cell.textLabel?.font = kMEArabicSearchFont
            }
            else if arabicFont.type == ArabicFontType.UsePDMSQuranicFont {
                cell.accessoryType = $.arabicFont == ArabicFontType.UsePDMSQuranicFont ? UITableViewCellAccessoryType.Checkmark :  UITableViewCellAccessoryType.None
                cell.textLabel?.font = kPDMSArabicSearchFont
            }
            else if arabicFont.type == ArabicFontType.UseNormalArabicFont {
                cell.accessoryType = $.arabicFont == ArabicFontType.UseNormalArabicFont ? UITableViewCellAccessoryType.Checkmark :  UITableViewCellAccessoryType.None
                cell.textLabel?.font = kLatinFont
            }
            cell.textLabel?.text = arabicFont.name
        }
        else if let fontSize: FontSizeClass = sectionContents.objectAtIndex(indexPath.row) as? FontSizeClass {
            if fontSize.type == FontSizeType.Medium {
                cell.accessoryType = $.fontLevel == FontSizeType.Medium ? UITableViewCellAccessoryType.Checkmark :  UITableViewCellAccessoryType.None
                cell.textLabel?.font = kLatinFont
            }
            else if fontSize.type == FontSizeType.Large {
                cell.accessoryType = $.fontLevel == FontSizeType.Large ? UITableViewCellAccessoryType.Checkmark :  UITableViewCellAccessoryType.None
                cell.textLabel?.font = kLatinFontLarge
            }
            else if fontSize.type == FontSizeType.ExtraLarge {
                cell.accessoryType = $.fontLevel == FontSizeType.ExtraLarge ? UITableViewCellAccessoryType.Checkmark :  UITableViewCellAccessoryType.None
                cell.textLabel?.font = kLatinFontExtraLarge
            }
            cell.textLabel?.text = fontSize.name
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let key: String = keys.objectAtIndex(indexPath.section) as! String
        let sectionContents: NSArray = contents.objectForKey(key) as! NSArray
        var keyToSet: String!
        var value: AnyObject!
        if let verseView: VerseViewClass = sectionContents.objectAtIndex(indexPath.row) as? VerseViewClass {
            if verseView.type == VerseViewType.NoTranslation {
                $.showTranslation = !$.showTranslation
                keyToSet = kShowTranslationKey
                value = $.showTranslation  ? 1 : 0
            }
            else if verseView.type == VerseViewType.NoTransliteration{
                $.showTransliteration = !$.showTransliteration
                keyToSet = kShowTransliterationKey
                value = $.showTransliteration ? 1 : 0
            }
        }
        else if let arabicFont: ArabicFont = sectionContents.objectAtIndex(indexPath.row) as? ArabicFont {
            $.arabicFont = arabicFont.type
            keyToSet = kCurrentArabicFontKey
            value = arabicFont.type.rawValue
        }
            
        else if let fontSize: FontSizeClass = sectionContents.objectAtIndex(indexPath.row) as? FontSizeClass {
            $.fontLevel = fontSize.type
            keyToSet = kCurrentFontLevelKey
            value = fontSize.type.rawValue
        }

        $.setPersistentObjectForKey(value, key: keyToSet)
        tableView.reloadData()
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
                NSNotificationCenter.defaultCenter().postNotificationName(kViewChangedNotification, object: nil,  userInfo: nil)
        Flurry.logEvent(FlurryEvent.chapterViewOption, withParameters: ["key": keyToSet, "value": value])
    }
}
