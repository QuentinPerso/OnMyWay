//
//  ViewController.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 01/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MapVC: UIViewController {

    private static let defaultRadiusUnselected:Double = 1000
    
    private var userAddRefHandle: DatabaseHandle?
    private var userChangeRefHandle: DatabaseHandle?
    private lazy var userRef: DatabaseReference = Database.database().reference().child("users")
    
    private var mapView: InteractivMap!
    private var locationButton: UIButton!
    private var drawerView:DrawerView!
    private var toggleButton:UIButton!
    private var emojiCollection:EmojiCollection!
    private var goView:GoView!
    
    private var users = [OMWUser]()
    
    // MARK: Object Lifecycle
    
    deinit {
        if let refHandle = userAddRefHandle { userRef.removeObserver(withHandle: refHandle) }
        if let refHandle = userChangeRefHandle { userRef.removeObserver(withHandle: refHandle) }
        
    }
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if mapView == nil {
            setViews()
            observeUsers()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.setUpdatingMap(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.setUpdatingMap(false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if goView != nil {
            return goView.frame.origin.y == 0 ? .lightContent : .default
        }
        return .default
    }
    
    
    
}

//************************************
// MARK: - Views Setup
//************************************

extension MapVC {
    
    private func setViews() {
        
        
        setupMap()
        
        setupDrawerView()
        
        setupGoView()
        
        setupLocationButton()
        
        self.view.addSubview(mapView)
        self.view.addSubview(locationButton)
        self.view.addSubview(drawerView)
        self.view.addSubview(goView)
        
    }
    
    //************************************
    // MARK: - Location Button
    //************************************
    
    private func setupLocationButton() {
        
        var locButtonFrame = CGRect(origin: .zero, size: CGSize(width: 64, height: 64))
        var bottomPadding: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            bottomPadding = window?.safeAreaInsets.bottom ?? 0
        }
        locButtonFrame.origin.y = view.frame.size.height - bottomPadding - 80
        locationButton = UIButton(frame: locButtonFrame)
        locationButton.center.x = view.center.x
        locationButton.setImage(#imageLiteral(resourceName: "locationButton"), for: .normal)
        locationButton.addTarget(self, action: #selector(self.locationButtonClicked), for: .touchUpInside)
        
    }
    
    @objc private func locationButtonClicked() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    //************************************
    // MARK: - MapView
    //************************************
    
    private func setupMap() {
        
        mapView = InteractivMap(frame: self.view.frame)
        mapView.tintColor = #colorLiteral(red: 0, green: 0.7843137255, blue: 1, alpha: 1)
        
        mapView.didSelectAnnotaionAction = { [weak self] annotation, selected, manualy in
            
            if selected {
                guard let pAnnot = annotation as? PersonAnnotation else { return }
                self?.toggleButton.setTitle("Send love to \(pAnnot.user!.name!)", for: .normal)
                self?.drawerView.animateToCollapsed()
                self?.mapView.set3DCamera(coord: annotation.coordinate, animated: true)
            }
            else {
                self?.drawerView.animateToExited()
                self?.goView.hide()
                if !manualy {
                    self?.mapView.centerOn(coord: annotation.coordinate, radius: MapVC.defaultRadiusUnselected, animated: true)
                }
                
            }
            
            
        }
        mapView.didUpdateUserLocationAction = { [weak self] coordinate in
            
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            let itemRef = self?.userRef.child(userId)
            
            itemRef?.updateChildValues(["coordinates":["lat":coordinate.latitude, "lng":coordinate.longitude]])
        }
        
        mapView.routeUpdatedAction = { [weak self] route in
            
            guard let targetUserId = self?.mapView.tagetUserAnnotation?.user.uniqueId else { return }
            self?.sendRouteToUser(route: route, toUserId: targetUserId)
        }
        
    }
    
    //************************************
    // MARK: - Drawer
    //************************************
    
    private func setupDrawerView() {
        drawerView = DrawerView(expandedHeight:self.view.frame.size.height*1/2, collapsedtHeight:self.view.frame.size.height*1/4)
        
        toggleButton = UIButton(frame: CGRect(x: 40, y: 10, width: drawerView.frame.width - 80, height: 48))
        toggleButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        toggleButton.autoresizingMask = [.flexibleHeight,.flexibleLeftMargin,.flexibleRightMargin]
        toggleButton.layer.cornerRadius = 24
        toggleButton.setTitle("Send emojis to Clarissa", for: .normal)
        toggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        toggleButton.setTitleColor(.lightGray, for: .normal)
        toggleButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        drawerView.containerView.addSubview(toggleButton)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        emojiCollection = EmojiCollection(frame: CGRect(x: 0, y:58 , width: drawerView.containerView.frame.size.width , height: drawerView.containerView.frame.size.height - 58), collectionViewLayout: layout)
        
        emojiCollection.backgroundColor = .clear
        emojiCollection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        drawerView.containerView.addSubview(emojiCollection)
        
        drawerView.stateChangedAction = { [weak self] in
            if self == nil { return }
            self!.mapView.layoutMargins.bottom = self!.mapView.frame.size.height - self!.drawerView.frame.origin.y
            UIView.animate(withDuration: 0.2, animations: {
                self?.locationButton.alpha = self!.drawerView.frame.origin.y == self!.view.frame.size.height ? 1:0
            })
        }
        
        emojiCollection.didSelectEmoji = { [weak self] emoji, emojiView in
            if self == nil { return }
            
            if emoji.isOnMyWay {
                self?.toggleOnMyWay()
            }

            self?.sendEmoji(emojiView: emojiView)
            
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        
        drawerView.toggleExpanded()
    }
    
    private func sendEmoji(emojiView:UIImageView){
        
        if mapView.selectedAnnotations.count == 0 { return }
        let selectedAnnot = mapView.selectedAnnotations[0]
        guard let annotView = mapView.view(for: selectedAnnot) else { return }

        HapticHelper.impact()
        
        let annotPoint = annotView.superview!.convert(annotView.center, to: view)
        let emojiPoint = emojiView.superview!.convert(emojiView.center, to: view)
        
        let emojiAnimImView = UIImageView(image: emojiView.image)
        emojiAnimImView.center = emojiPoint
        view.addSubview(emojiAnimImView)
        UIView.animate(withDuration: 0.6, animations: {
            emojiAnimImView.center = annotPoint
        }, completion: { (ended) in
            emojiAnimImView.removeFromSuperview()
        })
        
        UIView.animateKeyframes(withDuration: 0.6, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                emojiAnimImView.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
            })
            UIView.addKeyframe(withRelativeStartTime:0.75, relativeDuration: 0.25, animations: {
                emojiAnimImView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            })
            UIView.addKeyframe(withRelativeStartTime:0.8, relativeDuration: 0.2, animations: {
                emojiAnimImView.alpha = 0
            })
        }, completion: { (ended) in
            emojiAnimImView.removeFromSuperview()
        })
        
    }
    
    private func toggleOnMyWay() {
        
        if goView.walkRoute != nil { return }
        
        if mapView.selectedAnnotations.count == 0 { return }
        let coord = mapView.selectedAnnotations[0].coordinate
        
        let centerCoord = mapView.centerCoordinate
        goView.show()
        mapView.set3DCamera(coord: centerCoord, animated: true)
        
        LocationManager.requestRoute(coordinate: coord, type: .walking) { [weak self] route, error in
            guard let route = route else { return }
            self?.goView.walkRoute = route
        }
        
        LocationManager.requestRoute(coordinate: coord, type: .automobile) { [weak self] route, error in
            guard let route = route else { return }
            self?.goView.carRoute = route
        }
        
        LocationManager.requestRoute(coordinate: coord, type: .transit) { [weak self] route, error in
            guard let route = route else { return }
            self?.goView.trainRoute = route
        }
        
        LocationManager.requestRoute(coordinate: coord, type: .walking) { [weak self] route, error in
            guard let route = route else { return }
            self?.goView.bikeRoute = route
        }
        
    }
    
    //************************************
    // MARK: - GoView
    //************************************
    
    private func setupGoView() {
        
        goView = Bundle.main.loadNibNamed("GoView", owner: self, options: nil)?[0] as! GoView
        
        var topPadding:CGFloat = UIApplication.shared.statusBarFrame.height
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            if let topSafeArea = window?.safeAreaInsets.top, topSafeArea != 0 {
                topPadding = topSafeArea
            }
        }
        
        goView.frame = self.view.window!.bounds
        goView.frame.size.height = 78 + topPadding
        goView.frame.origin.y = -goView.frame.size.height
        
        goView.stateChangedAction = { [weak self] hidden in
            if self == nil { return }
            self?.mapView.route = nil
            self!.mapView.layoutMargins.top = self!.goView.frame.size.height
            self!.setNeedsStatusBarAppearanceUpdate()
        }
        
        goView.routeSelectedAction = { [weak self] route, going in
            if route == nil { return }

            self?.mapView.route = route
            let routeInset = UIEdgeInsets(top: PersonAnnotationView.pinSize.height+4, left: 4, bottom: 4, right: 4)
            self?.mapView.setVisibleMapRect(route!.polyline.boundingMapRect, edgePadding: routeInset, animated: true)
            
            if going {
                guard let targetUserId = self?.mapView.tagetUserAnnotation?.user.uniqueId else { return }
                self?.sendRouteToUser(route: route!, toUserId: targetUserId)
            }
            

        }
        
        goView.goButtonAction = { [weak self] going in
            
            self?.goToUser(going: going)
        
        }
        
    }
    
    private func goToUser(going:Bool) {

        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if going {
            print("on my way launched")
            if mapView.selectedAnnotations.count == 0 { return }
            guard let selectedAnnot = mapView.selectedAnnotations[0] as? PersonAnnotation else { return }
            guard let route = mapView.route else { return }
            
            guard let targetUserId = selectedAnnot.user.uniqueId else { return }
            
            mapView.tagetUserAnnotation = selectedAnnot
            
            sendRouteToUser(route: route, toUserId: targetUserId)
        }
        else {
            print("on my way canceled")
            mapView.tagetUserAnnotation = nil
            let itemRef = userRef.child(userId)
            itemRef.updateChildValues(["onMyWay":""])
        }
        
        
        
    }
    
    func sendRouteToUser(route:MKRoute, toUserId:String){
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let itemRef = userRef.child(userId)
        
        let omwDict = ["toUser": toUserId,
                       "transportType": goView.selectedTransportType.rawValue,
                       "estimatedArrival": route.expectedTravelTime] as [String : Any]
        
        
        
        itemRef.updateChildValues(["onMyWay":omwDict])
    }
    
    
