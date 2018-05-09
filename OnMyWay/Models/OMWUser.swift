//
//  OMWUser.swift
//  OnMyWay
//
//  Created by Quentin Beaudouin on 04/05/2018.
//  Copyright © 2018 Quentin Beaudouin. All rights reserved.
//

import Foundation
import CoreLocation

enum TransportType:String {
    case walk    = "walk"
    case car     = "car"
    case transit = "transit"
    case bike    = "bike"
    
    static let allValues = [walk, car, transit, bike]
}

class OMWUser: NSObject{
    
    private static let kId = "uniqueid"
    private static let kName = "userName"
    private static let kCoord = "coordinates"
    public static let kOMW = "onMyWay"
    
    var uniqueId: String!
    var name: String!
    var coordinates:CLLocationCoordinate2D!
    var omw:OMWOnMyWay?
    
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? OMWUser { return self.uniqueId == object.uniqueId }
        return false
    }
    
    init(dictionary:[String : AnyObject]) {
    
        super.init()
        uniqueId = dictionary[OMWUser.kId] as! String
        name = dictionary[OMWUser.kName] as! String
        if let coordDict = dictionary[OMWUser.kCoord] as? [String : AnyObject] {
            coordinates = CLLocationCoordinate2D(dictionary: coordDict)
        }
        
        if let omwDict = dictionary[OMWUser.kOMW] as? [String : AnyObject] {
            let onAWay = OMWOnMyWay(dictionary: omwDict)
            if onAWay.toUser == UserManager.shared.userId {
                omw = onAWay
            }
        }
    }
    
    init(id:String, nam:String) {
        
        super.init()
        uniqueId = id
        name = nam

    }
    
    static func toDataBaseFormat(uniqueId:String? = nil,
                                 name:String? = nil,
                                 coordinates:CLLocationCoordinate2D? = nil,
                                 omw:[String : Any]? = nil) -> [String:Any]
    {
        
        var dict:[String:Any] = [:]
        
        if let name = name {
            dict[kName] = name
        }
        if let id = uniqueId {
            dict[kId] = id
        }
        
        if let coord = coordinates {
            dict[kCoord] = ["lat":coord.latitude, "lng": coord.longitude]
        }
        
        if let omwDict = omw {
            dict[kOMW] = omwDict
        }
        
        return dict
        
    }
    
}

class OMWOnMyWay:NSObject {
    
    private static let kToUser = "toUser"
    private static let kType = "transportType"
    private static let kEta = "estimatedArrival"
    
    var toUser: String!
    var transportType: TransportType!
    var estimatedArrival:Int!
    
    init(dictionary:[String : AnyObject]) {
        
        toUser = dictionary[OMWOnMyWay.kToUser] as! String
        
        transportType = TransportType(rawValue: dictionary[OMWOnMyWay.kType] as! String)
        
        estimatedArrival = dictionary[OMWOnMyWay.kEta] as! Int
   
    }
    
    static func toDataBaseFormat(toUserId:String, type:TransportType, eta:Double) -> [String : Any] {
        
        return [kToUser: toUserId,
                kType: type.rawValue,
                kEta: eta] as [String : Any]
        
        
    }
    
}


extension CLLocationCoordinate2D {
    
    init(dictionary:[String : AnyObject]) {
        if let lat = dictionary["lat"] as? Double, let lng = dictionary["lng"] as? Double {
            self.init(latitude: lat, longitude: lng)
        }
        else {
            self.init()
        }
        
    }
    
}
