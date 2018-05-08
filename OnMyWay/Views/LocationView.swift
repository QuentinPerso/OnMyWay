//
//  LocationView.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 07/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit

class LocationView: UIView {
    
    private var locationButton: UIButton!
    private var friendOnWayIndicator:UIImageView!
    
    public var isOMWSelected = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        locationButton = UIButton(frame: bounds)
        locationButton.setImage(#imageLiteral(resourceName: "locationButton"), for: .normal)

        friendOnWayIndicator = UIImageView(image: #imageLiteral(resourceName: "Omw"))
        var indicatorCenter = locationButton.frame.origin
        indicatorCenter.x += bounds.size.width/4
        indicatorCenter.y += bounds.size.height/4
        friendOnWayIndicator.center = indicatorCenter
        friendOnWayIndicator.alpha = 0.7
        friendOnWayIndicator.isHidden = true
        
        addSubview(locationButton)
        addSubview(friendOnWayIndicator)
    }
    
    public func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
        locationButton.addTarget(target, action: action, for: controlEvents)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    public func setFriendOnHisWay(_ friendsOnWay:Bool) {
        
        guard let indicator = friendOnWayIndicator else { return }
        
        if indicator.isHidden == !friendsOnWay {
            return
        }
        
        indicator.isHidden = !friendsOnWay
        
        if friendsOnWay {
            UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: [.repeat], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                    indicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                })
                UIView.addKeyframe(withRelativeStartTime:0.5, relativeDuration: 0.5, animations: {
                    indicator.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
                
            }, completion: nil)
        }
        else {
            indicator.layer.removeAllAnimations()
            indicator.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
    }
    
}
