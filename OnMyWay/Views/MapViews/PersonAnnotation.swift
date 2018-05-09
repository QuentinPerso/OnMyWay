//
//  PersonAnnotation.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 04/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit
import MapKit

class PersonAnnotation:NSObject, MKAnnotation {
    
    var user:OMWUser!

    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    init(user:OMWUser) {
        
        self.user = user
        self.coordinate = user.coordinates

        //self.title = theaterShowTime.cinema.name

        
        super.init()
    }
    
}
