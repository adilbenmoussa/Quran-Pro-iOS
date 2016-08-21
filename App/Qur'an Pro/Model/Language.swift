//
//  Language.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

class Language: CustomStringConvertible {
    // language id
    var id: String
    // language name
    var name: String
    
    init(id: String, name: String){
        self.id = id
        self.name = name
    }
    
    var description: String {
        return "id= \(self.id), name=\(self.name)"
    }   
}
