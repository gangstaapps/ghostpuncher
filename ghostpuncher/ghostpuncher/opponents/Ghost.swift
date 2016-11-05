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
}
