//
//  Translation.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation


class Translation: CustomStringConvertible {
    
    var id: String!
    var name: String!
    var icon: UIImage!
    
    init (id: String, name: String, iconName: String) {
        self.id = id
        self.name = name
        self.icon = UIImage(named: iconName)
    }
    
    var description: String {
        return "id= \(id), name= \(name)"
    }
}