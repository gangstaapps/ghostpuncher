//
//  GameMode.swift
//  ghostpuncher
//
//  Created by Erik James on 10/18/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit


enum GameModes:UInt8
{
    case locked
    case ready
}

class GameMode {
    var current:GameModes = .locked
    
    func setGame(mode:GameModes){
        current = mode
    }
}
