//
//  OMWEmoji.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 05/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit

class OMWEmoji: NSObject {
    
    var image: UIImage!
    var isOnMyWay: Bool!

    init(image:UIImage, onMyWay:Bool = false) {
        // these properties can't be changed after this init.
        self.image = image
        self.isOnMyWay = onMyWay
        super.init()
  
    }
    
}
