//
//  ArtWork.swift
//  Busity
//
//  Created by Quentin BEAUDOUIN on 04/06/2016.
//  Copyright © 2016 Instama. All rights reserved.
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
