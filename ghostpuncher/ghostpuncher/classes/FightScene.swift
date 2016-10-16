//
//  FightScene.swift
//  ghostpuncher
//
//  Created by Erik James on 10/7/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class FightScene: SKScene, ControlsDelegate, BattleManagerDelegate, OpponentDelegate
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
        
        self.effectsLayer = EffectsLayer(frame: frame)
        self.effectsLayer?.zPosition = 3
        self.addChild(self.effectsLayer!)
        
        self.opponent = Opponent(frame: frame, name: "Ghost")
        self.addChild(self.opponent!)
        
        self.opponent?.position = CGPoint(x:frame.size.width/2, y:frame.size.height/2)
        self.opponent?.zPosition = 5
        self.opponent?.delegate = self
        
        self.player = Player(frame: frame)
        self.player?.zPosition = 10
        self.addChild(self.player!)
        
        self.controls = Controls(frame: frame)
        self.controls?.zPosition = 20
        self.addChild(self.controls!)
        self.controls?.delegate = self
        
        battleManager = BattleManager()
        battleManager?.delegate = self
        
         dump(frame)
        
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
        
        
        self.opponent?.update(currentTime)
        self.controls?.update(currentTime)
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
    
    func punchRight(power:CGFloat) {
        self.player?.punchRight()
        if (self.opponent?.willRightPunchConnect())! {
            self.battleManager?.playerConnect(power: power)
            self.opponent?.hitRecoil(.right, power:power)
        }
    }
    func punchLeft(power:CGFloat) {
        self.player?.punchLeft()
        if (self.opponent?.willLeftPunchConnect())! {
            self.battleManager?.playerConnect(power: power)
             self.opponent?.hitRecoil(.left, power:power)
        }
    }
    func kickLeft() {
        self.player?.kickLeft()
        if (self.opponent?.willLeftKickConnect())! {
            self.battleManager?.playerConnect()
//            self.opponent?.hitRecoil(.left)
        }
    }
    
    func kickRight() {
        self.player?.kickRight()
        if (self.opponent?.willRightKickConnect())! {
            self.battleManager?.playerConnect()
//            self.opponent?.hitRecoil(.right)
        }
    }
    func blockStart(){
        self.player?.blockStart()
    }
    func checkBlockEnd()->Bool{
        return (self.player?.blockEnd())!
    }
    
    // BattleManagerDelegate functions
    
    func playerHealthUpdated(newAmount:CGFloat){
        self.controls?.setPlayerHealth(percent:newAmount)
    }
    func opponentHealthUpdated(newAmount:CGFloat){
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
        self.opponent?.doLeftArmAttack(connected:!(self.player?.blocking)!)
        if !(self.player?.blocking)! {
            self.battleManager?.opponentConnect()
            self.room.lunge()
            self.effectsLayer?.showDamage(direction:.left)
            self.player?.showDamage(direction:.left)
        }
        
    }
    func opponentAttackRight(){
        self.opponent?.doRightArmAttack(connected:!(self.player?.blocking)!)
        if !(self.player?.blocking)! {
            self.battleManager?.opponentConnect()
            self.room.lunge()
            self.effectsLayer?.showDamage(direction:.right)
            self.player?.showDamage(direction:.left)
        }
        
    }
    
    func turnOffLights(){
        self.effectsLayer?.turnOffLights()
    }
    func turnOnLights(){
        self.effectsLayer?.turnOnLights()
    }
}
