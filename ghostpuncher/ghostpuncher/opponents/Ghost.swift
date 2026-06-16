//
//  Ghost.swift
//  ghostpuncher
//
//  Created by Erik James on 10/22/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class Ghost: Opponent {
    init(frame:CGRect, _ multiplier:Int = 1) {
        super.init(frame: frame, name: "ghost")
        self.initParams(params: FightParams(params: GhostParams(), multiplier: multiplier))
    }

    override func fadeOnRecoil()->Bool {
        return true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Telegraphed movekit. Tells shorten as the ghost takes damage so the
    // fight feels like it's escalating rather than the same random spam.
    override func randomAttack() {
        let direction: Direction = arc4random_uniform(2) == 0 ? .left : .right
        let healthFrac = max(0.2, min(1.0, (BattleManager.opponentHealth ?? 100) / 100.0))
        let paceScale = 0.55 + 0.45 * healthFrac

        let roll = Int(arc4random_uniform(10))
        let telegraph: Telegraph

        switch roll {
        case 0...4:
            telegraph = Telegraph(windUp: 0.32 * paceScale, cue: .eyeFlash,  direction: direction, power: 1.2)
        case 5...7:
            telegraph = Telegraph(windUp: 0.7  * paceScale, cue: .armPull,   direction: direction, power: 2.0)
        case 8:
            telegraph = Telegraph(windUp: 0.9  * paceScale, cue: .bodyHunch, direction: direction, power: 2.6)
        default:
            telegraph = Telegraph(windUp: 0.55 * paceScale, cue: .feint,     direction: direction, power: 0)
        }

        self.telegraphAttack(telegraph)
        self.isBlocking = false
    }

    override func baseSpecialInterval() -> TimeInterval {
        let level = BattleManager.level
        return level <= 1 ? 24.0 : (level == 2 ? 16.0 : 12.0)
    }

    override func pickSpecial() {
        // Ghost has no fireball/lightning textures, so its evil flavor comes
        // from the vanish + lights-out moments. The base fury barrage is kept
        // as a rare "boss-mode" punctuation.
        let roll = Int(arc4random_uniform(10))
        switch roll {
        case 0...5:
            // Vanish — the ghost's signature. Disappear, then strike from
            // the dark.
            self.goInvisible()
            self.opponent.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.9),
                SKAction.run { [weak self] in
                    let dir: Direction = arc4random_uniform(2) == 0 ? .left : .right
                    self?.telegraphAttack(Telegraph(windUp: 0.18, cue: .eyeFlash, direction: dir, power: 1.8))
                }
            ]))
        case 6...8:
            // Lights-out scare into a hard hit.
            self.delegate?.turnOffLights()
            self.opponent.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.6),
                SKAction.run { [weak self] in
                    let dir: Direction = arc4random_uniform(2) == 0 ? .left : .right
                    self?.telegraphAttack(Telegraph(windUp: 0.3, cue: .bodyHunch, direction: dir, power: 2.4))
                },
                SKAction.wait(forDuration: 0.8),
                SKAction.run { [weak self] in self?.delegate?.turnOnLights() }
            ]))
        default:
            // Rare full combo barrage.
            super.comboAttack1()
        }
    }
}
