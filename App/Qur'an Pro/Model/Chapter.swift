//
//  Chapter.swift // Surah
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

class Chapter: Equatable, CustomStringConvertible {
    
    // chapter id
    var id: Int
    // chapter name
    var name: String
    // list of verses (ayat) in the chapter (surah)
    var verses: Array<Verse>
    
    var revelationLocation: String
    
    //init the class model
    init(id: Int, name: String, revelationLocation: String){
        self.id = id
        self.name = name
        self.revelationLocation = revelationLocation
        self.verses = []
    }
    
    // return the audio folder name
    var folderName: String {
        if id < 10 {
            return "00\(id + 1)"
        }
        else if id < 100 && id >= 10 {
            return "0\(id + 1)"
        }
        else{
            return "\(id + 1)"
        }
    }
    
    var description: String {
        return "id: \(id), name: \(name), total verses: \(verses.count), revelation location: \(revelationLocation)"
    }
}

func == (lhs:Chapter,rhs:Chapter) -> Bool {
    return lhs.id == rhs.id && lhs.name == rhs.name
}