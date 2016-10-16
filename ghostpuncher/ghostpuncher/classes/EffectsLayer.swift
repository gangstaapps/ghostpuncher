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
    let roomLightNode:SKShapeNode
    
    
    init(frame: CGRect) {
        self.roomFrame = frame
        self.transparentNode = SKShapeNode(rect: frame)
        self.transparentNode.lineWidth = 0
        self.transparentNode.fillColor = UIColor.red
        self.transparentNode.alpha = 0
        
        self.roomLightNode = SKShapeNode(rect: frame)
        self.roomLightNode.lineWidth = 0
        self.roomLightNode.fillColor = UIColor.black
        self.roomLightNode.alpha = 0.3
        
        
        super.init()
        
        self.addChild(self.roomLightNode)

        self.addChild(self.transparentNode)
        
    }
    
    func showDamage(direction:Direction){
        self.transparentNode.run(SKAction.sequence([SKAction.fadeAlpha(to: 0.3, duration: 0.2),
                                                    SKAction.fadeAlpha(to: 0.0, duration: 0.1)]))
        
    }
    
    func turnOffLights(){
        self.roomLightNode.run(SKAction.fadeAlpha(to: 0.85, duration: 0.3))
    }
    
    func turnOnLights(){
        self.roomLightNode.run(SKAction.fadeAlpha(to: 0.2, duration: 0.3))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
