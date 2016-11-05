//
//  Devil.swift
//  ghostpuncher
//
//  Created by Erik James on 10/24/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class Devil: Opponent {
    
    let batwingCycle:SKAction
    var batwings:SKSpriteNode?
    
    init(frame:CGRect, _ multiplier:Int = 1) {
        let batwingAtlas = SKTextureAtlas(named: "batwing.atlas")
        let batwingFrames:[SKTexture] = [batwingAtlas.textureNamed("batwing1.png"),
                                         batwingAtlas.textureNamed("batwing2.png"),
                                         batwingAtlas.textureNamed("batwing3.png")]
        batwingCycle = SKAction.animate(with: batwingFrames, timePerFrame: 0.1)
//        batwings = SKSpriteNode(texture: batwingFrames[0])
        super.init(frame: frame, name: "devil")
        
        self.batwings = self.body?.childNode(withName: "wings") as! SKSpriteNode?
        self.batwings?.isHidden = true
        self.initParams(params: FightParams(params: DevilParams(), multiplier: multiplier))
    }
    
    override func addGlows(){
        sparkEmmiter = SKEmitterNode(fileNamed: "DevilFlames.sks")!
        sparkEmmiter?.position = CGPoint(x: 10, y: 200)
        sparkEmmiter?.name = "sparkEmmitter"
        sparkEmmiter?.particleZPosition = -2
        sparkEmmiter?.targetNode = self.opponent!
        sparkEmmiter?.alpha = 0.25
        sparkEmmiter?.particleAlpha = 0.5
//        sparkEmmiter?.particleColor = self.returnGlowColor()
//        sparkEmmiter?.particleColorBlendFactor = 1.0
//        sparkEmmiter?.particleColorSequence = nil
        sparkEmmiter?.particlePositionRange = CGVector(dx: 40.0, dy: 40.0)
        
        self.opponent?.addChild(sparkEmmiter!)
        
        bodyGlow = SKEmitterNode(fileNamed: "DevilFlames.sks")!
        bodyGlow?.position = CGPoint(x: 0, y: 10)
        bodyGlow?.name = "sparkEmmitter"
        bodyGlow?.particleZPosition = -2
        bodyGlow?.targetNode = self.opponent!
        bodyGlow?.particleAlpha = 0.5
        bodyGlow?.alpha = 0.25
//        bodyGlow?.particleColor = self.returnGlowColor()
//        bodyGlow?.particleColorBlendFactor = 1.0
//        bodyGlow?.particleColorSequence = nil
        bodyGlow?.particlePositionRange = CGVector(dx: 240.0, dy: 290.0)
        
        self.opponent?.addChild(bodyGlow!)
    }
    
    override func comboAttack1(){
        self.addEvent(event: .ghostComboAttack1)
        self.batwings?.isHidden = false
        self.batwings?.run(self.batwingCycle)
        
        if self.opponent.action(forKey: MOVEMENT_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        if self.opponent.action(forKey: COMBO_ATTACK_KEY) != nil {
            self.opponent.removeAction(forKey: COMBO_ATTACK_KEY)
        }
        
        
        
        let startPos = self.opponent.position
        
        self.delegate?.turnOffLights()
        self.opponent.position = startPosition
        
        
        let scaleUp = SKAction.scale(to: 2.0, duration: 0.2)
        let fadeUp = SKAction.fadeAlpha(to: 0.9, duration: 0.3)
        let moveIn = SKAction.moveBy(x: startPosition.x, y: startPosition.y - 100, duration: 0.2)
        let group1 = SKAction.group([SKAction.run({ self.head?.texture = SKTextureAtlas(named: "\(self.opponentName)Head.atlas").textureNamed("\(self.opponentName)_head_uppercut.png") }),scaleUp, fadeUp,moveIn,
                                     SKAction.run({ self.delegate?.superAttack() })])
        
        let attackLeft = SKAction.sequence([SKAction.run({ self.delegate?.opponentAttackLeft() }), SKAction.wait(forDuration: 0.3)])
        let attackRight = SKAction.sequence([SKAction.run({ self.delegate?.opponentAttackRight() }), SKAction.wait(forDuration: 0.3)])
        let lightsOn = SKAction.run({self.delegate?.turnOnLights()})
        
        
        let attack = SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.run({ self.opponent.setScale(0.0) }), SKAction.wait(forDuration: 3.0), group1, SKAction.run({ self.opponent.position = startPos }), attackLeft, attackRight,attackLeft,attackRight,attackLeft,attackRight,attackLeft,attackRight,lightsOn,SKAction.scale(to: 1.0, duration: 0.2),SKAction.fadeIn(withDuration: 0.1),
                                        SKAction.run({
                                            self.batwings?.run(SKAction.sequence([self.batwingCycle.reversed(),
                                                                                  SKAction.run({
                                                                                    self.batwings?.isHidden = true
                                                                                  })]))
                                            
                                        })])
        
        
        
        
        self.opponent.run(attack, withKey:COMBO_ATTACK_KEY)
        
    }
    
    override func willLeftComboConnect() -> Bool {
        let willConnect = super.willLeftComboConnect()
        
        if willConnect {
            self.batwings?.run(SKAction.sequence([self.batwingCycle.reversed(),
                                                  SKAction.run({
                                                    self.batwings?.isHidden = true
                                                  })]))
        }
        
        return willConnect
    }
    override func willRightComboConnect() -> Bool {
        let willConnect = super.willRightComboConnect()
        
        if willConnect {
            self.batwings?.run(SKAction.sequence([self.batwingCycle.reversed(),
                                                  SKAction.run({
                                                    self.batwings?.isHidden = true
                                                  })]))
        }
        
        return willConnect
    }
    
    override func spark(_ direction:Direction, _ power:CGFloat){
        
        let sparkEmmiter = SKEmitterNode(fileNamed: "devilBlood.sks")!
        sparkEmmiter.position = CGPoint(x: (direction == .right ? -30 : 30), y: -5)
        sparkEmmiter.name = "devilBlood"
        sparkEmmiter.zPosition = 1200
        sparkEmmiter.targetNode = self.head!
//        sparkEmmiter.particleLifetime = 3
//        sparkEmmiter.particleColor = SKColor.red
//        sparkEmmiter.particleColorBlendFactor = 1.0
//        sparkEmmiter.alpha = 1.0
//        sparkEmmiter.particleBlendMode = SKBlendMode.alpha
//        sparkEmmiter.particleColorSequence = nil
        sparkEmmiter.emissionAngle = (CGFloat(direction == .right ? 180.0.radiansToDegrees : 0.0.radiansToDegrees))
        sparkEmmiter.xAcceleration = (direction == .right ? -900 : 900)
        sparkEmmiter.numParticlesToEmit = Int(power.multiplied(by: 10))
        
        
        self.head?.addChild(sparkEmmiter)
    }
    
    override func returnGlowColor()->SKColor {
        return SKColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
