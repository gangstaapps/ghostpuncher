//
//  FightParams.swift
//  ghostpuncher
//
//  Created by Erik James on 10/27/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

protocol FightParamProto {
    var fullPowerPunch:[CGFloat] { get }
    var blockedPunch:[CGFloat] { get }
    var attackAggression:[CGFloat] { get } // the lower the number the more aggressive
    var comboAggression:[Int] { get } // the lower the number the more aggressive
    var dodgeFrequency:[Int] { get } // the lower the number the more dodging
    
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
            return  self.opponentParams.fullPowerPunch[self.multiplier]
        }
    }
    var blockedHit:CGFloat {
        get {
            return  self.opponentParams.blockedPunch[self.multiplier]
        }
    }
    var attackAggression:CGFloat {
        get {
            return self.opponentParams.attackAggression[self.multiplier]
        }
    }
    var comboAggression:Int {
        get {
            return self.opponentParams.comboAggression[self.multiplier]
        }
    }
    var dodgeFrequency:Int {
        get {
            return self.opponentParams.dodgeFrequency[self.multiplier]
        }
    }
    var comboFrequency:Int {
        get {
            return self.comboAggression * 10
        }
    }
}

class GhostParams:FightParamProto {
    let fullPowerPunch: [CGFloat] = [2.0, 2.5, 3.0]
    let blockedPunch: [CGFloat] = [0.5, 0.5, 1.0]
    let attackAggression:[CGFloat] = [8,7,7]
    let comboAggression:[Int] = [6,5,4]
    let dodgeFrequency:[Int] = [3,3,3]
}

class WitchParams:FightParamProto {
    let fullPowerPunch: [CGFloat] = [3.0, 3.5, 4.0]
    let blockedPunch: [CGFloat] = [1.0, 1.0, 1.5]
    let attackAggression:[CGFloat] = [7,6,6]
    let comboAggression:[Int] = [5,4,3]
    let dodgeFrequency:[Int] = [3,3,3]
}

class DevilParams:FightParamProto {
    let fullPowerPunch: [CGFloat] = [3.5,3.5, 4.0]
    let blockedPunch: [CGFloat] = [1.0, 1.0, 1.5]
    let attackAggression:[CGFloat] = [6,5,5]
    let comboAggression:[Int] = [5,4,3]
    let dodgeFrequency:[Int] = [3,3,3]
}

class BossParams:FightParamProto {
    let fullPowerPunch: [CGFloat] = [0,0,0,4.0]
    let blockedPunch: [CGFloat] = [0,0,0,1.5]
    let attackAggression:[CGFloat] = [0,0,0,5]
    let comboAggression:[Int] = [0,0,0,3]
    let dodgeFrequency:[Int] = [0,0,0,3]
}

