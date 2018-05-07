//
//  InteractivMap.swift
//  WatchOut
//
//  Created by admin on 09/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit
import MapKit

class InteractivMap: MKMapView {
    
    
    private var previousLocation:CLLocation?
    
    var tagetUserAnnotation:PersonAnnotation?
    
    private var shouldShowAnnotations = false
    private var shouldSkipDeselect = false
    private var shouldDeselect = true
    
    private var headingImageView: UIImageView?
    
    //var mapDraggedAction:(()->())?
    var route:MKRoute? { didSet{ polyline = route?.polyline } }
    var polyline:MKPolyline? {
        didSet {
            if let prevLine = oldValue {
                
                remove(prevLine)
            }
            if polyline != nil {
                add(polyline!)
            }
            
        }
    }
    
    var didSelectAnnotaionAction:((_ annotation:MKAnnotation, _ selected:Bool, _ manualy:Bool)->())?
    var didDeselectAllAnnotaionAction:(()->())?
    var didUpdateUserLocationAction:((_ userLocation:CLLocationCoordinate2D)->())?
    var routeUpdatedAction:((MKRoute)->())?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        self.delegate = self
        
        self.layoutMargins = UIEdgeInsets(top: 20,
                                             left: 20,
                                             bottom: 20,
                                             right: 20)
        
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        panRec.delegate = self
        
        self.addGestureRecognizer(panRec)
        
        let locAuthStatus = CLLocationManager.authorizationStatus()
        if locAuthStatus == .notDetermined {
            LocationManager.shared.locationInUseGranted = {[weak self] in
                self?.setUserTrackingMode(.follow, animated: false)
            }
            LocationManager.shared.requestLocAuth()
        }
        else if LocationManager.hasLocalisationAuth {
            
            self.showsUserLocation = true

            LocationManager.shared.startUpdatingLocation(oneShot:true, completion: { (coord, error) in
                //self.shouldStartSearch = true
                self.centerOn(coord: coord, radius: 10000, animated: false)
                //self.shouldStartSearch = false
                self.shouldShowAnnotations = true
                
            })
            
        }
    }

}

//************************************
// MARK: - Map Functions
//************************************
extension InteractivMap : UIGestureRecognizerDelegate {
    
    @objc func didDragMap(_ gestureRecognizer:UIGestureRecognizer){
        
        if gestureRecognizer.state == .began {
            for annot in selectedAnnotations {
                shouldSkipDeselect = true
                deselectAnnotation(annot, animated: true)
            }
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func reloadMap(users:[OMWUser]){
        
        var annotUsers = [OMWUser]()
        for annotation in annotations {
            guard let pAnnot = annotation as? PersonAnnotation else { continue }
            guard let annotsUser = pAnnot.user else { continue }
            annotUsers.append(annotsUser)
            if users.contains(annotsUser) {
                let user = users[users.index(of: annotsUser)!]
                let newCoord = user.coordinates
                UIView.animate(withDuration: 0.3) {
                    pAnnot.coordinate = newCoord!
                }
                guard let annotView = view(for: pAnnot) as? PersonAnnotationView else { continue }
                if let userETA = user.estimatedArrival, let transportType = user.transportType {
                    annotView.createParticles(type: transportType, eta: userETA)
                    pAnnot.user.estimatedArrival = userETA
                    pAnnot.user.transportType = transportType
                }
                else {
                    pAnnot.user.estimatedArrival = nil
                    pAnnot.user.transportType = nil
                    annotView.stopParticles()
                }
                
            }
            
        }
        
        
        for user in users {
            if !annotUsers.contains(user) {
                addAnnotation(PersonAnnotation(user: user))
            }
        }
    }
    
    func annotationViewBounceAnimation(_ annotView:UIView, scaleFactor sf:CGFloat) {
        
        annotView.transform = CGAffineTransform(scaleX: sf, y: 1)
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [.repeat, .allowUserInteraction], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                annotView.transform = CGAffineTransform(translationX: 0, y: PersonAnnotationView.pinSize.height * (1 - sf) / 2 ).scaledBy(x: 1, y: sf)
            })
            UIView.addKeyframe(withRelativeStartTime:0.5, relativeDuration: 0.5, animations: {
                annotView.transform = CGAffineTransform(scaleX: sf, y: 1)
            })
            
        }, completion: nil)
        
    }
    
    
}

//************************************
// MARK: - Heading view and update
//************************************
extension InteractivMap {
    
    
    private func addHeadingView(_ views: [MKAnnotationView]) {
        
        guard headingImageView == nil else { return }
        
        var view:MKAnnotationView?
        for annotView in views {
            if annotView.annotation is MKUserLocation {
                view = annotView
                break
            }
            
        }
        
        guard let annotationView = view  else { return }

        let image = #imageLiteral(resourceName: "headingView")
        headingImageView = UIImageView(image: image)
        headingImageView?.tintColor = UIColor.omwBlue
        
        let frame = CGRect(x: (annotationView.frame.size.width - image.size.width)/2,
                           y: (annotationView.frame.size.height - image.size.height)/2,
                           width: image.size.width,
                           height: image.size.height)
        headingImageView!.frame = frame
        annotationView.addSubview(headingImageView!)
        headingImageView!.isHidden = true
        
    }
    
