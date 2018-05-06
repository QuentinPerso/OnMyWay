//
//  Image+Label.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 05/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit

extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        label.layer.render(in: ctx)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
        
    }
}
