//
//  UserManager.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 08/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import Foundation
import Firebase


class UserManager: NSObject {
    
    
    
    private lazy var userRef: DatabaseReference = Database.database().reference().child("users")
    
    public var user:OMWUser!
    
    static let shared = UserManager()
    private override init(){ super.init() }
    
    public func connect(name:String, completion:((_ success:Bool)->())?) {
        
        Auth.auth().signInAnonymously(completion: { [weak self] (user, error) in
            if let err:Error = error {
                print(err.localizedDescription)
                completion?(false)
                return
            }
            guard let id = user?.uid else { return }
            self?.createRemoteUser(name: name, id: id)
            completion?(true)
            
        })
        
    }
    
    public func createRemoteUser(name:String, id:String) {
        let itemRef = self.userRef.child(id)
        let userItem = OMWUser.toDataBaseFormat(uniqueId: id, name: name)
        itemRef.setValue(userItem)
    }
    
    
    public func updateOnMyWayStatus() {
        
    }
    
    
}
