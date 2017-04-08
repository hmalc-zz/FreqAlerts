//
//  FormattingService.swift
//  FreqAlerts
//
//  Created by Hayden Malcomson on 2017-04-08.
//  Copyright © 2017 Hayden Malcomson. All rights reserved.
//

import Foundation

extension Double {
    
    func formatGain() -> String {
        let percentageInteger = Int(self * 100)
        return "\(percentageInteger)%"
    }
    
    func formatFrequency() -> String {
        let intValue = Int(self)
        return "\(intValue)Hz"
    }
    
    
}
