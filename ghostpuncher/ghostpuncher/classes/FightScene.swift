//
//  FightScene.swift
//  ghostpuncher
//
//  Created by Erik James on 10/7/16.
//  Copyright © 2016 Erik James. All rights reserved.
//
import CoreMotion
import SpriteKit

class FightScene: SKScene, ControlsDelegate, BattleManagerDelegate, OpponentDelegate
{
    var room:Room
    var opponent:Opponent?
    var player:Player?
    var controls:Controls?
    var battleManager:BattleManager?
    var effectsLayer:EffectsLayer?
    let sfxManager = SFXManager()
    var gameMode = GameMode()
    var ghostHolder:SKNode?
    
    var listenForTilt:Bool = false
    
    var motionManager: CMMotionManager!
    
    let lightPunchSound = SKAction.playSoundFileNamed("light_punch.wav", waitForCompletion: false)
    let mediumPunchSound = SKAction.playSoundFileNamed("med_punch.wav", waitForCompletion: false)
    let heavyPunchSound = SKAction.playSoundFileNamed("hard_punch.wav", waitForCompletion: false)
    let goInvisibleSound = SKAction.playSoundFileNamed("phaser.wav", waitForCompletion: false)
    let startSound = SKAction.playSoundFileNamed("start.wav", waitForCompletion: false)
    let lightsOutSound = SKAction.playSoundFileNamed("soulgrab.wav", waitForCompletion: false)
    let superAttackSound = SKAction.playSoundFileNamed("laugh_reverse.wav", waitForCompletion: false)
    let youLoseSound = SKAction.playSoundFileNamed("deathblow.wav", waitForCompletion: false)
    let youWinSound = SKAction.playSoundFileNamed("ghostshock.wav", waitForCompletion: false)
    let fireballSFX = SKAction.playSoundFileNamed("fireball.wav", waitForCompletion: false)
    
    
    
