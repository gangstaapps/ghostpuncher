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
            scaleMoveGroup, SKAction.run({[weak self] in
                self?.delegate?.ghostIsGone()})
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
    
    // Witch movekit: heavy on feints, quick jabs to punish over-commitment.
    // Whip-fast at low health.
    override func randomAttack() {
        let direction: Direction = arc4random_uniform(2) == 0 ? .left : .right
        let healthFrac = max(0.2, min(1.0, (BattleManager.opponentHealth ?? 100) / 100.0))
        let paceScale = 0.5 + 0.4 * healthFrac

        let roll = Int(arc4random_uniform(10))
        let telegraph: Telegraph

        switch roll {
        case 0...2:
            telegraph = Telegraph(windUp: 0.28 * paceScale, cue: .eyeFlash,  direction: direction, power: 1.3)
        case 3, 4:
            telegraph = Telegraph(windUp: 0.6  * paceScale, cue: .armPull,   direction: direction, power: 1.9)
        case 5, 6:
            telegraph = Telegraph(windUp: 0.5  * paceScale, cue: .feint,     direction: direction, power: 0)
        case 7:
            telegraph = Telegraph(windUp: 0.45 * paceScale, cue: .feint,     direction: direction, power: 0)
            self.scheduleFollowup(after: 0.55 * paceScale, direction: direction)
        case 8:
            telegraph = Telegraph(windUp: 0.65 * paceScale, cue: .bodyHunch, direction: direction, power: 2.3)
        default:
            telegraph = Telegraph(windUp: 0.28 * paceScale, cue: .eyeFlash,  direction: direction, power: 1.4)
        }

        self.telegraphAttack(telegraph)
        self.isBlocking = false
    }

    private func scheduleFollowup(after delay: TimeInterval, direction: Direction) {
        let realDir: Direction = direction == .left ? .right : .left
        let followup = Telegraph(windUp: 0.18, cue: .eyeFlash, direction: realDir, power: 1.5)
        self.opponent.run(SKAction.sequence([
            SKAction.wait(forDuration: delay + 0.05),
            SKAction.run { [weak self] in self?.telegraphAttack(followup) }
        ]))
    }

    override func baseSpecialInterval() -> TimeInterval {
        let level = BattleManager.level
        return level <= 1 ? 22.0 : (level == 2 ? 14.0 : 10.0)
    }

    override func pickSpecial() {
        // Witch's overridden comboAttack1 routes to fireball / multiFireball
        // / lightning. Use self.comboAttack1 (NOT super) so we hit the
        // elemental versions, not the base "fury of punches" barrage.
        self.comboAttack1()
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
        sparkEmmiter.numParticlesToEmit = Int(power * 10)
        
        
        self.head?.addChild(sparkEmmiter)
        
        self.cleanUpParticle(particle: sparkEmmiter)
    }
    
   
    
}
