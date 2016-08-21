//
//  FlurryEvent.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

class FlurryEvent {
    
    //init
    static let appStarted: String = "AppStarted"
    
    //chapter
    static let toggleChapterPanel: String = "ToggleChapterPanel"
    static let chapterSelected: String = "ChapterSelected"
    static let sestionSelected: String = "SectionSelected"
    static let verseViaSectionSelected: String = "VerseViaSectionSelected"
    
    //more
    static let toggleMorePanel: String = "ToggleMorePanel"
    
    //download
    static let downloadFromChapter: String = "DownloadFromChapter"
    static let downloadFromRow: String = "DownloadFromRow"
    static let downloadFrom3G: String = "DownloadFrom3G"
    static let downloadNoConnection: String = "DownloadNoConnection"
    static let downloadAll: String = "DownloadAll"
    static let removeAllDownloads: String = "RemoveAllDownloads"
    static let removeDownload: String = "RemoveDownload"
    static let stopDownload: String = "StopDownload"
    static let stopAllDownloads: String = "StopAllDownloads"
    static let pauseDownload: String = "PauseDownload"
    static let pauseAllDownloads: String = "PauseAllDownloads"
    static let downloadError: String = "DownloadError"
    static let downloadDead: String = "DownloadDead"
    
    //search
    static let searchOption: String = "SearchOption"
    static let searchQuery: String = "SearchQuery"
    
    //bookmark
    static let totalBookmarks: String = "TotalBookmarks"
    static let removeAllBookmarks: String = "RemoveAllBookmarks"
    static let addBookmark: String = "AddBookmark"
    static let removeBookmark: String = "RemoveBookmark"
    static let copy: String = "copy"
    
    //reciter
    static let reciterSelected: String = "ReciterSelected"
    
    //verse play options
    static let versePlayOption: String = "VersePlayOption"
    
    //chapter play option
    static let chapterPlayOption: String = "ChapterPlayOption"
    
    //chapter view option
    static let chapterViewOption: String = "ChapterViewOption"
    
    //audio player
    static let playerLoadFile: String = "PlayerLoadFile"
    static let playerAudioFromRow: String = "PlayerAudioFromRow"
    static let stopPlayingAudioFromRow: String = "StopPlayingAudioFromRow"
    
    //translation
    static let translationSelected: String = "TranslationSelected"
    static let removeTranslation: String = "RemoveTranslation"
    
    //audio session
    static let enableAudioSession: String = "EnableAudioSession"
    
    //Tell a friend
    static let tellAfriendMailCancelled: String = "TellAfriendMailCancelled"
    static let tellAfriendSaved: String = "TellAfriendMailSaved"
    static let tellAfriendMailSent: String = "TellAfriendMailSent"
    static let tellAfriendMailFaild: String = "TellAfriendMailFaild"
    
    static let appiraterDidOptToMail: String = "appiraterDidOptToMail"
    static let appiraterDidDeclineToRate: String = "appiraterDidDeclineToRate"
    static let appiraterDidOptToRate: String = "appiraterDidOptToRate"
    static let appiraterDidOptToRemindLater: String = "appiraterDidOptToRemindLater"
    
    
    //write a review
    static let writeAReview: String = "WriteAReviewSelected"
    
    //islamic apps selected
    static let islamicApps: String = "islamicAppsSelected"
    
    //social
    static let share: String = "Share"
    static let sharedViaFacebookCancelled: String = "SharedViaFacebookCancelled"
    static let sharedViaFacebookDone: String = "SharedViaFacebookDone"
    static let sharedViaTwitterCancelled: String = "SharedViaTwitterCancelled"
    static let sharedViaTwitterDone: String = "SharedViaTwitterDone"
    static let purchase: String = "Purchase"
    
    static func logPurchase(key: String) {
        Flurry.logEvent("\(FlurryEvent.purchase)_\(key)")
    }
    
}