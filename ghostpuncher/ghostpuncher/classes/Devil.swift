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
    
    override func hitRecoil(_ direction:Direction, power:CGFloat){
        self.opponent.alpha = 1.0
        let moveAmount = power * 2
        
        if self.opponent.action(forKey: MOVEMENT_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        if self.opponent.action(forKey: COMBO_ATTACK_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        
        let scaleDown:SKAction
        let headAnimation:SKAction
        
        if power > 8 {
            scaleDown = SKAction.scale(to: 0.85, duration: 0.3)
            if abs(self.opponent.position.x) > 30 {
                headAnimation = direction == .right ? self.headRightPunchAnimationSlow! : self.headLeftPunchAnimationSlow!
            } else {
                headAnimation = self.headFrontPunchAnimationSlow!
            }
            
        } else {
            scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
            if abs(self.opponent.position.x) > 30 {
                headAnimation = direction == .right ? self.headRightPunchAnimation! : self.headLeftPunchAnimation!
            } else {
                headAnimation = self.headFrontPunchAnimation!
            }
        }
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.2)
        
        let sequence = SKAction.sequence([scaleDown, scaleUp])
    
        
        let headRotate1 = SKAction.rotate(byAngle: (direction == .right ? CGFloat(power).degreesToRadians : CGFloat(-power).degreesToRadians), duration: 0.1)
        let headRotate2 = SKAction.rotate(toAngle: CGFloat(0).degreesToRadians, duration: 0.1)
        let headSequence = SKAction.group([SKAction.sequence([headRotate1, headRotate2]),  headAnimation])
        
        self.head?.run(headSequence)
        
        let bodyRotate1 = SKAction.rotate(byAngle: (direction == .right ? CGFloat(1).degreesToRadians : CGFloat(-1).degreesToRadians), duration: 0.1)
        let bodyRotate2 = SKAction.rotate(toAngle: CGFloat(0).degreesToRadians, duration: 0.1)
        let bodySequence = SKAction.sequence([bodyRotate1, bodyRotate2])
        
        self.body?.run(bodySequence)
        
        
        let leftArmRotate1 = SKAction.rotate(byAngle: (direction == .right ? CGFloat(moveAmount).degreesToRadians : CGFloat(-moveAmount).degreesToRadians), duration: 0.1)
        let leftArmRotate2 = SKAction.rotate(toAngle: CGFloat(0).degreesToRadians, duration: 0.2)
        let leftArmSequence = SKAction.sequence([leftArmRotate1, leftArmRotate2])
        
        self.leftArm?.run(leftArmSequence)
        self.rightArm?.run(leftArmSequence)
        
        self.opponent?.run(SKAction.group([sequence, SKAction.moveBy(x: (direction == .right ? -moveAmount : moveAmount), y: 0, duration: 0.1)]), withKey: MOVEMENT_KEY )
        
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
        
//        let sparkEmmiter = SKEmitterNode(fileNamed: "ectoPlasm.sks")!
//        sparkEmmiter.position = CGPoint(x: (direction == .right ? -30 : 30), y: 25)
//        sparkEmmiter.name = "sparkEmmitter"
//        sparkEmmiter.zPosition = 200
//        sparkEmmiter.targetNode = self
//        sparkEmmiter.particleLifetime = 3
//        sparkEmmiter.particleColor = SKColor.red
//        sparkEmmiter.particleColorBlendFactor = 1.0
//        sparkEmmiter.alpha = 1.0
//        sparkEmmiter.particleBlendMode = SKBlendMode.alpha
//        sparkEmmiter.particleColorSequence = nil
//        sparkEmmiter.emissionAngle = (CGFloat(direction == .right ? 180.0.radiansToDegrees : 0.0.radiansToDegrees))
//        sparkEmmiter.xAcceleration = (direction == .right ? -900 : 900)
//        sparkEmmiter.numParticlesToEmit = Int(power.multiplied(by: 10))
//        
//        
//        self.head?.addChild(sparkEmmiter)
    }
    
    override func returnGlowColor()->SKColor {
        return SKColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
