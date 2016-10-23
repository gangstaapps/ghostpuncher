//
//  Witch.swift
//  ghostpuncher
//
//  Created by Erik James on 10/22/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class Witch: Opponent {
    init(frame:CGRect) {
        super.init(frame: frame, name: "witch")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func returnGlowColor()->SKColor {
        return SKColor.blue
    }
    
    override func comboAttack1(){
        self.addEvent(event: .nothing)
        
        if self.opponent.action(forKey: MOVEMENT_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        if self.opponent.action(forKey: COMBO_ATTACK_KEY) != nil {
            self.opponent.removeAction(forKey: COMBO_ATTACK_KEY)
        }
        
        
//        sparkEmmiter.particleLifetime = 3
//        sparkEmmiter.emissionAngle = (CGFloat(direction == .right ? 180.0.radiansToDegrees : 0.0.radiansToDegrees))
//        sparkEmmiter.xAcceleration = (direction == .right ? -900 : 900)
//        sparkEmmiter.numParticlesToEmit = Int(power.multiplied(by: 10))
        self.delegate?.turnOffLights()
        
        
        
        let sequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run({
                self.head?.texture = SKTextureAtlas(named: "\(self.opponentName)Head.atlas").textureNamed("\(self.opponentName)_head_frontopen_punch.png")
            }),
            SKAction.wait(forDuration: 0.5),
            SKAction.run({
                self.block?.texture = SKTexture(imageNamed: "\(self.opponentName)_grapple")
                self.block?.isHidden = false
                self.leftArm?.isHidden = true
                self.rightArm?.isHidden = true
            }),
            SKAction.wait(forDuration: 0.5),
            SKAction.sequence([
                    SKAction.run({
                        let sparkEmmiter = SKEmitterNode(fileNamed: "FireBall.sks")!
                        sparkEmmiter.position = CGPoint(x:0, y:200)
                        sparkEmmiter.name = "fireBall"
                        sparkEmmiter.zPosition = 200
                        sparkEmmiter.targetNode = self
                        self.body?.addChild(sparkEmmiter)
                        sparkEmmiter.run(SKAction.scale(to: 4.0, duration: 0.5))
                    }),
                    SKAction.wait(forDuration: 0.3),
                    SKAction.run({
                        self.delegate?.explosion()
                        self.block?.texture = SKTexture(imageNamed: "\(self.opponentName)_block")
                        self.block?.isHidden = true
                        self.leftArm?.isHidden = false
                        self.rightArm?.isHidden = false
                        self.delegate?.turnOnLights()
                    })
                ])
            ])
        
        self.opponent?.run(sequence , withKey:COMBO_ATTACK_KEY)
    }
}
