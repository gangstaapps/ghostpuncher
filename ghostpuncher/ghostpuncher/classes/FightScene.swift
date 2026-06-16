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
    let state = FightStateMachine()
    var ghostHolder:SKNode?

    var listenForTilt:Bool = false

    var motionManager: CMMotionManager!

    private var pauseOverlay: PauseOverlay?
    private var pauseButton: SKShapeNode?
    private var pausableNodes: [SKNode] { return [opponent, player, controls, room, effectsLayer, ghostHolder].compactMap { $0 } }
    
    static let lightPunchSound = SKAction.playSoundFileNamed("light_punch.wav", waitForCompletion: false)
    static let goInvisibleSound = SKAction.playSoundFileNamed("phaser.wav", waitForCompletion: false)
    static let startSound = SKAction.playSoundFileNamed("start.wav", waitForCompletion: false)
    static let lightsOutSound = SKAction.playSoundFileNamed("soulgrab.wav", waitForCompletion: false)
    static let superAttackSound = SKAction.playSoundFileNamed("laugh_reverse.wav", waitForCompletion: false)
    static let youLoseSound = SKAction.playSoundFileNamed("deathblow.wav", waitForCompletion: false)
    static let youWinSound = SKAction.playSoundFileNamed("ghostshock.wav", waitForCompletion: false)
    static let fireballSFX = SKAction.playSoundFileNamed("fireball.wav", waitForCompletion: false)
    static let thunderSFX = SKAction.playSoundFileNamed("thunder.wav", waitForCompletion: false)
    static let lightningSFX = SKAction.playSoundFileNamed("lightning.wav", waitForCompletion: false)
    static let ghostAppearSFX = SKAction.playSoundFileNamed("ghostAppear.wav", waitForCompletion: false)
    static let witchAppearSFX = SKAction.playSoundFileNamed("witchAppear.wav", waitForCompletion: false)
    static let devilAppearSFX = SKAction.playSoundFileNamed("devilAppear.wav", waitForCompletion: false)
    
    
    init(frame: CGRect, backgroundColor : UIColor, opponent:String = "ghost", _ level:Int = 1) {
        self.room = Room(frame:frame, name:opponent)
        super.init(size: frame.size)
        self.backgroundColor = backgroundColor
        
        
        
        
        self.effectsLayer = EffectsLayer(frame: frame)
        if opponent == "boss" {
            self.effectsLayer?.turnOffLights(true)
        }
        
//        self.effectsLayer?.zPosition = 3
        self.addChild(self.room)
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
        
        
        
        let backgroundMusic = SKAudioNode(fileNamed: "atmos_loop1.wav")
        backgroundMusic.run(SKAction.changeVolume(to: 0.25, duration: 0))
        self.addChild(backgroundMusic)

        let backgroundMusic2 = SKAudioNode(fileNamed: "atmos_loop2.wav")
        backgroundMusic2.run(SKAction.changeVolume(to: 0.25, duration: 0))
        self.addChild(backgroundMusic2)
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: 2.0), FightScene.startSound]))
        
        if opponent == "boss" {
            self.opponent?.isHidden = true
            
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: 2.0),FightScene.thunderSFX,
            SKAction.run({[weak self] in
                self?.opponent?.isHidden = false
                self?.state.transition(to: .fighting)
                self?.turnOnLights()
                HapticsService.shared.bossIntro()
            })]))
        } else if opponent == "ghost" {
            self.opponent?.alpha = 0
            self.run(SKAction.sequence([FightScene.ghostAppearSFX,
                                        SKAction.run({[weak self] in
                                            self?.opponent?.run(SKAction.fadeIn(withDuration: 1.0))
                                        }),SKAction.wait(forDuration: 1.0),
                                        SKAction.run({[weak self] in
                                            self?.state.transition(to: .fighting)
                                            self?.opponent?.head?.run((self?.opponent?.headFrontPunchAnimation!)!)
                                        })]))

        } else if opponent == "witch" {
            self.opponent?.opponent?.alpha = 0
            self.run(SKAction.sequence([FightScene.witchAppearSFX,
                                        SKAction.run({[weak self] in
                                            self?.opponent?.fireballAppear()
                                        }),SKAction.wait(forDuration: 1.0),
                                           SKAction.run({[weak self] in
                                            self?.state.transition(to: .fighting)
                                            self?.opponent?.head?.run((self?.opponent?.headFrontPunchAnimation!)!)
                                           })]))

        }else if opponent == "devil" {
            self.opponent?.opponent?.alpha = 0
            self.run(SKAction.sequence([FightScene.devilAppearSFX,
                                        SKAction.run({[weak self] in
                                            self?.opponent?.fireballAppear()
                                        }),SKAction.wait(forDuration: 1.0),
                                           SKAction.run({[weak self] in
                                            self?.state.transition(to: .fighting)
                                            self?.opponent?.head?.run((self?.opponent?.headFrontPunchAnimation!)!)
                                           })]))

        }else {
            self.state.transition(to: .fighting)
        }
    }
    
    override func didMove(to view: SKView) {
        #if (arch(i386) || arch(x86_64))
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeRight.direction = UISwipeGestureRecognizer.Direction.right
            self.view?.addGestureRecognizer(swipeRight)

            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeRight.direction = UISwipeGestureRecognizer.Direction.left
            self.view?.addGestureRecognizer(swipeLeft)
        #else
            motionManager = CMMotionManager()

            motionManager.startGyroUpdates()
            motionManager.gyroUpdateInterval = 0.05
            listenForTilt = true
        #endif

        let twoFingerTap = UITapGestureRecognizer(target: self, action: #selector(self.handleTwoFingerTap))
        twoFingerTap.numberOfTouchesRequired = 2
        view.addGestureRecognizer(twoFingerTap)

        installPauseButton(in: view.bounds)
        installPauseOverlay(in: view.bounds)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)

        state.onChange = { [weak self] _, next in
            self?.applyState(next)
        }
    }

    @objc func handleTwoFingerTap() {
        togglePause()
    }

    @objc func appWillResignActive() {
        if state.current == .fighting {
            requestPause()
        }
    }

    private func installPauseButton(in bounds: CGRect) {
        let size: CGFloat = 36
        let inset: CGFloat = 16
        let button = SKShapeNode(rectOf: CGSize(width: size, height: size), cornerRadius: 6)
        button.fillColor = SKColor(white: 0.0, alpha: 0.55)
        button.strokeColor = SKColor(white: 1.0, alpha: 0.7)
        button.lineWidth = 1.5
        button.position = CGPoint(x: bounds.width - inset - size / 2,
                                  y: bounds.height - inset - size / 2)
        button.zPosition = 50
        button.name = "pauseButton"

        let barWidth: CGFloat = 4
        let barHeight: CGFloat = 18
        let gap: CGFloat = 4
        for offset in [-gap, gap] {
            let bar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight))
            bar.fillColor = SKColor.white
            bar.strokeColor = .clear
            bar.position = CGPoint(x: offset, y: 0)
            button.addChild(bar)
        }
        self.addChild(button)
        self.pauseButton = button
    }

    private func installPauseOverlay(in bounds: CGRect) {
        let overlay = PauseOverlay(size: bounds.size)
        overlay.zPosition = 100
        overlay.isHidden = true
        overlay.onResume = { [weak self] in self?.requestResume() }
        overlay.onRestart = { [weak self] in self?.restartScene() }
        overlay.onQuit = { [weak self] in self?.quitToMenu() }
        self.addChild(overlay)
        self.pauseOverlay = overlay
    }

    func togglePause() {
        switch state.current {
        case .fighting: requestPause()
        case .paused: requestResume()
        default: break
        }
    }

    func requestPause() {
        guard state.current == .fighting else { return }
        state.transition(to: .paused)
    }

    func requestResume() {
        guard state.current == .paused else { return }
        state.transition(to: .fighting)
    }

    private func applyState(_ state: FightState) {
        switch state {
        case .paused:
            pausableNodes.forEach { $0.isPaused = true }
            pauseOverlay?.isHidden = false
            pauseOverlay?.alpha = 0
            pauseOverlay?.run(SKAction.fadeAlpha(to: 1.0, duration: 0.15))
            pauseButton?.isHidden = true
            listenForTilt = false
        case .fighting:
            pausableNodes.forEach { $0.isPaused = false }
            pauseOverlay?.run(SKAction.sequence([
                SKAction.fadeAlpha(to: 0, duration: 0.15),
                SKAction.run { [weak self] in self?.pauseOverlay?.isHidden = true }
            ]))
            pauseButton?.isHidden = false
            listenForTilt = true
        case .victory, .defeat:
            pauseButton?.isHidden = true
        case .intro:
            pauseButton?.isHidden = false
        }
    }

    private func restartScene() {
        let opponentName: String
        if (opponent as? Ghost) != nil { opponentName = "ghost" }
        else if (opponent as? Witch) != nil { opponentName = "witch" }
        else if (opponent as? Devil) != nil { opponentName = "devil" }
        else { opponentName = "boss" }

        let scene = FightScene(frame: frame, backgroundColor: self.backgroundColor, opponent: opponentName, BattleManager.level)
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.4))
    }

    private func quitToMenu() {
        let scene = MenuScene(frame: frame, opponents: BattleManager.opponentNames, startWith: 0)
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.4))
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                self.jukeRight()
            case UISwipeGestureRecognizer.Direction.down:
                print("Swiped down")
            case UISwipeGestureRecognizer.Direction.left:
                self.jukeLeft()
            case UISwipeGestureRecognizer.Direction.up:
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
        if !self.state.current.runsSimulation
        {
            return
        }


        self.opponent?.update(currentTime)
        self.controls?.update(currentTime)
        self.player?.update()
        self.player?.updateStamina(currentTime: currentTime)
        if let staminaPct = self.player?.staminaPercent {
            self.controls?.setStamina(percent: staminaPct)
        }
        
        
        #if !(arch(i386) || arch(x86_64))
            if !listenForTilt {
                return
            }
            if let gyroData = motionManager.gyroData {
                let adjustedTilt = Int(gyroData.rotationRate.x * 5)
//               print("accelerometerData.acceleration.x = \(Int(gyroData.rotationRate.z * 10))")
                if abs(adjustedTilt) > 10 {
                    self.juke(amount: adjustedTilt)
                }
                
                let adjustedYTilt = Int(gyroData.rotationRate.y * 5)
                //               print("accelerometerData.acceleration.x = \(Int(gyroData.rotationRate.z * 10))")
                if abs(adjustedYTilt) > 10 {
                    self.enemyZoom(amount: adjustedYTilt)
                }
            }
        #endif
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if state.current == .paused {
            if let touch = touches.first {
                pauseOverlay?.handleTap(at: touch.location(in: self))
            }
            return
        }

        if let touch = touches.first, let button = pauseButton {
            let p = touch.location(in: self)
            if button.frame.insetBy(dx: -8, dy: -8).contains(p) {
                requestPause()
                return
            }
        }

        if !self.state.current.acceptsInput
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
        if !self.state.current.acceptsInput
        {
            return
        }
        
        self.controls?.touchEnded(location: pos, touch:touch)
    }
    
    func punchRight(power:CGFloat) {
        let cancelMul = self.player?.consumePunchTiming() ?? 1.0
        let staminaMul = self.player?.staminaPowerMultiplier ?? 1.0
        let finalPower = power * cancelMul * staminaMul
        let isHaymaker = power > 5
        self.player?.consumeStamina(forHaymaker: isHaymaker)
        self.player?.punchRight(finalPower)
        if (self.opponent?.willRightPunchConnect(finalPower))! {
            if finalPower < 3 {
                self.run(FightScene.lightPunchSound)
            } else if finalPower < 7 {
                self.run((self.opponent?.mediumPunchSFX())!)
            } else {
                self.run((self.opponent?.heavyPunchSFX())!)
            }
            self.battleManager?.playerConnect(power: finalPower)
            self.opponent?.hitRecoil(.right, power:finalPower)
            HapticsService.shared.punchConnect(power: finalPower)
            if cancelMul > 1.0 {
                cancelChainShake(intensity: cancelMul - 1.0)
                HapticsService.shared.cancelChainTick()
            }
        }
//        self.run(punchSound)
    }
    func punchLeft(power:CGFloat) {
        let cancelMul = self.player?.consumePunchTiming() ?? 1.0
        let staminaMul = self.player?.staminaPowerMultiplier ?? 1.0
        let finalPower = power * cancelMul * staminaMul
        let isHaymaker = power > 5
        self.player?.consumeStamina(forHaymaker: isHaymaker)
        self.player?.punchLeft(finalPower)
        if (self.opponent?.willLeftPunchConnect(finalPower))! {
            if finalPower < 3 {
                self.run(FightScene.lightPunchSound)
            } else if finalPower < 7 {
                self.run((self.opponent?.mediumPunchSFX())!)
            } else {
                self.run((self.opponent?.heavyPunchSFX())!)
            }
            self.battleManager?.playerConnect(power: finalPower)
             self.opponent?.hitRecoil(.left, power:finalPower)
            HapticsService.shared.punchConnect(power: finalPower)
            if cancelMul > 1.0 {
                cancelChainShake(intensity: cancelMul - 1.0)
                HapticsService.shared.cancelChainTick()
            }
        }
//        self.run(punchSound)
    }

    private func cancelChainShake(intensity: CGFloat) {
        let mag = min(8.0, 4.0 + intensity * 10.0)
        let dx = CGFloat.random(in: -mag...mag)
        let dy = CGFloat.random(in: -mag...mag)
        ghostHolder?.run(SKAction.sequence([
            SKAction.moveBy(x: dx, y: dy, duration: 0.02),
            SKAction.moveBy(x: -dx, y: -dy, duration: 0.05)
        ]))
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
        self.state.transition(to: .victory)
        self.room.openPortal()
        self.controls?.removeFromParent()
        self.run(SKAction.sequence([ FightScene.youWinSound, SKAction.wait(forDuration: 0.5), SKAction.run({[weak self] in
            self?.opponent?.punchedToHell()
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
            scene = MenuScene(frame: frame, opponents:BattleManager.opponentNames, startWith:1, true)
        } else if (self.opponent as? Witch) != nil {
            scene = MenuScene(frame: frame, opponents:BattleManager.opponentNames, startWith:2, true)
        } else if (self.opponent as? Devil) != nil {
            scene = MenuScene(frame: frame, opponents:BattleManager.opponentNames, startWith:3, true)
        } else {
            BattleManager.multiplier += 1
            BattleManager.level = 1
            scene = MenuScene(frame: frame, opponents:BattleManager.opponentNames, startWith:0)
        }
        
        
//        self.view?.presentScene(scene)
        
        self.view?.presentScene(scene, transition: reveal)
    }
    func playerLost(){
//        self.playerWon()
        self.effectsLayer?.turnOffLights()
        self.controls?.removeFromParent()
        self.player?.removeFromParent()
        self.run(FightScene.youLoseSound)
        self.state.transition(to: .defeat)
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
        } else if (self.opponent as? Devil) != nil {
            scene = MenuScene(frame: frame, diedAt:2)
        } else {
            scene = MenuScene(frame: frame, diedAt:0)
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
            HapticsService.shared.playerHit()
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
            HapticsService.shared.playerHit()
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
        self.run(FightScene.goInvisibleSound)
    }
    
    func superAttack(){
        self.run(FightScene.superAttackSound)
    }
    
    func playerPunchBlocked(){
        self.run(FightScene.lightPunchSound)
    }
    
    func fireBall(){
        self.run(FightScene.fireballSFX)
    }
    
    func lightning(){
        self.run(FightScene.lightningSFX)
    }
    
    func turnOffLights(){
        self.run(FightScene.lightsOutSound)
        self.effectsLayer?.turnOffLights()
    }
    func turnOnLights(){
        self.effectsLayer?.turnOnLights()
    }
    
    func juke(amount:Int) {
        listenForTilt = false
        
        
        self.ghostHolder?.run(SKAction.sequence([SKAction.move(to: CGPoint(x:amount * 10, y:0), duration: 0.3), SKAction.wait(forDuration: 0.1), SKAction.move(to: CGPoint(x:0, y:0), duration: 0.4), SKAction.run({[weak self] in
            self?.listenForTilt = true
        })]))
        self.room.run(SKAction.sequence([SKAction.move(to: CGPoint(x:amount * 3, y:0), duration: 0.3), SKAction.wait(forDuration: 0.1),SKAction.move(to: CGPoint(x:0, y:0), duration: 0.4)]))
    }
    
    func jukeRight() {
        listenForTilt = false
        
        self.ghostHolder?.run(SKAction.sequence([SKAction.move(to: CGPoint(x:-300, y:0), duration: 0.3), SKAction.wait(forDuration: 0.1), SKAction.move(to: CGPoint(x:0, y:0), duration: 0.4), SKAction.run({[weak self] in
            self?.listenForTilt = true
        })]))
        self.room.run(SKAction.sequence([SKAction.move(to: CGPoint(x:-200, y:0), duration: 0.3), SKAction.wait(forDuration: 0.1),SKAction.move(to: CGPoint(x:0, y:0), duration: 0.4)]))
    }
    func jukeLeft() {
        listenForTilt = false
        self.ghostHolder?.run(SKAction.sequence([SKAction.move(to: CGPoint(x:300, y:0), duration: 0.3), SKAction.wait(forDuration: 0.1),SKAction.move(to: CGPoint(x:0, y:0), duration: 0.4), SKAction.run({[weak self] in
            self?.listenForTilt = true
        })]))
        self.room.run(SKAction.sequence([SKAction.move(to: CGPoint(x:200, y:0), duration: 0.3), SKAction.wait(forDuration: 0.1),SKAction.move(to: CGPoint(x:0, y:0), duration: 0.4)]))
    }
    func showDamage(node:SKSpriteNode){
        self.effectsLayer?.addChild(node)
    }
    func enemyZoom(amount:Int){
        let scaleAmount:CGFloat = CGFloat(100 + amount)/100.0
        self.opponent?.run(SKAction.scale(to: min(max(0.9, scaleAmount), 1.1), duration: 0.3))
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - PauseOverlay

final class PauseOverlay: SKNode {
    private let backdrop: SKShapeNode
    private let panel: SKShapeNode
    private let resumeButton: SKShapeNode
    private let restartButton: SKShapeNode
    private let quitButton: SKShapeNode

    var onResume: (() -> Void)?
    var onRestart: (() -> Void)?
    var onQuit: (() -> Void)?

    init(size: CGSize) {
        backdrop = SKShapeNode(rectOf: size)
        backdrop.fillColor = SKColor(white: 0, alpha: 0.7)
        backdrop.strokeColor = .clear
        backdrop.position = CGPoint(x: size.width / 2, y: size.height / 2)

        let panelSize = CGSize(width: 320, height: 220)
        panel = SKShapeNode(rectOf: panelSize, cornerRadius: 12)
        panel.fillColor = SKColor(white: 0.08, alpha: 0.95)
        panel.strokeColor = SKColor(white: 1, alpha: 0.25)
        panel.lineWidth = 1
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)

        resumeButton = PauseOverlay.makeButton(title: "Resume", width: 240)
        resumeButton.position = CGPoint(x: 0, y: 60)
        restartButton = PauseOverlay.makeButton(title: "Restart", width: 240)
        restartButton.position = CGPoint(x: 0, y: 10)
        quitButton = PauseOverlay.makeButton(title: "Quit", width: 240)
        quitButton.position = CGPoint(x: 0, y: -40)

        super.init()

        addChild(backdrop)
        panel.addChild(resumeButton)
        panel.addChild(restartButton)
        panel.addChild(quitButton)
        addChild(panel)

        let title = SKLabelNode(text: "Paused")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: panelSize.height / 2 - 36)
        title.verticalAlignmentMode = .center
        panel.addChild(title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func makeButton(title: String, width: CGFloat) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: width, height: 44), cornerRadius: 8)
        button.fillColor = SKColor(white: 0.2, alpha: 1)
        button.strokeColor = SKColor(white: 1, alpha: 0.4)
        button.lineWidth = 1
        button.name = title.lowercased()
        let label = SKLabelNode(text: title)
        label.fontName = "AvenirNext-DemiBold"
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)
        return button
    }

    func handleTap(at scenePoint: CGPoint) {
        let panelPoint = convert(scenePoint, to: panel)
        if resumeButton.frame.contains(panelPoint) { onResume?(); return }
        if restartButton.frame.contains(panelPoint) { onRestart?(); return }
        if quitButton.frame.contains(panelPoint) { onQuit?(); return }
    }
}
