//
//  LVCacheManager.swift
//  LunchVote
//
//  Created by Yi JIANG on 5/2/17.
//  Copyright © 2017 RobertYiJiang. All rights reserved.
//

import Foundation

public final class LVCacheManager {
    
    static let sharedInstance = LVCacheManager()

    var multipeerConnectServiceType: String?
    var multipeerConnectLocalPeerId: String?
    var multipeerConnect = MultipeerConnect()
    
    var isBeaconNearBy: Bool?
    
}

struct MultipeerConnect {
    var ServiceType: String?
    var LocalPeerId: String? = "emptyPeerId"
}
