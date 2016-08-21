//
//  IJReachability.swift
//  IJReachability
//
//  Created by Isuru Nanayakkara on 1/14/15.
//  Copyright (c) 2015 Appex. All rights reserved.
//
// Adapted for Swift 2.0 by Adil Ben Moussa ttps://github.com/adilbenmoussa.
//

import Foundation
import SystemConfiguration

public enum IJReachabilityType {
    case WWAN,
    WiFi,
    NotConnected
}

struct NetworkStatusConstants  {
    static let kNetworkAvailabilityStatusChangeNotification = "kNetworkAvailabilityStatusChangeNotification"
    static let Status = "Status"
    static let Offline = "Offline"
    static let Online = "Online"
    static let Unknown = "Unknown"
}

public class IJReachability {
    
    /**
    :see: Original post - http://www.chrisdanielson.com/2009/07/22/iphone-network-connectivity-test-example/
    */
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        return (isReachable && !needsConnection)
    }
    
    public class func isConnectedToNetworkOfType() -> IJReachabilityType {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return .NotConnected
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return .NotConnected
        }
        
        let isReachable = flags.contains(.Reachable)
        let isWWAN = flags.contains(.IsWWAN)
        
        if(isReachable && isWWAN){
            return .WWAN
        }
        if(isReachable && !isWWAN){
            return .WiFi
        }
        
        return .NotConnected
    }
    
    class func monitorNetworkChanges() {
        
        let host = "google.com"
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let reachability = SCNetworkReachabilityCreateWithName(nil, host)!
        
        SCNetworkReachabilitySetCallback(reachability, { (_, flags, _) in
            
            let status:String?
            
            if !flags.contains(SCNetworkReachabilityFlags.ConnectionRequired) && flags.contains(SCNetworkReachabilityFlags.Reachable) {
                status = NetworkStatusConstants.Online
            } else {
                status =  NetworkStatusConstants.Offline
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(NetworkStatusConstants.kNetworkAvailabilityStatusChangeNotification,
                object: nil,
                userInfo: [NetworkStatusConstants.Status: status!])
            
            }, &context)
        
        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes)
    }
    
}
