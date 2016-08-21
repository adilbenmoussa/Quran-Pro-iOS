//
//  UIFont.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

extension UIFont {
    
    //get the arabic font
    class func latin() ->UIFont {
        if $.fontLevel == FontSizeType.Large {
            return kLatinFontLarge
        }
        else if $.fontLevel == FontSizeType.ExtraLarge {
            return kLatinFontLarge
        }
        else{
            return kLatinFont
        }
    }
    
    class func arabicFont() -> UIFont {
        if $.fontLevel == FontSizeType.Large {
            if $.arabicFont == ArabicFontType.UseMEQuranicFont {
                return kMEQuranicArabicFontLarge
            }
            else if $.arabicFont == ArabicFontType.UsePDMSQuranicFont {
                return kPDMSQuranicArabicFontLarge
            }
            else{
                return kArabicFontLarge
            }
        }
        else if $.fontLevel == FontSizeType.ExtraLarge {
            if $.arabicFont == ArabicFontType.UseMEQuranicFont {
                return kMEQuranicArabicFontExtraLarge
            }
            else if $.arabicFont == ArabicFontType.UsePDMSQuranicFont {
                return kPDMSQuranicArabicFontExtraLarge
            }
            else{
                return kArabicFontExtraLarge
            }
        }
        else{
            if $.arabicFont == ArabicFontType.UseMEQuranicFont {
                return kMEQuranicArabicFont
            }
            else if $.arabicFont == ArabicFontType.UsePDMSQuranicFont {
                return kPDMSQuranicArabicFont
            }
            else{
                return kArabicFont
            }
        }
    }
}