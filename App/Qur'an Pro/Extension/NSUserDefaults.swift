//
//  NSUserDefaults.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

extension NSUserDefaults {

    class func currentLanguageKey() -> String! {
        let dirs: NSArray! = NSUserDefaults.standardUserDefaults().objectForKey("AppleLanguages") as! NSArray
        return dirs[0] as? String
    }
}