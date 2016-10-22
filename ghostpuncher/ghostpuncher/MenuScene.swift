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
    var logo:SKSpriteNode?
    
    var fightButton:SKSpriteNode?
    var fightButtonRol:SKSpriteNode?
    var opponents:[SKSpriteNode]?
    
    let selectSound = SKAction.playSoundFileNamed("select.wav", waitForCompletion: false)
    
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
        
        logo = SKSpriteNode(imageNamed: "logo")
        logo?.size = frame.size
        logo?.position = CGPoint(x: -frame.midX, y: frame.midY)
        self.addChild(logo!)
        
        fist.run(SKAction.sequence([
             SKAction.moveTo(x: 0, duration: 0.2)
        ]))
        
        logo?.run(SKAction.sequence([
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
        
        fightButtonRol? = SKSpriteNode(imageNamed: "fight_rol")
        fightButtonRol?.setScale(0)
        fightButtonRol?.position = CGPoint(x: frame.size.width * 0.27, y: frame.size.height * 0.15)
//        self.addChild(fightButtonRol!)
        fightButtonRol?.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.9),
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1, duration: 0.1)
            ]))
        
        self.addChild(fightButton!)
        
        
        let backgroundMusic = SKAudioNode(fileNamed: "splashloop.wav")
        self.addChild(backgroundMusic)
        
    }
    
    init(frame: CGRect, opponents : [String] = ["ghost", "witch"]) {
        
        super.init(size: frame.size)
        
        let bkg = SKSpriteNode(imageNamed: "background_menu")
        bkg.size = frame.size
        bkg.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(bkg)
        
        let fist = SKSpriteNode(imageNamed: "fist")
        fist.anchorPoint = CGPoint(x:0.3,y:0.4)
        fist.position = CGPoint(x:0,y:0)
        
        self.addChild(fist)
        self.opponents = []
        for i in 0..<opponents.count {
            let button = SKSpriteNode(imageNamed: "\(opponents[i])_head_front")
            button.userData = ["name":opponents[i]]
            button.position = CGPoint(x: (frame.size.width/CGFloat(opponents.count + 1)) * CGFloat(i + 1), y: frame.size.height * 0.5)
            self.addChild(button)
            self.opponents?.append(button)
        }
        
        
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
//        if (self.fightButton?.contains(pos))! {
//            self.fightButton!.isHidden = true
//        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func checkFightPressed(atPoint pos : CGPoint)->Bool {
        guard let _ = self.fightButton?.contains(pos) else {
            return false
        }
        return true
    }
    
    func touchUp(atPoint pos : CGPoint, touch:UITouch) {
        self.fightButton?.isHidden = false
        if self.checkFightPressed(atPoint: pos) {
            self.run(selectSound)
            //            let reveal = SKTransition.push(with: SKTransitionDirection.right, duration: 2.0)
            self.fightButtonRol?.isHidden = true
            logo?.run(SKAction.moveBy(x: -self.frame.size.width/2, y: 0, duration: 0.2))
            fightButton?.run(SKAction.sequence([SKAction.moveBy(x: -self.frame.size.width/2, y: 0, duration: 0.2),
                             SKAction.run({
                                let scene = MenuScene(frame: self.frame, opponents:["ghost", "witch"])
                                self.view?.presentScene(scene)
                             })]))
            return
        }
        
        self.opponents?.forEach({button in
            if button.contains(pos){
                let scene = FightScene(frame: self.frame, backgroundColor: UIColor.black, opponent: button.userData?["name"] as! String)
                self.view?.presentScene(scene)
            }
        })
        
        
    }
}
