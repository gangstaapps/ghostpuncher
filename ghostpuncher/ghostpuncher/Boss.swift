//
//  Boss.swift
//  ghostpuncher
//
//  Created by Erik James on 11/2/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class Boss: Opponent {
    init(frame:CGRect, _ multiplier:Int = 1) {
        super.init(frame: frame, name: "boss")
        self.initParams(params: FightParams(params: BossParams(), multiplier: multiplier))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func returnGlowColor()->SKColor {
        return SKColor.purple
    }
    
    override func comboAttack1(){
        let random = Int(arc4random_uniform(4))
            
        switch  random {
        case 0:
            super.fireballAttack()
        case 1:
            super.multiFireballAttack()
        case 2:
            super.lightningAttack()
        default:
            super.comboAttack1()
        }
        
    }
    
    override func spark(_ direction:Direction, _ power:CGFloat){
        
        let sparkEmmiter = SKEmitterNode(fileNamed: "devilBlood.sks")!
        sparkEmmiter.position = CGPoint(x: (direction == .right ? -30 : 30), y: -5)
        sparkEmmiter.name = "devilBlood"
        sparkEmmiter.zPosition = 1200
        sparkEmmiter.targetNode = self.head!
        sparkEmmiter.particleLifetime = 3
        sparkEmmiter.particleColor = SKColor.orange
        sparkEmmiter.particleColorBlendFactor = 1.0
        sparkEmmiter.alpha = 1.0
        sparkEmmiter.particleBlendMode = SKBlendMode.alpha
        sparkEmmiter.particleColorSequence = nil
        sparkEmmiter.emissionAngle = (CGFloat(direction == .right ? 180.0.radiansToDegrees : 0.0.radiansToDegrees))
        sparkEmmiter.xAcceleration = (direction == .right ? -900 : 900)
        sparkEmmiter.numParticlesToEmit = Int(power.multiplied(by: 10))
        
        
        self.head?.addChild(sparkEmmiter)
    }
}
