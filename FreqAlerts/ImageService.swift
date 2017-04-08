//
//  ImageService.swift
//  FreqAlerts
//
//  Created by Hayden Malcomson on 2017-04-08.
//  Copyright © 2017 Hayden Malcomson. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func withColor(color: UIColor) -> UIImage {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}

