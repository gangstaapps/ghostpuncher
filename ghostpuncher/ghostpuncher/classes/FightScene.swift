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
//        self.effectsLayer?.zPosition = 3
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
        self.player?.punchRight(power)
        if (self.opponent?.willRightPunchConnect())! {
            self.battleManager?.playerConnect(power: power)
            self.opponent?.hitRecoil(.right, power:power)
        }
    }
    func punchLeft(power:CGFloat) {
        self.player?.punchLeft(power)
        if (self.opponent?.willLeftPunchConnect())! {
            self.battleManager?.playerConnect(power: power)
             self.opponent?.hitRecoil(.left, power:power)
        }
    }
    
    func blockStart(){
        self.player?.blockStart()
    }
    func checkBlockEndLeft()->Bool{
        return (self.player?.blockEndLeft())!
    }
    func checkBlockEndRight()->Bool{
        return (self.player?.blockEndRight())!
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
        self.opponent?.doLeftArmAttack(connected:!(self.player?.checkBlocking())!)
        if !(self.player?.checkBlocking())! {
            self.battleManager?.opponentConnect(power:self.opponent!.returnFullPowerHit())
            self.room.lunge()
            self.effectsLayer?.showDamage(direction:.left)
            self.opponent?.showDamage(direction:.left)
        } else {
            self.battleManager?.opponentConnect(power:self.opponent!.returnBlockedHit())
        }
        
    }
    func opponentAttackRight(){
        self.opponent?.doRightArmAttack(connected:!(self.player?.checkBlocking())!)
        if !(self.player?.checkBlocking())! {
            self.battleManager?.opponentConnect(power:self.opponent!.returnFullPowerHit())
            self.room.lunge()
            self.effectsLayer?.showDamage(direction:.right)
            self.opponent?.showDamage(direction:.right)
        }else {
            self.battleManager?.opponentConnect(power:self.opponent!.returnBlockedHit())
        }
        
    }
    
    func turnOffLights(){
        self.effectsLayer?.turnOffLights()
    }
    func turnOnLights(){
        self.effectsLayer?.turnOnLights()
    }
}