//    omwDict = dictionary["onMyWay"] as? [String : AnyObject] {
//    if let toUser = omwDict["toUser"] as? String, let myId = Auth.auth().currentUser?.uid {
//    if toUser == myId {
//    if let transportType = omwDict["transportType"] as? String {
//    self.transportType = TransportType(rawValue: transportType)
//    }
//    self.estimatedArrival = omwDict["estimatedArrival"] as? Int
    

    
}

//************************************
// MARK: - Firebase observer
//************************************

extension MapVC {
    
    private func observeUsers() {
        // We can use the observe method to listen for new
        // channels being written to the Firebase DB
        
        userChangeRefHandle = userRef.observe(.childChanged) { (snapshot) -> Void in
            let userData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if id != Auth.auth().currentUser?.uid {
                let user = OMWUser(dictionary: userData)
                if user.coordinates == nil { return }
                if self.users.contains(user){
                    self.users.remove(user)
                }
                self.users.append(user)
                self.mapView.reloadMap(users: self.users)
            }
        }
        
        userAddRefHandle = userRef.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            let userData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if id != Auth.auth().currentUser?.uid {
                
                let user = OMWUser(dictionary: userData)
                if user.coordinates == nil { return }
                if self?.users == nil { return }
                if self!.users.contains(user){
                    self!.users.remove(user)
                }
                self!.users.append(user)
                self!.mapView.reloadMap(users: self!.users)
                self!.mapView.showAnnotations(self!.mapView.annotations, animated: true)
            }
        })
    }
    
}

