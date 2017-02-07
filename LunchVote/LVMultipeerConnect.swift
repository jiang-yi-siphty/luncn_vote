//
//  LVMultipeerConnect.swift
//  LunchVote
//
//  Created by Yi JIANG on 5/2/17.
//  Copyright © 2017 RobertYiJiang. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth
import MultipeerConnectivity

public final class LVMultipeerConnection {
    public static let sharedInstance = LVMultipeerConnection()
    
    public static var session: MCSession!
    
    public static var peer: MCPeerID!
    
    public static var browser: MCNearbyServiceBrowser!
    
    public static var advertiser: MCNearbyServiceAdvertiser!
}
