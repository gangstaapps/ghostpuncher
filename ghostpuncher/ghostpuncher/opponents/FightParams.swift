//
//  FightParams.swift
//  ghostpuncher
//
//  Created by Erik James on 10/27/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

protocol FightParamProto {
    var fullPowerPunch:CGFloat { get }
    var blockedPunch:CGFloat { get }
    var attackAggression:CGFloat { get } // the lower the number the more aggressive
    var comboAggression:Int { get } // the lower the number the more aggressive
    var dodgeFrequency:Int { get } // the lower the number the more dodging
    
}

struct FightParams {
    var multiplier:Int
    var opponentParams:FightParamProto
    init(params:FightParamProto, multiplier:Int){
        self.multiplier = multiplier
        self.opponentParams = params
    }
    var fullPowerHit:CGFloat {
        get {
            return  self.opponentParams.fullPowerPunch
        }
    }
    var blockedHit:CGFloat {
        get {
            return  self.opponentParams.blockedPunch
        }
    }
    var attackAggression:CGFloat {
        get {
            return self.opponentParams.attackAggression/CGFloat(self.multiplier)
        }
    }
    var comboAggression:Int {
        get {
            return Int(self.opponentParams.comboAggression/self.multiplier)
        }
    }
    var dodgeFrequency:Int {
        get {
            return self.opponentParams.dodgeFrequency
        }
    }
    var comboFrequency:Int {
        get {
            return self.comboAggression * 10
        }
    }
}

class GhostParams:FightParamProto {
    var fullPowerPunch: CGFloat = 2.0
    var blockedPunch: CGFloat = 0.5
    var attackAggression:CGFloat = 4.5
    var comboAggression:Int = 10
    var dodgeFrequency:Int = 3
}

class WitchParams:FightParamProto {
    var fullPowerPunch: CGFloat = 3.0
    var blockedPunch: CGFloat = 1.0
    var attackAggression:CGFloat = 3.5
    var comboAggression:Int = 9
    var dodgeFrequency:Int = 3
}

class DevilParams:FightParamProto {
    var fullPowerPunch: CGFloat = 4.0
    var blockedPunch: CGFloat = 1.5
    var attackAggression:CGFloat = 3.0
    var comboAggression:Int = 8
    var dodgeFrequency:Int = 2
}

