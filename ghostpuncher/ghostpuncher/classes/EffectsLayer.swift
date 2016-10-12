//
//  EffectsLayer.swift
//  ghostpuncher
//
//  Created by Erik James on 10/11/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class EffectsLayer: SKNode
{
    let roomFrame:CGRect
    let transparentNode:SKShapeNode
    
    init(frame: CGRect) {
        self.roomFrame = frame
        self.transparentNode = SKShapeNode(rect: frame)
        self.transparentNode.lineWidth = 0
        self.transparentNode.fillColor = UIColor.red
        self.transparentNode.alpha = 0
        
        super.init()
        
        self.addChild(self.transparentNode)
    }
    
    func showDamage(){
        self.transparentNode.run(SKAction.sequence([SKAction.fadeAlpha(to: 0.3, duration: 0.2),
                                                    SKAction.fadeAlpha(to: 0.0, duration: 0.1)]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
