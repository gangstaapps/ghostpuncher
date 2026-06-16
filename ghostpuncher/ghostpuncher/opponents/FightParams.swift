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
            return  self.opponentParams.fullPowerPunch[self.multiplier - 1] * CGFloat(BattleManager.multiplier)
        }
    }
    var blockedHit:CGFloat {
        get {
            return  self.opponentParams.blockedPunch[self.multiplier - 1] * CGFloat(BattleManager.multiplier)
        }
    }
    var attackAggression:CGFloat {
        get {
            return self.opponentParams.attackAggression[self.multiplier - 1]
        }
    }
    var comboAggression:Int {
        get {
            return self.opponentParams.comboAggression[self.multiplier - 1]
        }
    }
    var dodgeFrequency:Int {
        get {
            return self.opponentParams.dodgeFrequency[self.multiplier - 1]
        }
    }
    var comboFrequency:Int {
        get {
            return self.comboAggression * 10
        }
    }
}

class GhostParams:FightParamProto {
    let fullPowerPunch: [CGFloat] = [4.5, 5.2, 6.0]
    let blockedPunch: [CGFloat] = [0.8, 1.0, 1.4]
    let attackAggression:[CGFloat] = [5,4,3]
    let comboAggression:[Int] = [5,4,3]
    let dodgeFrequency:[Int] = [3,3,3]
}

class WitchParams:FightParamProto {
    let fullPowerPunch: [CGFloat] = [5.0, 6.0, 7.0]
    let blockedPunch: [CGFloat] = [1.2, 1.4, 1.8]
    let attackAggression:[CGFloat] = [5,4,3]
    let comboAggression:[Int] = [4,3,2]
    let dodgeFrequency:[Int] = [3,3,3]
}

class DevilParams:FightParamProto {
    let fullPowerPunch: [CGFloat] = [5.5, 6.5, 7.5]
    let blockedPunch: [CGFloat] = [1.4, 1.6, 1.8]
    let attackAggression:[CGFloat] = [5,3,3]
    let comboAggression:[Int] = [4,3,2]
    let dodgeFrequency:[Int] = [3,3,3]
}

class BossParams:FightParamProto {
    let fullPowerPunch: [CGFloat] = [0,0,0,8.5]
    let blockedPunch: [CGFloat] = [0,0,0,2.0]
    let attackAggression:[CGFloat] = [0,0,0,2]
    let comboAggression:[Int] = [0,0,0,2]
    let dodgeFrequency:[Int] = [0,0,0,3]
}

