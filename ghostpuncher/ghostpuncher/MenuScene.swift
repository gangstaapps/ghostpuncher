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

    init(frame:CGRect) {
        super.init(size: frame.size)
        
        let bkg = SKSpriteNode(imageNamed: "background_menu")
        bkg.size = frame.size
        bkg.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(bkg)
        
        let fist = SKSpriteNode(imageNamed: "fist")
        fist.anchorPoint = CGPoint(x:0.3,y:0.4)
        fist.position = CGPoint(x:-fist.frame.size.width,y:0)
        
        self.addChild(fist)
        
        let logo = SKSpriteNode(imageNamed: "logo")
        logo.size = frame.size
        logo.position = CGPoint(x: -frame.midX, y: frame.midY)
        self.addChild(logo)
        
        fist.run(SKAction.sequence([
             SKAction.moveTo(x: 0, duration: 0.2)
        ]))
        
        logo.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.moveTo(x: frame.midX, duration: 0.0)
            ]))
        
        fightButton = SKSpriteNode(imageNamed: "fight_reg")
        fightButton?.setScale(0)
        fightButton?.position = CGPoint(x: frame.size.width * 0.27, y: frame.size.height * 0.15)
        
        fightButton?.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.9),
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1, duration: 0.1)
            ]))
        
        let fightButtonRol = SKSpriteNode(imageNamed: "fight_rol")
        fightButtonRol.setScale(0)
        fightButtonRol.position = CGPoint(x: frame.size.width * 0.27, y: frame.size.height * 0.15)
        self.addChild(fightButtonRol)
        fightButtonRol.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.9),
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1, duration: 0.1)
            ]))
        
        self.addChild(fightButton!)
    }
    
    init(frame: CGRect, backgroundColor : UIColor) {
        
        super.init(size: frame.size)
        self.backgroundColor = backgroundColor
        
        let logo:SKSpriteNode = SKSpriteNode(imageNamed: "logo_big")
        logo.setScale(0.5)
        logo.position = CGPoint(x: frame.size.width * 1.5, y: frame.size.height * 0.7)
        self.addChild(logo)
        logo.run(SKAction.moveTo(x: frame.size.width/2, duration: 0.5))
        
        fightButton = SKSpriteNode(imageNamed: "fight_reg")
        fightButton?.setScale(0.5)
        fightButton?.position = CGPoint(x: -frame.size.width * 1.5, y: frame.size.height * 0.25)
        self.addChild(fightButton!)
        fightButton?.run(SKAction.moveTo(x: frame.size.width/2, duration: 0.5))
    }
    
    init(frame:CGRect, backgroundColor:UIColor, text:String){
        super.init(size: frame.size)
        let myLabel = SKLabelNode(fontNamed: "Arial")
        myLabel.text = text
        myLabel.fontSize = 20
        myLabel.position = CGPoint(x:frame.midX, y:frame.midY)
        
        self.addChild(myLabel)
        
        fightButton = SKSpriteNode(imageNamed: "fight_reg")
        fightButton?.setScale(0.5)
        fightButton?.position = CGPoint(x: frame.midX, y: frame.size.height * 0.25)
        self.addChild(fightButton!)
        
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
            self.fightButton!.isHidden = true
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint, touch:UITouch) {
        if (self.fightButton?.contains(pos))! {
            //            let reveal = SKTransition.push(with: SKTransitionDirection.right, duration: 2.0)
            let scene = FightScene(frame: frame, backgroundColor: UIColor.black)
            self.view?.presentScene(scene)
        }
        self.fightButton!.isHidden = false
    }
}
