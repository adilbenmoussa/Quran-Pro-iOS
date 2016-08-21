//
//  PartQaurter.swift // Rub' al Juz'
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

class PartQuarter: CustomStringConvertible {
    
    var parentId: Int
    var chapterId: Int
    var verseId: Int
    var type: PartQuarterType
    var hizbId: Int
    
    init(parentId: Int, chapterId: Int, verseId: Int, type: PartQuarterType, hizbId: Int){
        self.parentId = parentId
        self.chapterId = chapterId
        self.verseId = verseId
        self.type = type
        self.hizbId = hizbId
    }
    
    var description: String {
        return "parentId: \(parentId), chapterid: \(chapterId), verseId: \(verseId), type: \(type)"
    }
    
    func display() -> String {
        if self.type == .One {
            return "Ḥizb ﴾\(hizbId)﴿"
        }
        else if self.type == .OneFourth{
            return "1/4 ḥizb"
        }
        else if self.type == .Half{
            return "1/2 ḥizb"
        }
        else if self.type == .ThreeFourth{
            return "3/4 ḥizb"
        }
        
        return ""
    }
}
