//
//  OMWUser.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 04/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

enum TransportType:String {
    case walk    = "walk"
    case car     = "car"
    case transit = "transit"
    case bike    = "bike"
    
    static let allValues = [walk, car, transit, bike]
}

class OMWUser: NSObject, NSCoding {
    
    var uniqueId: String!
    var name: String!
    var coordinates:CLLocationCoordinate2D!
    var estimatedArrival:Int?
    var transportType:TransportType?
    
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? OMWUser { return self.uniqueId == object.uniqueId }
        return false
    }
    
    init(dictionary:[String : AnyObject]) {
        // these properties can't be changed after this init.
        self.uniqueId = dictionary["uniqueid"] as! String
        self.name = dictionary["userName"] as! String
        if let coordDict = dictionary["coordinates"] as? [String : AnyObject] {
            if let lat = coordDict["lat"] as? Double, let lng = coordDict["lng"] as? Double {
                self.coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            }
        }
        
        if let omwDict = dictionary["onMyWay"] as? [String : AnyObject] {
            if let toUser = omwDict["toUser"] as? String, let myId = Auth.auth().currentUser?.uid {
                if toUser == myId {
                    if let transportType = omwDict["transportType"] as? String {
                        self.transportType = TransportType(rawValue: transportType)
                    }
                    self.estimatedArrival = omwDict["estimatedArrival"] as? Int
                }
            }
        }
        
        
        
        
        
        super.init()
        
        
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(uniqueId, forKey: "uniqueId")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        self.uniqueId = aDecoder.decodeObject(forKey: "uniqueId") as? String
        super.init()
    }
    
    
    
}
