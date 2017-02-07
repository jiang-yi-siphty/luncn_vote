//
//  LVConstant.swift
//  LunchVote
//
//  Created by Yi JIANG on 5/2/17.
//  Copyright © 2017 RobertYiJiang. All rights reserved.
//

import Foundation
import CoreLocation

public struct LVConstant {
    
    public static let sharedInstance = LVConstant()

    struct LVPlist {
        static let PlistName = "LVKeyList"
        
    }
    
    struct Beacon {
        static let majorValue: CLBeaconMajorValue = 0
        static let minorValue: CLBeaconMinorValue = 0
        static let name: String = "LunchVote"
        static let uuid: UUID = NSUUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")! as UUID
    }
}
