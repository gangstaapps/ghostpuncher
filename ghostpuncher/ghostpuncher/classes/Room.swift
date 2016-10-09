//
//  Room.swift
//  ghostpuncher
//
//  Created by Erik James on 10/7/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class Room: SKNode
{
    let roomFrame:CGRect
    let background:SKSpriteNode
    
    init(frame: CGRect) {
        self.roomFrame = frame
        self.background = SKSpriteNode(imageNamed:"background")
        super.init()
        self.background.size = self.roomFrame.size
        self.background.position = CGPoint(x: self.background.size.width/2, y: self.background.size.height/2)
        self.addChild(self.background)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
