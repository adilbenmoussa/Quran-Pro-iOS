//
//  WINPageContentViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

class WINPageContentViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var whatIsNewLabel: UILabel!
    
    var pageIndex: Int = 0
    var titleText: String = ""
    var imageName: String = ""
    var labelVersion: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = kAppColor
        self.backgroundImageView.image = UIImage(named: imageName)
        let layer = backgroundImageView.layer
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 3, height: 3)
        
        whatIsNewLabel.text = labelVersion
        
        self.titleLabel.text = titleText
        
        self.exitButton.setTitle(" " + "Continue".local + " ", forState: UIControlState.Normal)
        self.exitButton.titleLabel?.textColor = kAppColor
        self.exitButton.layer.borderWidth = 0.1
        self.exitButton.backgroundColor = UIColor.whiteColor()
        self.exitButton.tintColor = UIColor.blackColor()
        self.exitButton.layer.shadowColor = UIColor.blackColor().CGColor
        self.exitButton.layer.shadowOpacity = 0.6
        self.exitButton.layer.shadowRadius = 5
        self.exitButton.layer.shadowOffset = CGSize(width: 3, height: 3)
    }
    
    @IBAction func exitHandler(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(kExitWhatIsNewVCNotification, object: nil,  userInfo:nil)
    }
}