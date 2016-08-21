//
//  UITableViewCell.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation
import QuartzCore

extension UITableViewCell {
    func lock () {
        self.accessoryView = UIImageView(image: UIImage(named: "lock-disabled"))
        self.contentView.layer.opacity = 0.4;
    }
    
    func unlock() {
        self.accessoryView = nil
        self.contentView.layer.opacity = 1;
    }
}
