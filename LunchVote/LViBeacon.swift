//
//  LViBeacon.swift
//  LunchVote
//
//  Created by Yi JIANG on 6/2/17.
//  Copyright © 2017 RobertYiJiang. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

public final class iBeacon:NSObject {
    public static let sharedInstance = iBeacon()
    
    public static var localBeacon: CLBeaconRegion!
    public static var beaconPeripheralData: NSDictionary!
    public static var peripheralManager: CBPeripheralManager!
    public static let locationManager = CLLocationManager()
    
    public class func beaconRegion() -> CLBeaconRegion {
        let beaconRegion = CLBeaconRegion(proximityUUID: LVConstant.Beacon.uuid,
                                          major: LVConstant.Beacon.majorValue,
                                          minor: LVConstant.Beacon.minorValue,
                                          identifier: LVConstant.Beacon.name)
        return beaconRegion
    }
}
//
//
//extension iBeacon: CBPeripheralManagerDelegate{
//    
//    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
//        if peripheral.state == .poweredOn {
//            iBeacon.peripheralManager.startAdvertising(iBeacon.beaconPeripheralData as! [String: AnyObject]!)
//        } else if peripheral.state == .poweredOff {
//            iBeacon.peripheralManager.stopAdvertising()
//        }
//    }
//    
//}
