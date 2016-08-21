//
//  VerseCell.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

class VerseCell: UITableViewCell {
    
    @IBOutlet weak var bookmarkView: UIImageView!
    @IBOutlet var arabic:UILabel!
    @IBOutlet var translation:UILabel!
    @IBOutlet var transcription:UILabel!
    var verseId: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        verseId = 0
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
