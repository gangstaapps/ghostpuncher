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
    
    var tombstoneButton:SKSpriteNode?
    var continueFrom:Int = 0
    
    static var level = 1
    
    let selectSound = SKAction.playSoundFileNamed("select.wav", waitForCompletion: false)
    let buzzSound = SKAction.playSoundFileNamed("buzz.wav", waitForCompletion: false)
    let thumpSound = SKAction.playSoundFileNamed("groundThump.wav", waitForCompletion: false)
    let slashSound = SKAction.playSoundFileNamed("slash.wav", waitForCompletion: false)
    let slash2Sound = SKAction.playSoundFileNamed("slash2.wav", waitForCompletion: false)
    let mediumPunchSound = SKAction.playSoundFileNamed("sfx_punch3.wav", waitForCompletion: false)
    let evilLaughSound = SKAction.playSoundFileNamed("evilLaugh.wav", waitForCompletion: false)
    
    
    
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
            SKAction.moveTo(x: 0, duration: 0.2),
            self.mediumPunchSound
        ]))
        
        logo?.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.moveTo(x: frame.midX, duration: 0.0),
            evilLaughSound
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
    
    init(frame: CGRect, opponents : [String] = BattleManager.opponentNames) {
        
        super.init(size: frame.size)
        
        let bkg = SKSpriteNode(imageNamed: "select_bkg")
        bkg.size = frame.size
        bkg.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(bkg)
        
       
        self.opponents = []
        for i in 0..<opponents.count {
            let button = SKSpriteNode(imageNamed: "\(opponents[i])_rol")
            button.userData = ["name":opponents[i]]
            button.position = CGPoint(x: (frame.size.width/CGFloat(opponents.count + 1)) * CGFloat(i + 1), y: frame.size.height * 0.5)
            self.addChild(button)
            self.opponents?.append(button)
        }
        
        
    }
    
    init(frame: CGRect, diedAt:Int) {
        
        super.init(size: frame.size)
        
        self.continueFrom = diedAt
        
        let bkg = SKSpriteNode(imageNamed: "select_bkg")
        bkg.size = frame.size
        bkg.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(bkg)
        
        
        
        
        tombstoneButton = SKSpriteNode(imageNamed: "stone_dark")
        tombstoneButton?.position = CGPoint(x: frame.midX, y: frame.midY - frame.size.height)
        self.addChild(tombstoneButton!)
        
        let message = SKSpriteNode(imageNamed: Int(arc4random_uniform(UInt32(3))) == 1 ? "youlose" : "RIP")
        
        //message.position = CGPoint(x: frame.midX, y: frame.midY)
        tombstoneButton?.addChild(message)
        tombstoneButton?.run(SKAction.moveTo(y: frame.midY, duration: 2.0))
    }
    
    init(frame: CGRect, opponents : [String] = BattleManager.opponentNames, startWith:Int, _ animateIn:Bool = false) {
        
        super.init(size: frame.size)
        
        let bkg = SKSpriteNode(imageNamed: "select_bkg")
        bkg.size = frame.size
        bkg.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(bkg)
        
        var opponentsToDisplay = opponents
        
        var theLevel = min(MenuScene.level, 3)
        
        if MenuScene.level == 2 || MenuScene.level == 3 {
            let bossbkg = SKSpriteNode(imageNamed: "boss_background\(theLevel - 1)")
            bossbkg.size = frame.size
            bossbkg.position = CGPoint(x: frame.midX, y: frame.midY)
            self.addChild(bossbkg)
        } else if MenuScene.level > 3 {
            opponentsToDisplay = ["boss"]
            theLevel = 0
        }
        
        self.opponents = []
        for i in 0..<opponentsToDisplay.count {
            let button:SKSpriteNode

            
            if i >= startWith {
                button = SKSpriteNode(imageNamed: "\(opponentsToDisplay[i])_rol")
                button.userData = ["name":opponentsToDisplay[i]]
                button.position = CGPoint(x: (frame.size.width/CGFloat(opponentsToDisplay.count + 1)) * CGFloat(i + 1), y: frame.size.height * 0.5)
                
                self.addChild(button)
                
                if theLevel > 1 {
                
                    for j in 1..<theLevel {
                        let slash = SKSpriteNode(imageNamed: "slash\(i+1)_\(j)")
                        slash.position = CGPoint(x: frame.midX, y: frame.midY)
                        self.addChild(slash)
                    }
                }
            } else {
                button = SKSpriteNode(imageNamed: "stone\(i+1)")
                
                
                
                var slashes:[SKSpriteNode] = []
                for j in 1...theLevel {
                    let slash = SKSpriteNode(imageNamed: "slash\(i+1)_\(j)")
                    slash.position = CGPoint(x: frame.midX, y: frame.midY)
                    slashes.append(slash)
                }
                
                if animateIn && i == (startWith - 1) {
                    button.position = CGPoint(x: frame.midX, y: frame.midY + frame.size.height)
                    var sequence:[SKAction] = [SKAction.moveTo(y: frame.midY, duration: 0.3), self.thumpSound]
                    slashes.forEach({slash in
                        sequence.append(SKAction.wait(forDuration: 0.3))
                        sequence.append(self.slash2Sound)
                        sequence.append(SKAction.run({
                            self.addChild(slash)
                        }))
                    })
                    
                    button.run(SKAction.sequence(sequence))

                    self.addChild(button)
                } else {
                    button.position = CGPoint(x: frame.midX, y: frame.midY)
                    self.addChild(button)
                    slashes.forEach({slash in
                        self.addChild(slash)
                    })
                }
                
            }
            
            
            
            
            self.opponents?.append(button)
        }
        
        if startWith == self.opponents?.count {
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: 2.0), SKAction.run {
                MenuScene.level += 1
                let reveal = SKTransition.crossFade(withDuration: 1.0)
                let scene = MenuScene(frame: self.frame, opponents:BattleManager.opponentNames, startWith:0)
                self.view?.presentScene(scene, transition: reveal)
                }]))
            
            return
        }
        
        let button = self.opponents?[startWith]
        
        
        
        button?.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.run({
            self.run(self.buzzSound)
            button?.texture = SKTexture(imageNamed: "\(button?.userData?["name"] as! String)_reg")
        }),SKAction.wait(forDuration: 0.5), SKAction.run({
            button?.texture = SKTexture(imageNamed: "\(button?.userData?["name"] as! String)_rol")
        }),SKAction.wait(forDuration: 0.1), SKAction.run({
            self.run(self.buzzSound)
            button?.texture = SKTexture(imageNamed: "\(button?.userData?["name"] as! String)_reg")
        }),SKAction.wait(forDuration: 0.2), SKAction.run({
            button?.texture = SKTexture(imageNamed: "\(button?.userData?["name"] as! String)_rol")
        }),SKAction.wait(forDuration: 0.1), SKAction.run({
            self.run(self.buzzSound)
            button?.texture = SKTexture(imageNamed: "\(button?.userData?["name"] as! String)_reg")
        }), SKAction.wait(forDuration: 1.0), SKAction.run({
            let scene = FightScene(frame: self.frame, backgroundColor: UIColor.black, opponent: button?.userData?["name"] as! String, MenuScene.level)
            
            self.view?.presentScene(scene)
        })]) )
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

        
        self.fightButton?.isHidden = false
        if self.checkFightPressed(atPoint: pos) {
            self.run(selectSound)
            //            let reveal = SKTransition.push(with: SKTransitionDirection.right, duration: 2.0)
            self.fightButtonRol?.isHidden = true
            logo?.run(SKAction.moveBy(x: -self.frame.size.width/2, y: 0, duration: 0.2))
            fightButton?.run(SKAction.sequence([SKAction.moveBy(x: -self.frame.size.width/2, y: 0, duration: 0.2),
                                                SKAction.run({
//                                                   MenuScene.level  = 3
                                                    let scene = MenuScene(frame: self.frame, opponents:BattleManager.opponentNames, startWith:0)
                                                    self.view?.presentScene(scene)
                                                })]))
            return
        }
        
        if self.checkTombstonePressed(atPoint: pos) {
//             let enemies = ["ghost", "witch", "devil"]
            let scene = MenuScene(frame: frame, opponents:BattleManager.opponentNames, startWith:self.continueFrom, false)
//            let scene = FightScene(frame: self.frame, backgroundColor: UIColor.black, opponent: enemies[self.continueFrom], MenuScene.level)
            
            self.view?.presentScene(scene)
            
            return
        }
        
        
        
//        self.opponents?.forEach({button in
//            if button.contains(pos){
//                button.texture = SKTexture(imageNamed: "\(button.userData?["name"] as! String)_reg")
//                
//                button.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.run({
//                        let scene = FightScene(frame: self.frame, backgroundColor: UIColor.black, opponent: button.userData?["name"] as! String)
//                    
//                        self.view?.presentScene(scene)
//                })]) )
//
//            }
//        })
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func checkFightPressed(atPoint pos : CGPoint)->Bool {
        guard let _ = self.fightButton?.contains(pos) else {
            return false
        }
        return true
    }
    
    func checkTombstonePressed(atPoint pos : CGPoint)->Bool {
        guard let _ = self.tombstoneButton?.contains(pos) else {
            return false
        }
        return true
    }
    
    func touchUp(atPoint pos : CGPoint, touch:UITouch) {
        
        
        
    }
}
