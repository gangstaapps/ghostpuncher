//
//  MenuScene.swift
//  ghostpuncher
//
//  Created by Erik James on 10/10/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene
{
    
    var fightButton:SKSpriteNode?

    
    init(frame: CGRect, backgroundColor : UIColor) {
        
        super.init(size: frame.size)
        self.backgroundColor = backgroundColor
        
        let logo:SKSpriteNode = SKSpriteNode(imageNamed: "logo_big")
        logo.setScale(0.5)
        logo.position = CGPoint(x: frame.size.width * 1.5, y: frame.size.height * 0.7)
        self.addChild(logo)
        logo.run(SKAction.moveTo(x: frame.size.width/2, duration: 0.5))
        
        fightButton = SKSpriteNode(imageNamed: "start_reg")
        fightButton?.setScale(0.5)
        fightButton?.position = CGPoint(x: -frame.size.width * 1.5, y: frame.size.height * 0.25)
        self.addChild(fightButton!)
        fightButton?.run(SKAction.moveTo(x: frame.size.width/2, duration: 0.5))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self), touch: t) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self), touch: t) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self), touch: t) }
    }
    
    func touchDown(atPoint pos : CGPoint, touch:UITouch) {
        if (self.fightButton?.contains(pos))! {
            let reveal = SKTransition.push(with: SKTransitionDirection.right, duration: 2.0)
            let scene = FightScene(frame: frame, backgroundColor: UIColor.black)
            self.view?.presentScene(scene, transition: reveal)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint, touch:UITouch) {
        
    }
}
