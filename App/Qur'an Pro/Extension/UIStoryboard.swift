//
//  UIStoryboard.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation
import UIKit

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }
    
    class func moreViewController() -> MoreViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MoreViewController") as? MoreViewController
    }
    
    class func chaptersViewController() -> ChaptersViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ChaptersViewController") as? ChaptersViewController
    }
    
    class func centerViewController() -> CenterViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CenterViewController") as? CenterViewController
    }
    
    class func downloadViewController() -> DownloadViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("DownloadViewController") as? DownloadViewController
    }
    
    class func bookMarkViewController() -> BookmarkViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("BookmarkViewController") as? BookmarkViewController
    }
    
    class func searchViewController() -> SearchViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SearchViewController") as? SearchViewController
    }
    
    class func searchOptionsViewController() -> SearchOptionViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SearchOptionViewController") as? SearchOptionViewController
    }

    class func recitersViewController() -> RecitersViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("RecitersViewController") as? RecitersViewController
    }
    
    class func versePlayOptionViewController() -> VersePlayOptionViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("VersePlayOptionViewController") as? VersePlayOptionViewController
    }

    class func chapterPlayOptionViewController() -> ChapterPlayOptionViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ChapterPlayOptionViewController") as? ChapterPlayOptionViewController
    }

    class func chapterViewOptionViewController() -> ChapterViewOptionViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ChapterViewOptionViewController") as? ChapterViewOptionViewController
    }
    class func translationViewController() -> TranslationViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("TranslationViewController") as? TranslationViewController
    }
    
    class func winPageContentViewController() -> WINPageContentViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("WINPageContentViewController") as? WINPageContentViewController
    }
    
    
}