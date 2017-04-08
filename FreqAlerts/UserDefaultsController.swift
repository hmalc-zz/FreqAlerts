//
//  UserDefaultsController.swift
//  FreqAlerts
//
//  Created by Hayden Malcomson on 2017-04-08.
//  Copyright © 2017 Hayden Malcomson. All rights reserved.
//

import Foundation


class UserDefaultsService {
    
    static func getBoolValueForKey(keyString: String) -> Bool {
        return UserDefaults.standard.bool(forKey: keyString)
    }
    
    static func setBoolValueForKey(keyString: String, bool: Bool) {
        UserDefaults.standard.set(bool, forKey: keyString)
    }
    
    static func setValueForKey(keyString: String, value: Double){
        UserDefaults.standard.set(value, forKey: keyString)
    }
    
    static func getValueForKey(keyString: String) -> Double? {
        return UserDefaults.standard.value(forKey: keyString) as? Double
    }
    
    static func setAllToTrue(){
        let keysToSet = [SHOULD_FLASH,SHOULD_VIBRATE,SHOULD_PLAY_SOUND]
        for key in keysToSet {
            setBoolValueForKey(keyString: key, bool: true)
        }
    }
    
    static let FIRST_LOAD = "FIRST_LOAD"
    
    static let SHOULD_FLASH = "SHOULD_FLASH"
    static let SHOULD_VIBRATE = "SHOULD_VIBRATE"
    static let SHOULD_PLAY_SOUND = "SHOULD_PLAY_SOUND"
    
    static let GAIN_CUTOFF_VALUE = "GAIN_CUTOFF_VALUE"
    static let FREQUENCY_CUTOFF_VALUE = "FREQUENCY_CUTOFF_VALUE"
    
}
