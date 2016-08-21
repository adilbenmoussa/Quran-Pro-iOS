////
////  MigrationService.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//////  Qur'an Pro
////
////  Created by A Ben Moussa on 3/12/15.
////  Copyright (c) 2015 Islamhome.info. All rights reserved.
////
//
//import Foundation
//
//class MigrationService {
//    
//    class func run(dataService: DataService) {
//        func isLanguageAvailable(langKey: String) -> Bool{
//            for translation in dataService.translations {
//                if translation.id == langKey {
//                    return true
//                }
//            }
//            return false
//        }
//        let languageKey: String = NSUserDefaults.currentLanguageKey()
//        let emtyList: NSMutableArray = emptyDownloadList()
//        let downloads: NSMutableDictionary = ["reciter0": emtyList, /*Husary*/
//        "reciter1": emtyList, /*Afasy*/
//        "reciter2": emtyList, /*Shatri*/
//        "reciter3": emtyList, /*Basit*/
//        "reciter4": emtyList] /*Ghamdi*/
//        var userSettings:NSMutableDictionary? = NSBundle.readDictionaryPlistFromDocumentFolder(kUserSettingsFile)
//        
//        if userSettings == nil {
//            if kIsSingleLanguage {
//                dataService.currentLanguageKey = kAppLanguage
//            }
//            else{
//                if (isLanguageAvailable(languageKey)) {
//                    dataService.currentLanguageKey = languageKey
//                }
//                else{
//                    dataService.currentLanguageKey = kAppLanguage
//                }
//            }
//            
//            // create a temp file applicationVersion
//            userSettings = [kApplicationVersionKey: kApplicationVersion,
//                kUserLanguageKey: dataService.currentLanguageKey,
//                kCurrentReciterKey: 0,
//                kCurrentRepeatVerseKey: 0,
//                kCurrentRepeatChapterhKey: 0,
//                kDownloadsKey: downloads]
//            
//            //write down the files into the document folder
//            NSBundle.writeDictionaryPlistToDocumentFolder(filename: kUserSettingsFile, dictionary: userSettings!)
//        }
//        else{
//            if let savedApplicationVersion:Double = (userSettings?.objectForKey(kApplicationVersionKey) as? NSString)?.doubleValue {
//                if savedApplicationVersion < kApplicationVersion.doubleValue {
//                    
//                    ///Update the user settings for
//                    // the vessions lower or equal then 2.0
//                    if savedApplicationVersion <= 2.0 {
//                        userSettings?.setObject(downloads, forKey: kDownloadsKey)
//                        userSettings?.setObject(0, forKey: kCurrentReciterKey)
//                        userSettings?.setObject(0, forKey: kCurrentRepeatVerseKey)
//                        userSettings?.setObject(0, forKey: kCurrentRepeatChapterhKey)
//                    }
//                    userSettings?.setObject(kApplicationVersion, forKey: kApplicationVersionKey)
//                    //update the user setting in the document folder
//                    NSBundle.writeDictionaryPlistToDocumentFolder(filename: kUserSettingsFile, dictionary: userSettings!)
//                }
//            }
//            
//            if kIsSingleLanguage {
//                dataService.currentLanguageKey = kAppLanguage
//            }
//            else{
//                dataService.currentLanguageKey = userSettings?.objectForKey(kUserLanguageKey) as? String
//            }
//            if let index: Int = userSettings?.objectForKey(kCurrentReciterKey) as? Int {
//                dataService.currentReciter = dataService.reciters[index]
//            }
//            else{
//                dataService.currentReciter = dataService.reciters[0]
//            }
//        }
//        
//        //fix for update bug for the version 2.6 caused by the currentLanguage
//        if dataService.currentLanguageKey != nil || dataService.currentLanguageKey == ""  || dataService.currentLanguageKey == "ul" {
//            if (isLanguageAvailable(languageKey)) {
//                dataService.currentLanguageKey = languageKey
//            }
//            else{
//                dataService.currentLanguageKey = kAppLanguage
//            }
//            
//            userSettings?.setObject(dataService.currentLanguageKey, forKey: kUserLanguageKey)
//            //update the user setting in the document folder
//            NSBundle.writeDictionaryPlistToDocumentFolder(filename: kUserSettingsFile, dictionary: userSettings!)
//        }
//        
//        // @Since v2.8
//        // Add new reciteurs
//        if var downloadsExt: NSMutableDictionary = userSettings?.objectForKey(kDownloadsKey) as? NSMutableDictionary {
//            if downloadsExt.count  <= downloads.count {
//                // add the new items
//                downloadsExt.setObject(emtyList, forKey:"reciter5");//As-Sudais
//                downloadsExt.setObject(emtyList, forKey:"reciter6");//Bukhatir
//                downloadsExt.setObject(emtyList, forKey:"reciter7");//Al-Muaiqly
//                downloadsExt.setObject(emtyList, forKey:"reciter8");//Al-Hudaify
//                
//                userSettings?.setObject(downloadsExt , forKey: kDownloadsKey)
//                //update the user setting in the document folder
//                NSBundle.writeDictionaryPlistToDocumentFolder(filename: kUserSettingsFile, dictionary: userSettings!)
//            }
//        }
//        
//        // @Since v2.8
//        // Add the option to show/hide the traslations and transliteration
//        // Add the font level as well
//        // Add Search options
//        var saveSetting: Bool = false
//        
//        // Translation
//        if userSettings?.objectForKey(kShowTranslationKey) == nil {
//            userSettings?.setObject(1, forKey: kShowTranslationKey)
//            saveSetting = true
//        }
//        // Translatiration
//        if userSettings?.objectForKey(kShowTransliterationKey) == nil {
//            userSettings?.setObject(1, forKey: kShowTransliterationKey)
//            saveSetting = true
//        }
//        
//        // Font level
//        if userSettings?.objectForKey(kCurrentFontLevelKey) == nil {
//            userSettings?.setObject(0, forKey: kCurrentFontLevelKey)
//            saveSetting = true
//        }
//        
//        // Search option
//        if userSettings?.objectForKey(kCurrentSearchOptionKey) == nil {
//            userSettings?.setObject(0, forKey: kCurrentSearchOptionKey)
//            saveSetting = true
//        }
//        
//        if saveSetting {
//            //update the user setting in the document folder
//            NSBundle.writeDictionaryPlistToDocumentFolder(filename: kUserSettingsFile, dictionary: userSettings!)
//        }
//        
//        // @Since v4.0
//        if kApplicationVersion.doubleValue == 4.0 {
//            // Remove the download folder since is not needed
//            userSettings?.removeObjectForKey(kDownloadsKey)
//            //update the user setting in the document folder
//            NSBundle.writeDictionaryPlistToDocumentFolder(filename: kUserSettingsFile, dictionary: userSettings!)
//        }
//    }
//    
//    
//    class func emptyDownloadList () -> NSMutableArray {
//        var out: NSMutableArray = NSMutableArray()
//        for i in 0...113 {
//            out.addObject(0)
//        }
//        return out
//    }
//}
