//
//  MapView+Center.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 04/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import MapKit

extension MKMapView {
    
    //************************************
    // MARK: - Coordinate
    //************************************
    
    func centerOn(coord: CLLocationCoordinate2D, radius:CLLocationDistance?, animated:Bool) {
        
        if radius != nil {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coord, radius!, radius!)
            self.setRegion(coordinateRegion, animated: animated)
        }
        else {
            self.setCenter(coord, animated: animated)
        }
    }
    
    //************************************
    // MARK: - 3D Camera
    //************************************
    
    func set3DCamera(coord:CLLocationCoordinate2D, animated:Bool) {
        
        let distance: CLLocationDistance = 800
        let pitch: CGFloat = 20
        let heading = 00.0
        
        let camera = MKMapCamera(lookingAtCenter: coord,
                                 fromDistance: distance,
                                 pitch: pitch,
                                 heading: heading)
        
        self.setCamera(camera, animated: animated)
    }
    

    
    
}
