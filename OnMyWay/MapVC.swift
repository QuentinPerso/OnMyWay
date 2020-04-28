//
//  ViewController.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 01/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    private static let defaultRadiusUnselected:Double = 1000
    private let targetInSightDistance = 10.0
    
    
    private var mapView: InteractivMap!
    private var locationView:LocationView!
    private var drawerView:DrawerView!
    private var toggleButton:UIButton!
    private var emojiCollection:EmojiCollection!
    private var goView:GoView!
    

    
    // MARK: Object Lifecycle and App notifications
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillTerminate, object: nil)
    }
    
    @objc func willEnterForeground(){
        for annot in mapView.annotations {
            if let view = mapView.view(for: annot) as? PersonAnnotationView {
                mapView.annotationViewBounceAnimation(view, scaleFactor: 0.9)
            }
        }
    }
    
    @objc func willTerminate(){
        setOnMyWay(onMyWay: false)
    }

    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: .UIApplicationWillTerminate, object: nil)

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
        self.view.addSubview(locationView)
//        self.view.addSubview(locationButton)
//        self.view.addSubview(friendOnWayIndicator)
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
        
        locationView = LocationView(frame: locButtonFrame)
        locationView.center.x = view.center.x
        locationView.addTarget(self, action: #selector(self.locationButtonClicked), for: .touchUpInside)

        
    }
    
    @objc private func locationButtonClicked() {
        
        var annotShow = [PersonAnnotation]()
        for annot in mapView.annotations {
            if let pAnnot = annot as? PersonAnnotation, pAnnot.user.omw != nil {
                annotShow.append(pAnnot)
            }
        }
        
        if annotShow.count != 0, locationView.isOMWSelected == false {
            mapView.showAnnotations(annotShow, animated: true)
            locationView.isOMWSelected = true
        }
        else {
            mapView.showAnnotations(mapView.annotations, animated: true)
            locationView.isOMWSelected = false
        }
        
    }
    
    private func showFriendOnWayIndicator() {
        
        var isFriendsOnWay = false
        for friend in FriendManager.shared.friends {
            if friend.omw != nil {
                isFriendsOnWay = true
                break
            }
        }

        locationView.setFriendOnHisWay(isFriendsOnWay)
        
        
    }
    
    //************************************
    // MARK: - MapView
    //************************************
    
    private func setupMap() {
        
        mapView = InteractivMap(frame: self.view.frame)
        mapView.tintColor = UIColor.omwBlue
        
        mapView.didSelectAnnotationAction = { [weak self] annotation, selected, manualy in
            
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
            
            self?.friendFound(userCoordinate: coordinate)
            
            UserManager.shared.update(coordinate: coordinate)
        }
        
        mapView.routeUpdatedAction = { [weak self] route in
            
            guard let targetUserId = self?.mapView.tagetUserAnnotation?.user.uniqueId else { return }
            self?.goView.updateRoute(route)
            self?.sendRouteToUser(route: route, toUserId: targetUserId)
        }
        
    }
    
    private func friendFound(userCoordinate:CLLocationCoordinate2D) {
        
        guard let tagetUserAnnotation = mapView.tagetUserAnnotation else { return }

        let userLoc = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let friendLoc = CLLocation(latitude: tagetUserAnnotation.coordinate.latitude, longitude: tagetUserAnnotation.coordinate.longitude)
        
        let distance = userLoc.distance(from: friendLoc)
        
        if distance < targetInSightDistance {
            let alert = Bundle.main.loadNibNamed("Popup", owner: self, options: nil)?[0] as! Popup
            alert.setup(title: "\(tagetUserAnnotation.user!.name!) found !", message: "You found your friend !")
            alert.showInWindow(self.view.window!, confetti: true)
            setOnMyWay(onMyWay: false)
            goView.hide()
        }
        
        
        
    }
    
    //************************************
    // MARK: - Drawer
    //************************************
    
    private func setupDrawerView() {
        drawerView = DrawerView(expandedHeight:self.view.frame.size.height*1/2, collapsedtHeight:self.view.frame.size.height*1/4)
        
        toggleButton = UIButton(frame: CGRect(x: 40, y: 10, width: drawerView.frame.width - 80, height: 48))
        toggleButton.backgroundColor = UIColor.white
        toggleButton.autoresizingMask = [.flexibleHeight,.flexibleLeftMargin,.flexibleRightMargin]
        toggleButton.layer.cornerRadius = 24
        toggleButton.setTitle("Send emojis to Friend", for: .normal)
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
                self?.locationView.alpha = self!.drawerView.frame.origin.y == self!.view.frame.size.height ? 1:0

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
        
        if mapView.selectedAnnotations.count == 0 { return }
        guard let selectedAnnot = mapView.selectedAnnotations[0] as? PersonAnnotation else { return }
        let coord = selectedAnnot.coordinate
        
        let isRouteRequested = goView.walkRoute != nil
        var isRouteToSameUser = true

        if let user = mapView.tagetUserAnnotation?.user, user.uniqueId! != selectedAnnot.user!.uniqueId! {
            isRouteToSameUser = false
        }
        
        if isRouteRequested, isRouteToSameUser {
            return
        }

        setOnMyWay(onMyWay: false)
        
        let centerCoord = mapView.centerCoordinate
        goView.show()
        mapView.set3DCamera(coord: centerCoord, animated: true)
        
        LocationManager.shared.requestRoute(coordinate: coord, type: .walking) { [weak self] route, error in
            guard let route = route else { return }
            self?.goView.walkRoute = route
        }
        
        LocationManager.shared.requestRoute(coordinate: coord, type: .automobile) { [weak self] route, error in
            guard let route = route else { return }
            self?.goView.carRoute = route
        }
        
        LocationManager.shared.requestRoute(coordinate: coord, type: .transit) { [weak self] route, error in
            guard let route = route else { return }
            self?.goView.trainRoute = route
        }
        
        LocationManager.shared.requestRoute(coordinate: coord, type: .walking) { [weak self] route, error in
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
            let routeInset = UIEdgeInsets(top: PersonAnnotationView.pinSize.height+4, left: 20, bottom: 20, right: 20)
            self?.mapView.setVisibleMapRect(route!.polyline.boundingMapRect, edgePadding: routeInset, animated: true)
            
            if going {
                guard let targetUserId = self?.mapView.tagetUserAnnotation?.user.uniqueId else { return }
                self?.sendRouteToUser(route: route!, toUserId: targetUserId)
            }
            

        }
        
        goView.goButtonAction = { [weak self] going in
            
            self?.setOnMyWay(onMyWay: going)
        
        }
        
    }
    
    private func setOnMyWay(onMyWay:Bool) {

        if onMyWay {
            if mapView.selectedAnnotations.count == 0 { return }
            guard let selectedAnnot = mapView.selectedAnnotations[0] as? PersonAnnotation else { return }
            guard let route = mapView.route else { return }
            
            guard let targetUserId = selectedAnnot.user.uniqueId else { return }
            
            mapView.tagetUserAnnotation = selectedAnnot
            
            sendRouteToUser(route: route, toUserId: targetUserId)
        }
        else {
            
            mapView.tagetUserAnnotation = nil
            mapView.route = nil
            goView.setOnMyWayMode(false)
            
            UserManager.shared.update(removeOmw: true)
            
        }
        
        
        
    }
    
    func sendRouteToUser(route:MKRoute, toUserId:String){
        
        let omwDict = OMWOnMyWay.toDataBaseFormat(toUserId: toUserId, type: goView.selectedTransportType, eta: route.expectedTravelTime)
        UserManager.shared.update(omwDictionary: omwDict)
        
    }

    
}

//************************************
// MARK: - Firebase observer
//************************************

extension MapVC {
    
    private func observeUsers() {

        FriendManager.shared.observeFriendAdded { [weak self] in
            self?.mapView.reloadMap(users: FriendManager.shared.friends)
            self?.showFriendOnWayIndicator()
            guard let map = self?.mapView else { return }
            map.showAnnotations(map.annotations, animated: true)
        }
        
        FriendManager.shared.observeFriendChanged { [weak self] in
            self?.mapView.reloadMap(users: FriendManager.shared.friends)
            self?.showFriendOnWayIndicator()
            
        }
        
    }
    
}

