//
//  Int+TimeString.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 06/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import Foundation

extension Int {
    
    func roundedTimeString() -> String {
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .brief

        let formattedString = formatter.string(from: TimeInterval(self))!
        
        return formattedString
        
    }
    
}
