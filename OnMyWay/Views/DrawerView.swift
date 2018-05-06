//
//  DrawerView.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 02/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit

class DrawerView: UIView {
    
    public var viewBackgroundColor:UIColor = UIColor.clear
    public var containerView = UIView()
    public var stateChangedAction:(()->())?
    
    private var expandedTopMargin:CGFloat!
    private var collapsedTopMargin:CGFloat!
    private var gestureRecognizer = UIPanGestureRecognizer()
    private var backGroundView:UIView!
    
    
    required init(expandedHeight:CGFloat, collapsedtHeight:CGFloat) {
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        var bottomPadding: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            bottomPadding = window?.safeAreaInsets.bottom ?? 0
        }
        
        expandedTopMargin = screenSize.height - bottomPadding - expandedHeight
        collapsedTopMargin = screenSize.height - bottomPadding - collapsedtHeight
        
        super.init(frame: CGRect(x: 0, y:UIScreen.main.bounds.height , width: screenSize.width, height: screenSize.height - expandedTopMargin))
        
        self.alpha = 0
        self.backgroundColor = viewBackgroundColor
        
        backGroundView = UIView()
        backGroundView.backgroundColor = .white
        backGroundView.alpha = 0
        backGroundView.frame = self.bounds
        backGroundView.clipsToBounds = true
        backGroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(backGroundView)
        
        containerView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - bottomPadding)
        containerView.backgroundColor = .clear
        self.addSubview(containerView)
        
        gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.addGestureRecognizer(gestureRecognizer)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            
            
            var newTranslation = CGPoint()
            var oldTranslation = CGPoint()
            newTranslation = gestureRecognizer.translation(in: self.superview)
            
            if(!(newTranslation.y < 0 && self.frame.origin.y + newTranslation.y <= expandedTopMargin)) {
                self.translatesAutoresizingMaskIntoConstraints = true
                self.center = CGPoint(x: self.center.x, y: self.center.y + newTranslation.y)
                
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.superview)
                
                oldTranslation.y = newTranslation.y
            }
            else {
                self.frame.origin.y = expandedTopMargin
                self.isUserInteractionEnabled = false
            }
            
        }
        else if (gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled) {
            
            self.isUserInteractionEnabled = true
            let velocityY = gestureRecognizer.velocity(in: self.superview).y
            
            let screenH = UIScreen.main.bounds.height
            let curentYOffset = self.frame.origin.y
            let distanceToExpanded = abs(expandedTopMargin - curentYOffset)
            let distanceToCollapsed = abs(collapsedTopMargin - curentYOffset)
            let distanceToExited = abs(UIScreen.main.bounds.height - curentYOffset)
            
            let currentYFromBot = screenH - curentYOffset
            
            if 0 <=  currentYFromBot, currentYFromBot < screenH - collapsedTopMargin{
                if (velocityY > 0) {
                    animateToExited()
                }
                else if (velocityY == 0) {
                    
                    if distanceToExited < distanceToCollapsed {
                        animateToExited()
                    }
                    else {
                        animateToCollapsed()
                    }
                    
                }
                else {
                    animateToCollapsed()
                }
            }
            else if screenH - collapsedTopMargin <= currentYFromBot, currentYFromBot <= screenH - expandedTopMargin {
                if (velocityY > 0) {
                    animateToCollapsed()
                }
                else if (velocityY == 0) {
                    
                    if distanceToExpanded < distanceToCollapsed {
                        animateToExpanded()
                    }
                    else {
                        animateToCollapsed()
                    }
                    
                }
                else {
                    animateToExpanded()
                }
            }
            
            self.addGestureRecognizer(gestureRecognizer)
        }
        
    }
    
    func toggleExpanded() {
        
        if(self.frame.origin.y == collapsedTopMargin) {
            animateToExpanded()
        }
        else {
            animateToCollapsed()
        }
    }
    
    
    private func animateToExpanded() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 6, initialSpringVelocity: 1, options: [UIViewAnimationOptions.curveEaseOut, .allowUserInteraction], animations: ({
            
            self.frame.origin.y = self.expandedTopMargin
            self.backGroundView.alpha = 1
            self.alpha = 1
            
        }), completion: { (ended) in
            if ended {
                
            }
        })
        self.stateChangedAction?()
        HapticHelper.impact(strenght: .light)
    }
    
    func animateToCollapsed() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [UIViewAnimationOptions.curveEaseOut, .allowUserInteraction], animations: ({
            
            self.frame.origin.y = self.collapsedTopMargin
            self.backGroundView.alpha = 0
            self.alpha = 1
            
        }), completion: { (ended) in
            if ended {
                
            }
        })
        self.stateChangedAction?()
        HapticHelper.impact(strenght: .light)
    }
    
    func animateToExited() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [UIViewAnimationOptions.curveEaseOut, .allowUserInteraction], animations: ({
            
            self.frame.origin.y = UIScreen.main.bounds.height
            self.alpha = 0
            
        }), completion: { (ended) in
            if ended {
                
            }
        })
        self.stateChangedAction?()
        HapticHelper.impact(strenght: .light)
    }
    
}

