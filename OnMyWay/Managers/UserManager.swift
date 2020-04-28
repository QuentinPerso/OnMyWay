//
//  UserManager.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 08/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation


class UserManager {

    private lazy var userRef: DatabaseReference = Database.database().reference().child("users")
    
    public var userId:String? {
        return Auth.auth().currentUser?.uid
    }
 //   public var user:OMWUser!
    static let shared = UserManager()
    
    public func connect(name:String, completion:((_ success:Bool)->())?) {
        
        Auth.auth().signInAnonymously(completion: { [weak self] (user, error) in
            if let err:Error = error {
                print(err.localizedDescription)
                completion?(false)
                return
            }
            guard let id = user?.uid else { return }
            //self?.user = OMWUser(id: id, nam: name)
            
            self?.createRemoteUser(name: name, id: id)
            completion?(true)
            
        })
        
    }
    
    public func createRemoteUser(name:String, id:String) {
        let itemRef = self.userRef.child(id)
        let userItem = OMWUser.toDataBaseFormat(uniqueId: id, name: name)
        itemRef.setValue(userItem)
    }
    
    
    public func update(name:String? = nil,
                       coordinate:CLLocationCoordinate2D? = nil,
                       omwDictionary:[String : Any]? = nil,
                       removeOmw:Bool = false) {
        
        guard let userId = UserManager.shared.userId else { return }
        
        let itemRef = userRef.child(userId)
        
        if removeOmw {
            itemRef.child(OMWUser.kOMW).removeValue()
            return
        }
//        if let coord = coordinate {
//            user.coordinates = coord
//        }
//        if name != nil {
//            user.name = name
//        }
//        if omwDictionary != nil {
//            user.omw = OMWOnMyWay(dictionary: omwDictionary! as [String : AnyObject])
//        }
        let userNewValues = OMWUser.toDataBaseFormat(uniqueId: nil, name: name, coordinates: coordinate, omw: omwDictionary)

        itemRef.updateChildValues(userNewValues)
    }
    
    
}


