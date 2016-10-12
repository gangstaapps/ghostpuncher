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
    let foreground:SKSpriteNode
    
    init(frame: CGRect) {
        self.roomFrame = frame
        self.background = SKSpriteNode(imageNamed:"background")
        self.foreground = SKSpriteNode(imageNamed:"foreground")
        super.init()
        self.background.size = CGSize(width: self.roomFrame.size.width * 1.1, height: self.roomFrame.size.height * 1.1)
        self.background.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(self.background)
        
        
        
        self.foreground.size = CGSize(width: self.roomFrame.size.width * 1.5,
                                      height: ((self.roomFrame.size.width * 1.5) / self.foreground.frame.size.width) * self.roomFrame.size.height )
        self.foreground.position = CGPoint(x: frame.midX, y: frame.size.height * 0.25)
        self.addChild(self.foreground)
    }
    
    func lunge(){
        self.background.run(SKAction.sequence([SKAction.scale(to: 0.9, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.1)]))
        
        self.foreground.run(SKAction.sequence([SKAction.scale(to: 0.95, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.1)]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
