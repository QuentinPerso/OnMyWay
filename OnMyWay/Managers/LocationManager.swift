//
//  LocationManager.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 02/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import CoreLocation
import MapKit

typealias LMLocationUpdateClosure = ((_ coordinate:CLLocationCoordinate2D, _ error:String?)->())?


@objc
protocol LocationManagerDelegate : class
{
    @objc optional func locationAlwaysGranted()
    @objc optional func locationGranted(status:CLAuthorizationStatus)
}

class LocationManager: NSObject{
    
    //************************************
    // MARK: - Location
    //************************************
    
    static var hasLocalisationAuth:Bool {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined, .denied, .restricted:
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        }
    }
    
    fileprivate var locUpateClosure:LMLocationUpdateClosure
    fileprivate var headingUpateClosure:((_ heading:CLLocationDirection)->())?
    fileprivate var singleUpdate = false
    
    var locationStatus : String = "Calibrating"// to pass in handler
    fileprivate var locationManager: CLLocationManager!
    
    var locationAlwaysGranted:(()->())?
    var locationInUseGranted:(()->())?
    
    var coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var heading = CLLocationDirection()
    
    var lastLocation:CLLocation?
    var lastKnownCoord:CLLocationCoordinate2D?{ return lastLocation?.coordinate }
    
    
    //var autoUpdate = false
    
    static let shared = LocationManager()
    fileprivate override init(){ super.init() }
    
    fileprivate func resetLatLon(){
        
        coordinates = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
    }
    
    func startUpdatingLocation(oneShot:Bool = false, completion:((_ coordinate:CLLocationCoordinate2D, _ error:String?)->())? = nil){
        
        singleUpdate = oneShot
        
        locUpateClosure = completion
        
        initLocationManager()
        
        startCoordUpdate()
        
    }
    
    func stopUpdatingLocation(){
        
        stopCoordUpdate()
        
    }
    
    func startUpdatingDirection(_ completion:((_ heading:CLLocationDirection)->())? = nil){
        
        if locationManager == nil { return }
        
        headingUpateClosure = completion
        
        locationManager.startUpdatingHeading()
    }
    
    func stopUpdatingDirection(){
        
        if locationManager == nil { return }
        
        locationManager.stopUpdatingHeading()
        
    }
    
    
    
    fileprivate func initLocationManager() {
        
        if locationManager != nil { return }
        
        locationManager = CLLocationManager()
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        
    }
    
    func requestLocAuth() {
        initLocationManager()
    }
    
    
    fileprivate func startCoordUpdate(){
        locationManager.startUpdatingLocation()
    }
    
    
    fileprivate func stopCoordUpdate(){
        
        locationManager.stopUpdatingLocation()
        
    }
    
    //************************************
    // MARK: - Routes
    //************************************
    
    static func requestRoute(coordinate:CLLocationCoordinate2D,
                             type:MKDirectionsTransportType,
                             completion:@escaping (_ route:MKRoute?, _ error:Error?)->()) {
        
        let myRouteRequest = MKDirectionsRequest()
        myRouteRequest.transportType = type
        
        myRouteRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        myRouteRequest.source = MKMapItem.forCurrentLocation()
        
        let directions = MKDirections(request: myRouteRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            if let error = error {
                print(error)
                completion(nil, error)
            }
            else if let routes = response?.routes, response!.routes.count > 0 {
                completion(routes[0], nil)
            }
            else {
                completion(nil, nil)
            }
        }
        
        
    }
    
    
}

//************************************
// MARK: - CLLocationManager Delegate
//************************************

extension LocationManager:CLLocationManagerDelegate {
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        stopCoordUpdate()
        
        resetLatLon()
        
        locUpateClosure?(coordinates, error.localizedDescription)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        if newHeading.headingAccuracy < 0 { return }
        
        heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        
        headingUpateClosure?(heading)
        
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        if location == nil { return }
        
        let coord = location!.coordinate
        
        coordinates = coord
        lastLocation = location
        if singleUpdate {
            locationManager.stopUpdatingLocation()
            singleUpdate = false
        }
        
        locUpateClosure?(coord, nil)
        
    }
    
    
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        
        switch status {
        case .restricted, .denied, .notDetermined:
            resetLatLon()
            if (!locationStatus.isEqual("Denied access")){
                locUpateClosure?(coordinates, nil)
                
            }
        case .authorizedAlways:
            locationAlwaysGranted?()
        case .authorizedWhenInUse:
            locationInUseGranted?()
        }
        
    }
    
}




