//
//  VerticalButton.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 05/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit

class VerticalButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if imageView == nil || titleLabel == nil { return }
        
        var titleFrame = titleLabel!.frame
        titleFrame = CGRect(x: 0,
                       y: bounds.size.height - titleFrame.size.height,
                       width: self.frame.size.width, height: titleFrame.size.height)
        titleLabel!.frame = titleFrame
        titleLabel?.textAlignment = .center
        
        
        var frame = imageView!.frame
        frame = CGRect(x: CGFloat(truncf(Float((bounds.size.width - frame.size.width) / 2))),
                       y: (bounds.size.height - titleFrame.size.height - frame.size.height)/2,
                       width: frame.size.width,
                       height: frame.size.height)
        imageView!.frame = frame

        
        
    }
    
}
