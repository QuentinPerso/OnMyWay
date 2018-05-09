//
//  FriendsManager.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 09/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class FriendManager: NSObject {
    
    private var userAddRefHandle: DatabaseHandle?
    private var userChangeRefHandle: DatabaseHandle?
    private lazy var userRef: DatabaseReference = Database.database().reference().child("users")
    
    public var friends = [OMWUser]()
    
    static let shared = FriendManager()
    private override init(){ super.init() }
    
    
    deinit {
        if let refHandle = userAddRefHandle { userRef.removeObserver(withHandle: refHandle) }
        if let refHandle = userChangeRefHandle { userRef.removeObserver(withHandle: refHandle) }
    }
    
    public func observeFriendAdded(completion:(()->())?) {
        
        userAddRefHandle = userRef.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            self?.updateUsersOnFirebaseEvent(snapshot)
            completion?()
        })
        
        
    }
    
    public func observeFriendChanged(completion:(()->())?) {
        
        userAddRefHandle = userRef.observe(.childChanged, with: { [weak self] (snapshot) -> Void in
            self?.updateUsersOnFirebaseEvent(snapshot)
            completion?()
        })
        
        
    }
    
    private func updateUsersOnFirebaseEvent(_ snapshot:DataSnapshot) {
        
        let userData = snapshot.value as! Dictionary<String, AnyObject>
        let id = snapshot.key
        if id != UserManager.shared.userId {
            
            let user = OMWUser(dictionary: userData)
            if user.coordinates == nil { return }
            if friends.contains(user){
                friends.remove(user)
            }
            friends.append(user)
            
            
        }
        
    }
    
    
}