    init(frame: CGRect, backgroundColor : UIColor, opponent:String = "ghost", _ level:Int = 1) {
        self.room = Room(frame:frame, name:opponent)
        super.init(size: frame.size)
        self.backgroundColor = backgroundColor
        self.addChild(self.room)
        
        
        
        self.effectsLayer = EffectsLayer(frame: frame)
//        self.effectsLayer?.zPosition = 3
        self.addChild(self.effectsLayer!)
        
        
        self.ghostHolder = SKNode()
        self.addChild(self.ghostHolder!)
        
        self.opponent = Opponent.makeOpponent(frame: frame, named: opponent, level)
        self.ghostHolder?.addChild(self.opponent!)
        
        self.opponent?.position = CGPoint(x:frame.size.width/2, y:frame.size.height/2)
        self.opponent?.zPosition = 5
        self.opponent?.delegate = self
        
        self.player = Player(frame: frame)
        self.player?.zPosition = 10
        self.addChild(self.player!)
        
        self.controls = Controls(frame: frame, opponent:opponent)
        self.controls?.zPosition = 20
        self.addChild(self.controls!)
        self.controls?.delegate = self
        
        battleManager = BattleManager()
        battleManager?.delegate = self
        
         dump(frame)
        
        self.gameMode.setGame(mode: .ready)
        
        let backgroundMusic = SKAudioNode(fileNamed: "atmos_loop1.wav")
        backgroundMusic.run(SKAction.changeVolume(to: 0.25, duration: 0))
        self.addChild(backgroundMusic)
        
        let backgroundMusic2 = SKAudioNode(fileNamed: "atmos_loop2.wav")
        backgroundMusic2.run(SKAction.changeVolume(to: 0.25, duration: 0))
        self.addChild(backgroundMusic2)
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), startSound]))
    }
    
    override func didMove(to view: SKView) {
        #if (arch(i386) || arch(x86_64))
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            self.view?.addGestureRecognizer(swipeRight)
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeRight.direction = UISwipeGestureRecognizerDirection.left
            self.view?.addGestureRecognizer(swipeLeft)
        #else
            motionManager = CMMotionManager()
            
            motionManager.startGyroUpdates()
            motionManager.gyroUpdateInterval = 0.05
            listenForTilt = true
        #endif
        
       
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                self.jukeRight()
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                self.jukeLeft()
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        
    }
    override func update(_ currentTime: TimeInterval) {
        //
        if self.gameMode.current != .ready
        {
            return
        }
        
        
        self.opponent?.update(currentTime)
        self.controls?.update(currentTime)
        self.player?.update()
        
        
        #if !(arch(i386) || arch(x86_64))
            if !listenForTilt {
                return
            }
            if let gyroData = motionManager.gyroData {
                let adjustedTilt = Int(gyroData.rotationRate.z * 10)
//               print("accelerometerData.acceleration.x = \(Int(gyroData.rotationRate.z * 10))")
                if abs(adjustedTilt) > 10 {
                    self.juke(amount: adjustedTilt)
                }
                
            }
        #endif
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.gameMode.current != .ready
        {
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
        if self.gameMode.current == .locked
        {
            return
        }
        
        self.controls?.touchEnded(location: pos, touch:touch)
    }
    
    func punchRight(power:CGFloat) {
        self.player?.punchRight(power)
        if (self.opponent?.willRightPunchConnect(power))! {
            if power < 3 {
                self.run(lightPunchSound)
            } else if power < 7 {
                self.run((self.opponent?.mediumPunchSFX())!)
            } else {
                self.run((self.opponent?.heavyPunchSFX())!)
            }
            self.battleManager?.playerConnect(power: power)
            self.opponent?.hitRecoil(.right, power:power)
        }
//        self.run(punchSound)
    }
    func punchLeft(power:CGFloat) {
        self.player?.punchLeft(power)
        if (self.opponent?.willLeftPunchConnect(power))! {
            if power < 3 {
                self.run(lightPunchSound)
            } else if power < 7 {
                self.run((self.opponent?.mediumPunchSFX())!)
            } else {
                self.run((self.opponent?.heavyPunchSFX())!)
            }
            self.battleManager?.playerConnect(power: power)
             self.opponent?.hitRecoil(.left, power:power)
        }
//        self.run(punchSound)
    }
    
    func comboRight() {
        let willItWork = (self.opponent?.willRightComboConnect())!
        self.player?.punchRight(10)
        if willItWork {
            self.run((self.opponent?.heavyPunchSFX())!)
            self.battleManager?.playerConnect(power: 10)
            self.opponent?.hitRecoil(.right, power:10)
        }
        
    }
    
    func comboLeft() {
        let willItWork = (self.opponent?.willLeftComboConnect())!
        self.player?.punchLeft(10)
        if willItWork {
            self.run((self.opponent?.heavyPunchSFX())!)
            self.battleManager?.playerConnect(power: 10)
            self.opponent?.hitRecoil(.left, power:10)
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
        self.gameMode.setGame(mode: .locked)
        self.room.openPortal()
        self.controls?.removeFromParent()
        self.run(SKAction.sequence([ youWinSound, SKAction.wait(forDuration: 0.5), SKAction.run({
            self.opponent?.punchedToHell()
        })]))
//        self.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.run({
//            self.ghostIsGone()
//        })]))
    }
    func ghostIsGone(){
        self.room.closePortal()
        
        let reveal = SKTransition.crossFade(withDuration: 1.0)
        
        let scene:MenuScene
        
        if (self.opponent as? Ghost) != nil {
            scene = MenuScene(frame: frame, opponents:["ghost", "witch", "devil"], startWith:1, true)
        } else if (self.opponent as? Witch) != nil {
            scene = MenuScene(frame: frame, opponents:["ghost", "witch", "devil"], startWith:2, true)
        } else {
            scene = MenuScene(frame: frame, opponents:["ghost", "witch", "devil"], startWith:3, true)
        }
        
        
//        self.view?.presentScene(scene)
        
        self.view?.presentScene(scene, transition: reveal)
    }
    func playerLost(){
//        self.playerWon()
        self.effectsLayer?.turnOffLights()
        self.controls?.removeFromParent()
        self.player?.removeFromParent()
        self.run(youLoseSound)
        self.gameMode.setGame(mode: .locked)
//        self.room.openPortal()
        self.opponent?.victory()
        
    }
    
    func youAreDead(){
//        let reveal = SKTransition.crossFade(withDuration: 1.0)
        
        let scene:MenuScene
        
        if (self.opponent as? Ghost) != nil {
            scene = MenuScene(frame: frame, diedAt:0)
        } else if (self.opponent as? Witch) != nil {
            scene = MenuScene(frame: frame, diedAt:1)
        } else {
            scene = MenuScene(frame: frame, diedAt:2)
        }
        
        
        self.view?.presentScene(scene)

    }
    
    func opponentAttackLeft(){
        
        let isBlocking:Bool! = self.player?.checkBlocking()
        
        let hitPos = (self.opponent?.position.x)! + (self.ghostHolder?.position.x)!
        
        let connected = min(max(hitPos, 0), 400) == hitPos
        print("hitPos = \(hitPos)")
//
//        self.opponent?.doLeftArmAttack(connected:isBlocking!)
//        
//        if !connected {
//            return
//        }
        self.opponent?.doLeftArmAttack(connected:!isBlocking)
        if !isBlocking && connected {
            self.battleManager?.opponentConnect(power:self.opponent!.returnFullPowerHit())
            self.room.lunge()
            self.effectsLayer?.showDamage(direction:.left)
            self.opponent?.showDamage(direction:.left)
            self.run(self.opponent!.enemyConnectSFX())
        } else {
            self.battleManager?.opponentConnect(power:connected ? self.opponent!.returnBlockedHit() : 0)
            self.run(self.opponent!.enemyBlockedSFX())
        }
        
    }
    func opponentAttackRight(){
        let isBlocking:Bool! = self.player?.checkBlocking()
        
        let hitPos = (self.opponent?.position.x)! + (self.ghostHolder?.position.x)!
        
        let connected = min(max(hitPos, 100), 400) == hitPos
//        print("hitPos = \(hitPos)")
//
//        self.opponent?.doRightArmAttack(connected:isBlocking!)
//        
//        if !connected {
//            return
//        }
        self.opponent?.doRightArmAttack(connected:!isBlocking)
        
        if !isBlocking && connected {
            self.battleManager?.opponentConnect(power:self.opponent!.returnFullPowerHit())
            self.room.lunge()
            self.effectsLayer?.showDamage(direction:.right)
            self.opponent?.showDamage(direction:.right)
            self.run(self.opponent!.enemyConnectSFX())
        }else {
            self.battleManager?.opponentConnect(power:connected ? self.opponent!.returnBlockedHit() : 0)
            self.run(self.opponent!.enemyBlockedSFX())
        }
        
    }
    
    func explosion() {
        self.battleManager?.opponentConnect(power:self.opponent!.returnFullPowerHit())
        self.room.lunge()
        self.effectsLayer?.showExplosion()
    }
    
    func goingInvisible(){
        self.run(goInvisibleSound)
    }
    
    func superAttack(){
        self.run(superAttackSound)
    }
    
    func playerPunchBlocked(){
        self.run(lightPunchSound)
    }
    
    func fireBall(){
        self.run(fireballSFX)
    }
    
    func turnOffLights(){
        self.run(lightsOutSound)
        self.effectsLayer?.turnOffLights()
    }
    func turnOnLights(){
        self.effectsLayer?.turnOnLights()
    }
    
    func juke(amount:Int) {
        listenForTilt = false
        
        
        self.ghostHolder?.run(SKAction.sequence([SKAction.move(to: CGPoint(x:amount * 10, y:0), duration: 0.3), SKAction.wait(forDuration: 0.1), SKAction.move(to: CGPoint(x:0, y:0), duration: 0.4), SKAction.run({
            self.listenForTilt = true
        })]))
        self.room.run(SKAction.sequence([SKAction.move(to: CGPoint(x:amount * 3, y:0), duration: 0.3), SKAction.wait(forDuration: 0.1),SKAction.move(to: CGPoint(x:0, y:0), duration: 0.4)]))
    }
    
    func jukeRight() {
        listenForTilt = false
        
        self.ghostHolder?.run(SKAction.sequence([SKAction.move(to: CGPoint(x:-300, y:0), duration: 0.3), SKAction.wait(forDuration: 0.1), SKAction.move(to: CGPoint(x:0, y:0), duration: 0.4), SKAction.run({
            self.listenForTilt = true
        })]))
        self.room.run(SKAction.sequence([SKAction.move(to: CGPoint(x:-200, y:0), duration: 0.3), SKAction.wait(forDuration: 0.1),SKAction.move(to: CGPoint(x:0, y:0), duration: 0.4)]))
    }
    func jukeLeft() {
        listenForTilt = false
        self.ghostHolder?.run(SKAction.sequence([SKAction.move(to: CGPoint(x:300, y:0), duration: 0.3), SKAction.wait(forDuration: 0.1),SKAction.move(to: CGPoint(x:0, y:0), duration: 0.4), SKAction.run({
            self.listenForTilt = true
        })]))
        self.room.run(SKAction.sequence([SKAction.move(to: CGPoint(x:200, y:0), duration: 0.3), SKAction.wait(forDuration: 0.1),SKAction.move(to: CGPoint(x:0, y:0), duration: 0.4)]))
    }
    func showDamage(node:SKSpriteNode){
        self.effectsLayer?.addChild(node)
    }
}
