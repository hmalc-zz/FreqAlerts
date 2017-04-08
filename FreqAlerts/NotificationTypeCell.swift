//
//  NotificationTypeCell.swift
//  FreqAlerts
//
//  Created by Hayden Malcomson on 2017-04-08.
//  Copyright © 2017 Hayden Malcomson. All rights reserved.
//

import UIKit

class NotificationTypeCell: UICollectionViewCell {

    var alarmResponsePreference: AlarmResponsePreference!
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var summary: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureWithAlarmResponse(alarmResponsePreference:AlarmResponsePreference) {
        self.alarmResponsePreference = alarmResponsePreference
        title.text = alarmResponsePreference.title
        summary.text = alarmResponsePreference.summary
        iconImage.image = alarmResponsePreference.icon.withColor(color: alarmResponsePreference.colorHex)
    }
    
    @IBAction func `switch`(_ sender: UISwitch) {
        if sender.isOn {
            
        } else {
            
        }
    }
    
}
