//
//  Config.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation
import UIKit

//Other Swift Macro Flag
//#if PRO
let isPro = true
//#else
//let isPro = false
//#endif

let isDebug: Bool = NSProcessInfo.processInfo().environment["DEBUG"] != nil
let isIpad: Bool = UIDevice.currentDevice().userInterfaceIdiom == .Pad
let isPortrait: Bool = UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait || UIDevice.currentDevice().orientation == UIDeviceOrientation.PortraitUpsideDown

//Constants
let kQuranProId = "994829561"
let kQuranLiteId = "1071463644"
let kQuranLiteName = "Qur'an Lite"
let kAppDefaultLanguage: String = "en"
let kApplicationDisplayName: NSString = isPro ? (NSBundle.mainBundle().localizedInfoDictionary?["CFBundleLargeDisplayName"] as? NSString)! : kQuranLiteName
let kApplicationVersion: NSString = (NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? NSString)!
let kApplicationName: NSString = (NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? NSString)!
let kAppId: String = isPro ? kQuranProId : kQuranLiteId
let kDevEmail: String  = "adil.benmoussa@gmail.com"

let kReviewUrl: String = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&type=Purple+Software&mt=8"
let kMoreAppsUrl: String = "itms-apps://itunes.com/apps/adilbenmoussa"
let kAppUrlTemplate: String = "http://itunes.apple.com/%@/app/id%@"
let kAppUrl: String = "itms-apps://itunes.apple.com/app/id%@"
let kDownloadMirrorUrl: String = "http://benmoussa.bitbucket.org/reciters/reciters.plist"
let kShortenAppUrl = isPro ? "http://apple.co/1dil0we" : "http://apple.co/1Ot9k5f"


//API's
let kFlurryAPIKey: String = isPro ? "123456789" : "123456789" // change this to your keys
let kParseAppId: String = isPro ? "123456789" : "123456789" // change this to your keys
let kParseClientKey: String = isPro ? "123456789": "123456789" // change this to your keys

//The width value in points, of the center view controller that will be left visible once it has animated offscreen.
//let kCenterPanelExpandedOffset: CGFloat = isIpad ? UIScreen.mainScreen().bounds.size.width - 360 : 60
let kCenterPanelExpandedOffset: CGFloat = 60

//Constants
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
let kFatihaIndex: Int = 0
let kTaubahIndex: Int = 8
let kBasmallah: String = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"
let kSpecialReciterFolderFormatIds = [5, 6, 7, 8]

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//Style
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//App
let kAppColor: UIColor = UIColor(red: 0.588, green: 0.706, blue: 0.398, alpha: 1)
let kImageWaterMarkColor = UIColor(red: 0.588, green: 0.706, blue: 0.398, alpha: 1)
let kImageWaterMarkFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!

//NavigationBar
let kUINavigationBarTintColor: UIColor = UIColor.whiteColor()
let kUINavigationBarBackgroundImage: String = "nav_bgc"
let kUINavigationBarTitleFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 22.0)!
let kUINavigationBarTitleColor: UIColor = UIColor(red: 245, green: 245, blue: 245)
let kUINavigationBarTitleShadowSize: CGSize = CGSize(width: 0, height: 1)

//Section
let kSectionBackgrondColor = UIColor(red: 0.588, green: 0.706, blue: 0.398, alpha: 0.9)
let kSectionBackgrondFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 16.0)!

//More table
let kMoreTableFooterFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 18.0)!

//Button spacing
let kUIBarButtonItemUIEdgeInsetsRight: CGFloat = -30
let kUIBarButtonItemUIEdgeInsetsAudioRight: CGFloat = -40

//StatusBar
let kUIStatusBarStyle: UIStatusBarStyle = UIStatusBarStyle.LightContent //White status bar

//Categories & Settings Table
let kCellTextLabelFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 20.0)!
let kCellTextLabelColor: UIColor = UIColor(red: 101, green: 112, blue: 122)
let kEmptyCategoryIcon = "empty-category.png"

//Categories Table
let kHeightForRowAtIndexPath: CGFloat = 60.0 //the cell height
let kSelectedCellBackgroudColor: UIColor = UIColor(red: 244, green: 244, blue: 244)

//Settings Table
let kSettingTableBackgroundImage: String = "SettingTableBackgroundImage.png"
let kSettingSwitchOnTintColor: UIColor = UIColor(red: 81, green: 196, blue: 212)

//Verse Table
let kArabicFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 26.0)!
let kArabicFontLarge: UIFont = UIFont(name: "HelveticaNeue-Light", size: 28.0)!
let kArabicFontExtraLarge: UIFont = UIFont(name: "HelveticaNeue-Light", size: 30.0)!

//Font names
let me_quran: (String, String) = ("me_quran", "ME Quran Font") //0= font name, 1= display name
let pdms_quran: (String, String) = ("_PDMS_Saleem_QuranFont", "PDMS Quran Font") //0= font name, 1= display name

let kMEQuranicArabicFont: UIFont = UIFont(name: me_quran.0, size: 24.0)!
let kMEQuranicArabicFontLarge: UIFont = UIFont(name: me_quran.0, size: 26.0)!
let kMEQuranicArabicFontExtraLarge: UIFont = UIFont(name: me_quran.0, size: 28.0)!

