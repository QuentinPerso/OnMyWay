//
//  Font+Functions.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 04/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit

enum FontWeight:String {
    case light = "Light"
    case regular = "Regular"
    case medium = "Medium"
    case demiBold = "DemiBold"
    case bold = "Bold"
    case black = "Black"
    case heavy = "Heavy"
    
}

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        
        
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                     attributes: [NSAttributedStringKey.font: self],
                                                     context: nil).size
    }
    
    static func omwFont(size:CGFloat, weight:FontWeight = .demiBold) -> UIFont {

        let fontName = "AvenirNext-\(weight.rawValue)"
        
        return UIFont(name: fontName, size: size)!
        
    }
}
