//
//  Extensions.swift
//  FreqAlerts
//
//  Created by Hayden Malcomson on 2017-04-09.
//  Copyright © 2017 Hayden Malcomson. All rights reserved.
//

import Foundation
import UIKit

class AttributedStringHelper {
    
    static func setAttributedStringWithColoredSection(baseString: String, replacementStrings: [String]) -> NSAttributedString {
        let text = baseString
        let attributedString = NSMutableAttributedString(string:text)
        
        for strings in replacementStrings {
            let specialText = strings
            let range = (text as NSString).range(of: specialText)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hex: "080f91"), range: range)
        }
        return attributedString
    }
}
