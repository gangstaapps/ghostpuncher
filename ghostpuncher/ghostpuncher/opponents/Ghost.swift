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
            // Quick jab — short tell, light damage. The bread and butter.
            telegraph = Telegraph(windUp: 0.32 * paceScale,
                                  cue: .eyeFlash,
                                  direction: direction,
                                  power: 0.85)
        case 5...7:
            // Heavy hook — long tell, big damage. Punish-on-read.
            telegraph = Telegraph(windUp: 0.75 * paceScale,
                                  cue: .armPull,
                                  direction: direction,
                                  power: 1.6)
        case 8:
            // Body slam — slowest tell, biggest hit.
            telegraph = Telegraph(windUp: 0.9 * paceScale,
                                  cue: .bodyHunch,
                                  direction: direction,
                                  power: 2.0)
        default:
            // Feint — looks like a heavy, but lands no damage. Teaches the
            // player to read, not just react.
            telegraph = Telegraph(windUp: 0.6 * paceScale,
                                  cue: .feint,
                                  direction: direction,
                                  power: 0)
        }

        self.telegraphAttack(telegraph)
        self.isBlocking = false
    }
}
