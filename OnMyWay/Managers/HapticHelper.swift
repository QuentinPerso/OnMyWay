//
//  HapticHelper.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 04/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit

class HapticHelper: NSObject {
    
    static func impact(strenght:UIImpactFeedbackStyle = .medium){
        
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: strenght)
            
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
    }
}