let kPDMSQuranicArabicFont: UIFont = UIFont(name: pdms_quran.0, size: 28.0)!
let kPDMSQuranicArabicFontLarge: UIFont = UIFont(name: pdms_quran.0, size: 30.0)!
let kPDMSQuranicArabicFontExtraLarge: UIFont = UIFont(name: pdms_quran.0, size: 32.0)!


let kLatinFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 20.0)!
let kLatinFontLarge: UIFont = UIFont(name: "HelveticaNeue-Light", size: 22.0)!
let kLatinFontExtraLarge: UIFont = UIFont(name: "HelveticaNeue-Light", size: 24.0)!
let kLatinSearchAndBookmarkFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 16.0)!
let kMEArabicSearchFont: UIFont = UIFont(name: me_quran.0, size: 16.0)!
let kPDMSArabicSearchFont: UIFont = UIFont(name: pdms_quran.0, size: 20.0)!
let kHizbTableCellColor: UIColor = UIColor(red: 234, green: 231, blue: 179)
let kVerseCellyOddColor: UIColor = UIColor(red: 243, green: 251, blue: 229)
let kVerseCellyEvenColor: UIColor = UIColor(red: 247, green: 250, blue: 250)

//Download Table
let kDownloadFont: UIFont = isIpad ? UIFont(name: "HelveticaNeue-Light", size: 14.0)! : UIFont(name: "HelveticaNeue-Light", size: 12.0)!
let kPercentageFont: UIFont = isIpad ? UIFont(name: "HelveticaNeue-Light", size: 16.0)! : UIFont(name: "HelveticaNeue-Light", size: 14.0)!
let kDownloadedFont: UIFont = isIpad ? UIFont(name: "HelveticaNeue-Bold", size: 14.0)! : UIFont(name: "HelveticaNeue-Bold", size: 12.0)!


//File names
let kBookmarkFile: String = "favorites"
let kMediaFile: String = "media.plist"
let kAppsFile:String = "apps.plist"
let kRecitersFile:String = "reciters"
let kArabicFile:String = "arabic"
let kArabic2File:String = "arabic2"
let kTranscriptionFile:String = "transcription"
let kUserSettingsFile:String = "userSettings"
let kTranslationsFile:String = "translations"



//Key setting contstants
let kCurrentReciterKey: String = "currentReciter"
let kDownloadsKey: String = "downloads"
let kApplicationVersionKey: String = "applicationVersion"
let kCurrentRepeatVerseKey: String = "currentRepeatAya"
let kCurrentRepeatChapterhKey: String = "currentRepeatSurah"
let kCurrentChapterKey: String = "currentChapter"
let kCurrentSearchOptionKey: String = "currentSearchOption"
let kShowTranslationKey: String = "showTranslation"
let kShowTransliterationKey: String = "showTransliteration"
let kCurrentFontLevelKey: String = "currentFontLevel"
let kCurrentTranslationKey: String = "currentTranslationKey"
let kCurrentArabicFontKey: String = "currentArabicFontKey"
let kGrouViewTypeKey: String = "groupViewTypeKey"

//deprecated from v1.3
let kUseQuranicFontKey: String = "useQuranicFontKey"


//Bookmark keys
let kChapterhId = "surahId"
let kVerseId = "ayaId"


let kWhatIsNew1dot2 = "whatIsNew1dot2"
let kWhatIsNew1dot3 = "whatIsNew1dot3"
let kWhatIsNew1dot4 = "whatIsNew1dot4__"
let kWhatIsNewLite1dot0 = "whatIsNewLite1dot0"


//Notifications
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Audio
let kProgressUpdatedNotification: String = "ProgressUpdatedNotification"
let kDownloadCompleteNotification: String = "DownloadCompleteNotification"
let kDownloadStartedNotification: String = "DownloadStartedNotification"
let kDownloadErrorNotification: String = "DownloadErrorNotification"
let kDownloadDeadNotification: String = "DownloadDeadNotification"
let kDownloadCancelNotification: String = "DownloadCancelNotification"
let kDownloadCancelAllNotification: String = "DownloadCancelAllNotification"
let kAudioRemovedNotification: String = "AudioRemovedNotification"
let kAllAudiosRemovedNotification: String = "AllAudiosRemovedNotification"
let kBeginReceivingRemoteControlEvents: String = "BeginReceivingRemoteControlEvents"
let kExitWhatIsNewVCNotification: String = "ExitWhatIsNewVCNotification"

//Chapter selection
let kNewChapterSelectedNotification: String = "NewChapterSelectedNotification"

//Verse selection
let kNewVerseSelectedNotification: String = "NewVerseSelectedNotification"

//Bookmark
let kBookmarkChangedNotification: String = "BookmarkChangedNotification"
let kBookmarksRemovedNotification: String = "BookmarksRemovedNotification"

//Search
let kSearchOptionChangedNotification: String = "SearchOptionChangedNotification"

//Reciter
let kReciterChangedNotification: String = "ReciterChangedNotification"

//Chapter view changes
let kChapterViewOptionChangedNotification: String = "ChapterViewOptionChangedNotification"

//Translation changes
let kTranslationChangedNotification: String = "TranslationChangedNotification"

//View option changes
let kViewChangedNotification: String = "ViewChangedNotification"

//Repeat count changed
let kRepatCountChangedNotification: String = "RepatCountChangedNotification"

//let kOpenSKControllerNotification: String = "OpenSKControllerNotification"

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


