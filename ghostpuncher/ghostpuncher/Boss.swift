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
    
    // Boss movekit: a real fighting-game kit. Phases by health.
    //   > 66% HP — patient, mostly heavy hooks with one feint mixed in
    //   33-66%   — adds quick eye-flash combos, mid-tempo
    //   < 33%    — phase 3: aggressive, tells halved, double-feints, body slams
    override func randomAttack() {
        let direction: Direction = arc4random_uniform(2) == 0 ? .left : .right
        let healthFrac = max(0.1, min(1.0, (BattleManager.opponentHealth ?? 100) / 100.0))
        let phase: Int
        let paceScale: TimeInterval
        if healthFrac > 0.66 {
            phase = 1; paceScale = 0.95
        } else if healthFrac > 0.33 {
            phase = 2; paceScale = 0.75
        } else {
            phase = 3; paceScale = 0.5
        }

        let telegraph: Telegraph
        switch phase {
        case 1:
            let roll = Int(arc4random_uniform(10))
            switch roll {
            case 0...5:  telegraph = Telegraph(windUp: 0.7  * paceScale, cue: .armPull,   direction: direction, power: 2.2)
            case 6, 7:   telegraph = Telegraph(windUp: 0.95 * paceScale, cue: .bodyHunch, direction: direction, power: 3.0)
            case 8:      telegraph = Telegraph(windUp: 0.55 * paceScale, cue: .feint,     direction: direction, power: 0)
            default:     telegraph = Telegraph(windUp: 0.38 * paceScale, cue: .eyeFlash,  direction: direction, power: 1.4)
            }
        case 2:
            let roll = Int(arc4random_uniform(10))
            switch roll {
            case 0, 1:   telegraph = Telegraph(windUp: 0.26 * paceScale, cue: .eyeFlash,  direction: direction, power: 1.5)
            case 2, 3:
                telegraph = Telegraph(windUp: 0.28, cue: .eyeFlash, direction: direction, power: 1.4)
                scheduleFollowup(after: 0.32, direction: direction, asEyeFlash: true)
            case 4...6:  telegraph = Telegraph(windUp: 0.6  * paceScale, cue: .armPull,   direction: direction, power: 2.2)
            case 7, 8:   telegraph = Telegraph(windUp: 0.8  * paceScale, cue: .bodyHunch, direction: direction, power: 2.8)
            default:     telegraph = Telegraph(windUp: 0.45 * paceScale, cue: .feint,     direction: direction, power: 0)
            }
        default:
            let roll = Int(arc4random_uniform(10))
            switch roll {
            case 0, 1:   telegraph = Telegraph(windUp: 0.20, cue: .eyeFlash,  direction: direction, power: 1.6)
            case 2, 3:
                telegraph = Telegraph(windUp: 0.30, cue: .feint, direction: direction, power: 0)
                scheduleFollowup(after: 0.36, direction: direction, asEyeFlash: false)
            case 4, 5:   telegraph = Telegraph(windUp: 0.4,  cue: .armPull,   direction: direction, power: 2.6)
            case 6, 7:   telegraph = Telegraph(windUp: 0.5,  cue: .bodyHunch, direction: direction, power: 3.4)
            case 8:      telegraph = Telegraph(windUp: 0.28, cue: .feint,     direction: direction, power: 0)
            default:     telegraph = Telegraph(windUp: 0.22, cue: .eyeFlash,  direction: direction, power: 1.8)
            }
        }

        self.telegraphAttack(telegraph)
        self.isBlocking = false
    }

    private func scheduleFollowup(after delay: TimeInterval, direction: Direction, asEyeFlash: Bool) {
        let cue: Telegraph.Cue = asEyeFlash ? .eyeFlash : .armPull
        let power: CGFloat = asEyeFlash ? 1.4 : 2.2
        let followup = Telegraph(windUp: 0.2, cue: cue, direction: direction, power: power)
        self.opponent.run(SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.run { [weak self] in self?.telegraphAttack(followup) }
        ]))
    }

    override func baseSpecialInterval() -> TimeInterval {
        // Boss is the final fight — relentless. Cooldown scales heavily with
        // the player's progress (BattleManager.multiplier increases per loop).
        let mult = max(1, BattleManager.multiplier)
        return max(3.0, 6.0 - Double(mult - 1))
    }

    override func pickSpecial() {
        // Boss reuses its own comboAttack1 override (which already dispatches
        // among fireball / multiFireball / lightning / super combo).
        super.comboAttack1()
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
        sparkEmmiter.numParticlesToEmit = Int(power * 10)
        
        self.cleanUpParticle(particle: sparkEmmiter)
        
        self.head?.addChild(sparkEmmiter)
    }
}
