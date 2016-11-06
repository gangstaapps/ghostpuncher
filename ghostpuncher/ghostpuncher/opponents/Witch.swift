//
//  Witch.swift
//  ghostpuncher
//
//  Created by Erik James on 10/22/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class Witch: Opponent {
    init(frame:CGRect, _ multiplier:Int = 1) {
        super.init(frame: frame, name: "witch")
        self.initParams(params: FightParams(params: WitchParams(), multiplier: multiplier))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func returnGlowColor()->SKColor {
        return SKColor.black
    }
    
    
    
    override func comboAttack1(){
        let random = Int(arc4random_uniform(3))
        
        switch  random {
        case 0:
            super.fireballAttack()
        case 1:
            super.multiFireballAttack()
        default:
            super.lightningAttack()
        }
        
    }
    
    
    
    
    override func punchedToHell(){
        self.opponent?.removeAllActions()
        self.head?.removeAllActions()
        self.opponent?.setScale(1.0)
        self.opponent?.alpha = 1.0
        
        self.head?.texture = SKTextureAtlas(named: "\(self.opponentName)Head.atlas").textureNamed("\(self.opponentName)_head_frontopen_punch.png")
        self.leftArm?.texture = SKTextureAtlas(named: "\(self.opponentName)LeftArm.atlas").textureNamed("\(self.opponentName)_left4.png")
        self.rightArm?.texture = SKTextureAtlas(named: "\(self.opponentName)RightArm.atlas").textureNamed("\(self.opponentName)_right3.png")
        
        let scaleMoveGroup:SKAction = SKAction.group([SKAction.scale(to: 0.0, duration: 2.0), SKAction.move(to: CGPoint(x:0, y:0), duration: 2.0)])
        
        self.opponent?.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            scaleMoveGroup, SKAction.run({self.delegate?.ghostIsGone()})
            ]))
    }
    
    
    
    
    override func addGlows(){
        sparkEmmiter = SKEmitterNode(fileNamed: "Smoke.sks")!
        sparkEmmiter?.position = CGPoint(x: 30, y: 200)
        sparkEmmiter?.name = "sparkEmmitter"
        sparkEmmiter?.particleZPosition = -1
        sparkEmmiter?.targetNode = self.opponent!
        sparkEmmiter?.alpha = 0.5
        sparkEmmiter?.particleColor = self.returnGlowColor()
        sparkEmmiter?.particleColorBlendFactor = 1.0
        sparkEmmiter?.particleColorSequence = nil
        sparkEmmiter?.particlePositionRange = CGVector(dx: 40.0, dy: 40.0)
        
        self.opponent?.addChild(sparkEmmiter!)
        
        bodyGlow = SKEmitterNode(fileNamed: "Smoke.sks")!
        bodyGlow?.position = CGPoint(x: 20, y: -40)
        bodyGlow?.name = "sparkEmmitter"
        bodyGlow?.particleZPosition = -1
        bodyGlow?.targetNode = self.opponent!
        bodyGlow?.alpha = 0.5
        bodyGlow?.particleColor = self.returnGlowColor()
        bodyGlow?.particleColorBlendFactor = 1.0
        bodyGlow?.particleColorSequence = nil
        bodyGlow?.particlePositionRange = CGVector(dx: 240.0, dy: 290.0)
        
        self.opponent?.addChild(bodyGlow!)
    }
    
    override func spark(_ direction:Direction, _ power:CGFloat){
        
        let sparkEmmiter = SKEmitterNode(fileNamed: "devilBlood.sks")!
        sparkEmmiter.position = CGPoint(x: (direction == .right ? -30 : 30), y: -5)
        sparkEmmiter.name = "devilBlood"
        sparkEmmiter.zPosition = 1200
        sparkEmmiter.targetNode = self.head!
        sparkEmmiter.particleLifetime = 3
        sparkEmmiter.particleColor = SKColor.blue
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
