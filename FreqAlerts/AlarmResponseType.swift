//
//  AlarmResponseType.swift
//  FreqAlerts
//
//  Created by Hayden Malcomson on 2017-04-08.
//  Copyright © 2017 Hayden Malcomson. All rights reserved.
//

import UIKit
import Foundation
import Hex

enum AlarmResponseType: Int {
    case flashlight = 0
    case vibrate = 1
    case sound = 2
}

struct AlarmResponsePreference {
    
    let title: String!
    let summary: String!
    let icon: UIImage!
    let colorHex: UIColor!
    let index: Int
    let defaultKey: String!
    
    init(alarmResponseType: AlarmResponseType) {
        
        self.index = alarmResponseType.rawValue
        
        switch alarmResponseType {
        case .flashlight:
            self.title = "Flashlight"
            self.summary = "Pulse the flash"
            self.icon = #imageLiteral(resourceName: "flash")
            self.colorHex = UIColor(hex: "FFCC00") // Yellow
            self.defaultKey = UserDefaultsService.SHOULD_FLASH
        case .vibrate:
            self.title = "Vibrate"
            self.summary = "Trigger vibration during alarm"
            self.icon = #imageLiteral(resourceName: "vibration")
            self.colorHex = UIColor(hex: "FF2D55") // Hot Pink
            self.defaultKey = UserDefaultsService.SHOULD_VIBRATE
        case .sound:
            self.title = "Sound"
            self.summary = "Play a sound"
            self.icon = #imageLiteral(resourceName: "sound")
            self.colorHex = UIColor(hex: "34AADC") // Blue
            self.defaultKey = UserDefaultsService.SHOULD_PLAY_SOUND
        }
    }
}

class AlarmResponse {
    
    static func getAlarmResponseTypes() -> [AlarmResponsePreference] {
        let responseCategories: [AlarmResponseType] = [.flashlight, .vibrate, .sound]
        var responseStructs: [AlarmResponsePreference] = []
        for category in responseCategories {
            let alarmResponsePreference = AlarmResponsePreference(alarmResponseType: category)
            responseStructs.append(alarmResponsePreference)
        }
        return responseStructs
    }
}
