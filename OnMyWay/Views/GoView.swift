//
//  GoView.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 05/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit
import MapKit

class GoView: UIView {
    
    @IBOutlet var transportButtons: [VerticalButton]!
    
    @IBOutlet weak var walkButton: VerticalButton!
    @IBOutlet weak var carButton: VerticalButton!
    @IBOutlet weak var trainButton: VerticalButton!
    @IBOutlet weak var bikeButton: VerticalButton!
    
    var walkRoute:MKRoute? { didSet { setButtonState(walkButton, route: walkRoute) } }
    var carRoute:MKRoute? { didSet { setButtonState(carButton, route: carRoute) } }
    var trainRoute:MKRoute? { didSet { setButtonState(trainButton, route: trainRoute) } }
    //TODO:Change API for real bike route
    var bikeRoute:MKRoute? { didSet { setButtonState(bikeButton, route: bikeRoute) } }
    
    private var isInHisWayMode = false
    
    public var stateChangedAction:((_ hidden:Bool)->())?
    var routeSelectedAction:((MKRoute?, _ onMyWay:Bool)->())?
    var goButtonAction:((_ isGoing:Bool)->())?
    
    var selectedTransportType:TransportType = .walk
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for button in transportButtons {
            button.alpha = 0.5
        }
        walkButton.alpha = 1
    }
    
    private func setButtonState(_ button:UIButton, route:MKRoute?) {
        if route == nil {
            button.setTitle("??", for: .normal)
            button.isEnabled = false
        }
        else {
            let title = "\(Int(route!.expectedTravelTime/(button == bikeButton ? 120 : 60))) min"
            button.setTitle(title, for: .normal)
            button.isEnabled = true
            if button.alpha == 1 {
                transportClicked(button)
            }
        }
    
        
    }
    
    @IBAction func transportClicked(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.2) {
            sender.alpha = 1
        }
        
        for button in transportButtons {
            if button != sender {
                UIView.animate(withDuration: 0.2) {
                    button.alpha = 0.5
                }
            }
        }
        
        if sender == walkButton {
            selectedTransportType = .walk
            routeSelectedAction?(walkRoute, isInHisWayMode)
        }
        else if sender == carButton {
            selectedTransportType = .car
            routeSelectedAction?(carRoute, isInHisWayMode)
        }
        else if sender == trainButton {
            selectedTransportType = .transit
            routeSelectedAction?(trainRoute, isInHisWayMode)
        }
        else if sender == bikeButton {
            selectedTransportType = .bike
            routeSelectedAction?(bikeRoute, isInHisWayMode)
        }
    }

    @IBAction func goButtonClicked(_ sender: UIButton) {
        
        sender.setTitle("", for: .selected)
        UIView.transition(with: sender, duration: 0.2, options: .transitionFlipFromLeft, animations: {
            sender.isSelected = !sender.isSelected
        }, completion: nil)
        
        isInHisWayMode = sender.isSelected
        goButtonAction?(isInHisWayMode)
        hide()
    }
    
    func show() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 6, initialSpringVelocity: 1, options: [UIViewAnimationOptions.curveEaseOut, .allowUserInteraction], animations: ({
            
            self.frame.origin.y = 0
            self.alpha = 1
            
        }), completion: { (ended) in
            if ended { }
        })
        
        //Auto select route on show
        for button in transportButtons {
            if button.alpha == 1 {
                transportClicked(button)
                break
            }
        }
        stateChangedAction?(false)
    }
    
    func hide() {
        
        if isInHisWayMode { return }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [UIViewAnimationOptions.curveEaseOut, .allowUserInteraction], animations: ({

            self.alpha = 0
            self.frame.origin.y = -self.frame.size.height
            
        }), completion: { (ended) in
            if ended { }
        })
        walkRoute = nil
        carRoute = nil
        trainRoute = nil
        bikeRoute = nil
        stateChangedAction?(true)
    }



}