    func setUpdatingMap(_ updating:Bool){
        
        self.showsUserLocation = updating
        
        if updating {
            LocationManager.shared.startUpdatingDirection({ [weak self] direction in
                self?.updateHeadingRotation(direction: direction)
            })
        }
        else {
            LocationManager.shared.stopUpdatingDirection()
        }
        
        
    }
    
    private func updateHeadingRotation(direction:CLLocationDirection) {
        if let headingImageView = headingImageView {
            
            headingImageView.isHidden = false
            let rotation = CGFloat(direction/180 * .pi)
            headingImageView.transform = CGAffineTransform(rotationAngle: rotation)
        }
    }
    
    private func updateRoute(userLocation:CLLocation) {
        
        if previousLocation == nil {
            previousLocation = userLocation
        }
        
        guard let route = route else { return }
        guard let tagetUserAnnotation = tagetUserAnnotation else { return }
        
        var distanceThreshold = 100.0
        switch route.transportType {
        case .walking:
            distanceThreshold = 100
        case .automobile:
            distanceThreshold = 200
        case .transit:
            distanceThreshold = 200
        default:
            distanceThreshold = 100
        }
        
        
        if userLocation.distance(from: previousLocation!) > distanceThreshold {
            LocationManager.requestRoute(coordinate: tagetUserAnnotation.coordinate, type: route.transportType) { [weak self] (route, error) in
                if route != nil {
                    self?.route = route
                    self?.routeUpdatedAction?(route!)
                }
                
            }
            return
        }
        
        guard let polyline = polyline else { return }
        
        var coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: polyline.pointCount)
        polyline.getCoordinates(coordsPointer, range: NSMakeRange(0, polyline.pointCount))
        
        var minDistance = 10000.0
        var indexMinDistance = -1
        for i in 0..<polyline.pointCount {
            let coord = coordsPointer[i]
            let distance = userLocation.distance(from: CLLocation(latitude: coord.latitude, longitude: coord.longitude))
            
            if distance < minDistance {
                indexMinDistance = i
                minDistance = distance
            }
        }

        var array = Array(UnsafeBufferPointer(start: coordsPointer, count: polyline.pointCount))
        array = Array(array.dropFirst(indexMinDistance))
        array[0] = userLocation.coordinate
        coordsPointer = UnsafeMutablePointer(mutating: array)
        self.polyline = MKPolyline(coordinates: coordsPointer, count: array.count)
        
    }
    
    
    
}


//************************************
// MARK: - Map View Delegate
//************************************

extension InteractivMap : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? PersonAnnotation {
            
            
            let identifier = "personAnnotView"+annotation.user.name
            var annotationView: PersonAnnotationView
            if let dequeuedView = dequeueReusableAnnotationView(withIdentifier: identifier) as? PersonAnnotationView{
                dequeuedView.annotation = annotation
                annotationView = dequeuedView 
            }
            else {
                annotationView = PersonAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.annotText = annotation.user.name
                annotationView.initLayout()
            }
            
            if let userETA = annotation.user.estimatedArrival, let transportType = annotation.user.transportType {
                annotationView.createParticles(type: transportType, eta: userETA)
            }
            
            
            return annotationView
            
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        if let cineAnnot = view.annotation as? PersonAnnotation {
            
            didSelectAnnotaionAction?(cineAnnot, true, true)

            
 
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        if let annot = view.annotation {
            didSelectAnnotaionAction?(annot, false, shouldSkipDeselect)
        }
        
        shouldSkipDeselect = false
        
        if (view.annotation as? PersonAnnotation) != nil {
            if selectedAnnotations.count == 0{
                didDeselectAllAnnotaionAction?()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let userLocationView = view(for: userLocation)
        userLocationView?.canShowCallout = false
        didUpdateUserLocationAction?(userLocation.coordinate)
        
        if let location = userLocation.location {
            updateRoute(userLocation: location)
        }
        
        
 
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        
    }
    
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {

        addHeadingView(views)
        
        var delay = 0.0
        for annotView in views {
            if let placeAnnotView = annotView as? PersonAnnotationView {
                let sf:CGFloat = 0.9
                annotView.transform = CGAffineTransform(translationX: 0, y: placeAnnotView.frame.size.height).scaledBy(x: 0, y: 0)
                UIView.animate(withDuration: 0.2, delay: delay, options: .curveEaseInOut, animations: {
                    annotView.transform = CGAffineTransform(scaleX: sf, y: 1)
                }, completion: { ended in
                    
                    self.annotationViewBounceAnimation(annotView, scaleFactor: sf)
                    
                })
                delay += 0.05
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) ->MKOverlayRenderer {
        
        if let polyline = polyline {
            let gradientColors = [UIColor.omwBlue, UIColor.omwGreen]
            let polylineRenderer = JLTGradientPathRenderer(polyline: polyline, colors: gradientColors)
            polylineRenderer.lineWidth = 7
            return polylineRenderer
        }
        
        return MKOverlayRenderer()
    }
}
