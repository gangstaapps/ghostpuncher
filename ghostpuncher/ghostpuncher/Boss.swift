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
}
