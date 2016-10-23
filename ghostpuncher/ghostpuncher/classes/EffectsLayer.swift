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
    let explosionNode:SKShapeNode
    let roomLightNode:SKShapeNode
    
    
    init(frame: CGRect) {
        self.roomFrame = frame
        self.transparentNode = SKShapeNode(rect: frame)
        self.transparentNode.lineWidth = 0
        self.transparentNode.fillColor = UIColor.red
        self.transparentNode.alpha = 0
        self.transparentNode.zPosition = 20
        
        self.roomLightNode = SKShapeNode(rect: frame)
        self.roomLightNode.lineWidth = 0
        self.roomLightNode.fillColor = UIColor.black
        self.roomLightNode.alpha = 0.2
        self.roomLightNode.zPosition = 3
        
        self.explosionNode = SKShapeNode(rect: frame)
        self.explosionNode.lineWidth = 0
        self.explosionNode.fillColor = UIColor.orange
        self.explosionNode.alpha = 0
        self.explosionNode.zPosition = 20
        
        super.init()
        
        self.addChild(self.roomLightNode)
        self.addChild(self.explosionNode)
        self.addChild(self.transparentNode)
        
    }
    
    func showDamage(direction:Direction){
        self.transparentNode.run(SKAction.sequence([SKAction.fadeAlpha(to: 0.5, duration: 0.2),
                                                    SKAction.fadeAlpha(to: 0.0, duration: 0.1)]))
        
    }
    
    func showExplosion(){
        self.explosionNode.run(SKAction.sequence([SKAction.fadeAlpha(to: 0.6, duration: 0.2),
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
