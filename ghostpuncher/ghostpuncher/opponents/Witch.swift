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
    
    override func returnFullPowerHit()->CGFloat
    {
        return 4.0
    }
    
    override func returnBlockedHit()->CGFloat
    {
        return 1.0
    }
    
    override func comboAttack1(){
        self.addEvent(event: .nothing)
        
        if self.opponent.action(forKey: MOVEMENT_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        if self.opponent.action(forKey: COMBO_ATTACK_KEY) != nil {
            self.opponent.removeAction(forKey: COMBO_ATTACK_KEY)
        }
        
        self.delegate?.turnOffLights()
        self.opponent?.alpha = 1.0
        
        
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
                        self.fireball(pos: CGPoint(x: 0, y: 200))
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
    
    func comboAttack2(){
        self.addEvent(event: .nothing)
        
        if self.opponent.action(forKey: MOVEMENT_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        if self.opponent.action(forKey: COMBO_ATTACK_KEY) != nil {
            self.opponent.removeAction(forKey: COMBO_ATTACK_KEY)
        }
        
//        self.delegate?.turnOffLights()
        self.opponent?.alpha = 1.0
        
        
        let sequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run({
                self.head?.texture = SKTextureAtlas(named: "\(self.opponentName)Head.atlas").textureNamed("\(self.opponentName)_head_frontopen_punch.png")
            }),
            SKAction.wait(forDuration: 0.1),
            SKAction.sequence([
                SKAction.run({
                    self.fireball(pos: CGPoint(x: -100, y: 200))
                    self.leftArm?.texture = SKTextureAtlas(named: "\(self.opponentName)LeftArm.atlas").textureNamed("\(self.opponentName)_left4.png")
                    self.rightArm?.texture = SKTextureAtlas(named: "\(self.opponentName)RightArm.atlas").textureNamed("\(self.opponentName)_right1.png")
                }),
                SKAction.wait(forDuration: 0.3),
                SKAction.run({
                    self.fireball(pos: CGPoint(x: 100, y: 200))
                    self.leftArm?.texture = SKTextureAtlas(named: "\(self.opponentName)LeftArm.atlas").textureNamed("\(self.opponentName)_left1.png")
                    self.rightArm?.texture = SKTextureAtlas(named: "\(self.opponentName)RightArm.atlas").textureNamed("\(self.opponentName)_right4.png")
                }),
                SKAction.wait(forDuration: 0.3),
                SKAction.run({
                    self.fireball(pos: CGPoint(x: -100, y: 200))
                    self.leftArm?.texture = SKTextureAtlas(named: "\(self.opponentName)LeftArm.atlas").textureNamed("\(self.opponentName)_left4.png")
                    self.rightArm?.texture = SKTextureAtlas(named: "\(self.opponentName)RightArm.atlas").textureNamed("\(self.opponentName)_right1.png")
                }),
                SKAction.wait(forDuration: 0.3),
                SKAction.run({
                    self.leftArm?.texture = SKTextureAtlas(named: "\(self.opponentName)LeftArm.atlas").textureNamed("\(self.opponentName)_left1.png")
                    self.rightArm?.texture = SKTextureAtlas(named: "\(self.opponentName)RightArm.atlas").textureNamed("\(self.opponentName)_right1.png")
                })
                ])
            ])
        
        self.opponent?.run(sequence , withKey:COMBO_ATTACK_KEY)
    }
    
    override func update(_ currentTime: TimeInterval){
        
        currentSceneTime = currentTime
        
        if self.isBlocking {
//            print("BREAK: is blocking")
            return
        }
        
        if self.opponent.action(forKey: COMBO_ATTACK_KEY) != nil {
//            print("BREAK: combo attack")
            return
        }
        
        if self.checkDodging() {
//            print("BREAK: is dodging")
            return
        }
        
        if self.opponent.action(forKey: MOVEMENT_KEY) == nil {
            let newPos:CGPoint = CGPoint(x: startPosition.x + CGFloat(arc4random_uniform(UInt32(100))) - CGFloat(arc4random_uniform(UInt32(100))), y: startPosition.y + CGFloat(arc4random_uniform(UInt32(20))) - CGFloat(arc4random_uniform(UInt32(20))))
            
            let movement:SKAction = SKAction.move(to: newPos, duration: 4)
            self.opponent.run(movement, withKey: MOVEMENT_KEY)
        }
        
        if self.opponent.alpha < 1.0 {
            print("BREAK: alpha < 1")
            return
        }
        
        if self.checkForAttackTime()
        {
            
//            if Int(arc4random_uniform(UInt32(4))) == 1  && !self.checkLast(10, eventsEqualAny: [.ghostBlock],  excluding:[]) {
//                self.blockAttack()
//            }else {
                let amount = max(arc4random_uniform(UInt32(2)), 1)
                
                for _ in 0...amount {
                    self.randomAttack()
                }
//            }
            return
        } else {
            print("BREAK: not attack time")
        }
        
        
         let comboFrequency = self.fightParams?.comboFrequency ?? 40
        
        if !self.checkFor(events: [.ghostComboAttack1, .ghostComboAttack2], withinLast: comboFrequency){
            if Int(arc4random_uniform(UInt32(2))) == 1 {
                self.addEvent(event: .ghostComboAttack1)
            } else {
                self.addEvent(event: .ghostComboAttack2)
            }
            return
        }
        
        
        
        if currentSceneTime - lastActivityCheck > INACTIVITY_TIME_TO_CHECK {
            self.addEvent(event: .nothing)
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
    
    
    func fireball(pos:CGPoint){
        let sparkEmmiter = SKEmitterNode(fileNamed: "FireBall.sks")!
        sparkEmmiter.position = pos
        sparkEmmiter.name = "fireBall"
        sparkEmmiter.zPosition = 200
        sparkEmmiter.targetNode = self
        sparkEmmiter.zRotation = CGFloat(45.degreesToRadians)
        self.body?.addChild(sparkEmmiter)
        sparkEmmiter.run(SKAction.scale(to: 4.0, duration: 0.5))
        self.delegate?.fireBall()
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
    
    /*
     let comboAggression = self.fightParams?.comboAggression ?? 10
     
     if self.checkLast(comboAggression, eventsEqualAny: [.playerRightPunchConnect, .playerLeftPunchConnect, .playerLeftKickConnect, .playerRightKickConnect],
     excluding: [.nothing, .playerRightPunchFail, .playerLeftPunchFail, .playerRightKickFail, .playerLeftKickFail, .ghostGoInvisible, .ghostLeftAttackFail, .ghostRightAttackFail]){
     
     if !self.checkFor(events: [.ghostComboAttack1], withinLast: comboAggression){
     self.addEvent(event: .ghostComboAttack1)
     
     return true
     }
     }
     
     let dodgeFrequency = self.fightParams?.dodgeFrequency ?? 3
     
     if self.checkLast(dodgeFrequency, eventsEqualAny: [.playerRightPunchConnect, .playerLeftPunchConnect],
     excluding: [.nothing, .playerRightPunchFail, .playerLeftPunchFail]){
     
     
     if Int(arc4random_uniform(UInt32(2))) == 1 {
     self.blockAttack()
     }
     if self.checkMoreRecent(events: [.playerLeftPunchConnect, .playerRightPunchConnect]) == .playerLeftPunchConnect {
     self.addEvent(event: .ghostDodgeRight)
     } else {
     self.addEvent(event: .ghostDodgeLeft)
     }
     
     
     
     
     return true
     }
 */
    
    override func checkDodging()->Bool {
        
        let comboAggression = self.fightParams?.comboAggression ?? 10
        
        if self.checkLast(comboAggression, eventsEqualAny: [.playerRightPunchConnect, .playerLeftPunchConnect, .playerLeftKickConnect, .playerRightKickConnect],
                          excluding: [.nothing, .playerRightPunchFail, .playerLeftPunchFail, .playerRightKickFail, .playerLeftKickFail, .ghostGoInvisible, .ghostLeftAttackFail, .ghostRightAttackFail]){
            
            if !self.checkFor(events: [.ghostComboAttack1, .ghostComboAttack2], withinLast: 10){
                if Int(arc4random_uniform(UInt32(2))) == 1 {
                    self.addEvent(event: .ghostComboAttack1)
                } else {
                    self.addEvent(event: .ghostComboAttack2)
                }
                return true
            }
        }
        
        let dodgeFrequency = self.fightParams?.dodgeFrequency ?? 3
        
        if self.checkLast(dodgeFrequency, eventsEqualAny: [.playerRightPunchConnect, .playerLeftPunchConnect],
                          excluding: [.nothing, .playerRightPunchFail, .playerLeftPunchFail]){
            
            
            if Int(arc4random_uniform(UInt32(4))) == 1  && !self.checkLast(10, eventsEqualAny: [.ghostBlock],  excluding:[]) {
                self.blockAttack()
            } else {
                if self.checkMoreRecent(events: [.playerLeftPunchConnect, .playerRightPunchConnect]) == .playerLeftPunchConnect {
                    self.addEvent(event: .ghostDodgeRight)
                } else {
                    self.addEvent(event: .ghostDodgeLeft)
                }
            }
            
            
            
            return true
        }
        
        if self.checkLast(1, eventsEqual: .ghostDodgeRight){
            self.dodgeRight()
            return true
        }
        
        if self.checkLast(1, eventsEqual: .ghostDodgeLeft){
            self.dodgeLeft()
            return true
        }
        
        if self.checkLast(1, eventsEqual: .ghostComboAttack1){
            self.comboAttack1()
            return true
        }
        
        if self.checkLast(1, eventsEqual: .ghostComboAttack2){
            self.comboAttack2()
            return true
        }
        
        return false
    }
    
}
