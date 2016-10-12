//
//  FightScene.swift
//  ghostpuncher
//
//  Created by Erik James on 10/7/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class FightScene: SKScene, ControlsDelegate, BattleManagerDelegate
{
    var room:Room
    var opponent:Opponent?
    var player:Player?
    var controls:Controls?
    var battleManager:BattleManager?
    var effectsLayer:EffectsLayer?
    var battleOn = false
    
    init(frame: CGRect, backgroundColor : UIColor) {
        self.room = Room(frame:frame)
        super.init(size: frame.size)
        self.backgroundColor = backgroundColor
        self.addChild(self.room)
        
        self.opponent = Opponent(frame: frame, name: "Ghost")
        self.addChild(self.opponent!)
        
        self.opponent?.position = CGPoint(x:frame.size.width/2, y:frame.size.height/2)
        
        
        self.player = Player(frame: frame)
        self.player?.zPosition = 10
        self.addChild(self.player!)
        
        self.effectsLayer = EffectsLayer(frame: frame)
        self.effectsLayer?.zPosition = 15
        self.addChild(self.effectsLayer!)
        
        self.controls = Controls(frame: frame)
        self.controls?.zPosition = 20
        self.addChild(self.controls!)
        self.controls?.delegate = self
        
        battleManager = BattleManager()
        battleManager?.delegate = self
        
        battleOn = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        
    }
    override func update(_ currentTime: TimeInterval) {
        //
        if !battleOn {
           return
        }
        
        
        self.battleManager?.update(currentTime)
        self.opponent?.update()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !battleOn {
            return
        }
        
//        for t in touches { self.touchDown(atPoint: t.location(in: self), touch: t) }
        self.controls?.checkButtonHit(touches)
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
    
        
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint, touch:UITouch) {
        if !battleOn {
            return
        }
        
        self.controls?.touchEnded(location: pos, touch:touch)
    }
    
    func punchRight() {
        self.player?.punchRight()
        if (self.opponent?.willRightPunchConnect())! {
            self.battleManager?.playerConnect()
            self.opponent?.hitRecoil()
        }
    }
    func punchLeft() {
        self.player?.punchLeft()
        if (self.opponent?.willLeftPunchConnect())! {
            self.battleManager?.playerConnect()
             self.opponent?.hitRecoil()
        }
    }
    func kickLeft() {
        self.player?.kickLeft()
    }
    func kickRight() {
        self.player?.kickRight()
    }
    func blockStart(){
        self.player?.blockStart()
    }
    func checkBlockEnd(){
        self.player?.blockEnd()
    }
    
    // BattleManagerDelegate functions
    
    func playerHealthUpdated(newAmount:CGFloat){
        print("player health is now \(newAmount)")
        self.controls?.setPlayerHealth(percent:newAmount)
    }
    func opponentHealthUpdated(newAmount:CGFloat){
        print("opponent health is now \(newAmount)")
        self.controls?.setOpponentHealth(percent:newAmount)
    }
    func playerWon(){
        battleOn = false
        
        let reveal = SKTransition.crossFade(withDuration: 1.0)
        let scene = MenuScene(frame: frame, backgroundColor: UIColor.black, text:"You win")
        self.view?.presentScene(scene, transition: reveal)
        
    }
    func playerLost(){
        battleOn = false
        
        let reveal = SKTransition.crossFade(withDuration: 1.0)
        let scene = MenuScene(frame: frame, backgroundColor: UIColor.black, text:"You lose")
        self.view?.presentScene(scene, transition: reveal)
    }
    func opponentAttackLeft(){
        self.opponent?.doLeftArmAttack()
        if !(self.player?.blocking)! {
            self.battleManager?.opponentConnect()
            self.room.lunge()
            self.effectsLayer?.showDamage()
        }
        
    }
    func opponentAttackRight(){
        self.opponent?.doRightArmAttack()
        if !(self.player?.blocking)! {
            self.battleManager?.opponentConnect()
            self.room.lunge()
            self.effectsLayer?.showDamage()
        }
        
    }
}
