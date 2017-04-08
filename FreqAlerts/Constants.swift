//
//  Constants.swift
//  FreqAlerts
//
//  Created by Hayden Malcomson on 2017-04-08.
//  Copyright © 2017 Hayden Malcomson. All rights reserved.
//

import UIKit
import Foundation

enum AlarmResponseType: Int {
    case flashlight = 0
    case vibrate = 1
    case sound = 2
}

typealias AlarmResponse = (String, String, UIImage, Int)

public func getAlarmResponseTypes() -> [AlarmResponseType] {
    return [.flashlight, .vibrate, .sound]
}

struct AlarmResponsePreference {
    
    let title: String!
    let summary: String!
    let icon: UIImage!
    let index: Int
    
    init(alarmResponseType: AlarmResponseType) {
        
        self.index = alarmResponseType.rawValue
        
        switch alarmResponseType {
        case .flashlight:
            self.title = "Flashlight"
            self.summary = "Pulse the flash"
            self.icon = UIImage()
        case .vibrate:
            self.title = "Vibrate"
            self.summary = "Trigger vibration during alarm"
            self.icon = UIImage()
        case .sound:
            self.title = "Sound"
            self.summary = "Play a custom sound"
            self.icon = UIImage()
        }
    }
    
    
}
