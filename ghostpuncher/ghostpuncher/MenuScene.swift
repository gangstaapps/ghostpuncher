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
    private var settingsButton: SKShapeNode?
    
    
    
    static let selectSound = SKAction.playSoundFileNamed("select.wav", waitForCompletion: false)
    static let buzzSound = SKAction.playSoundFileNamed("buzz.wav", waitForCompletion: false)
    static let thumpSound = SKAction.playSoundFileNamed("groundThump.wav", waitForCompletion: false)
    static let slashSound = SKAction.playSoundFileNamed("slash.wav", waitForCompletion: false)
    static let slash2Sound = SKAction.playSoundFileNamed("slash2.wav", waitForCompletion: false)
    static let mediumPunchSound = SKAction.playSoundFileNamed("sfx_punch3.wav", waitForCompletion: false)
    static let evilLaughSound = SKAction.playSoundFileNamed("evilLaugh.wav", waitForCompletion: false)
    
    static let levelAppear = SKAction.playSoundFileNamed("LevelAppear.wav", waitForCompletion: false)
    
    
    
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
            MenuScene.mediumPunchSound
        ]))
        
        logo?.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.moveTo(x: frame.midX, duration: 0.0),
            MenuScene.evilLaughSound
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
        backgroundMusic.run(SKAction.changeVolume(to: GameSettings.shared.musicVolume, duration: 0))
        self.addChild(backgroundMusic)

        let gear = SKShapeNode(circleOfRadius: 22)
        gear.position = CGPoint(x: frame.size.width - 36, y: frame.size.height - 36)
        gear.fillColor = SKColor(white: 0, alpha: 0.55)
        gear.strokeColor = SKColor(white: 1, alpha: 0.7)
        gear.lineWidth = 1.5
        gear.zPosition = 50
        gear.name = "settingsButton"
        let label = SKLabelNode(text: "\u{2699}")
        label.fontName = "Helvetica"
        label.fontSize = 26
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -1)
        gear.addChild(label)
        self.addChild(gear)
        self.settingsButton = gear

        if !GameSettings.shared.tutorialCompleted {
            self.run(SKAction.sequence([
                SKAction.wait(forDuration: 1.2),
                SKAction.run { [weak self] in
                    guard let self = self else { return }
                    let tutorial = TutorialScene(frame: self.frame)
                    self.view?.presentScene(tutorial, transition: SKTransition.fade(withDuration: 0.4))
                }
            ]))
        }
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
        
        var theLevel = min(BattleManager.level, 3)
        
        if BattleManager.level == 2 || BattleManager.level == 3 {
            let bossbkg = SKSpriteNode(imageNamed: "boss_background\(theLevel - 1)")
            bossbkg.size = frame.size
            bossbkg.position = CGPoint(x: frame.midX, y: frame.midY)
            self.addChild(bossbkg)
        } else if BattleManager.level > 3 {
            opponentsToDisplay = ["boss"]
            theLevel = 0
        }
        
        if !animateIn {
            self.run(MenuScene.levelAppear)
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
                    var sequence:[SKAction] = [SKAction.moveTo(y: frame.midY, duration: 0.3), MenuScene.thumpSound]
                    slashes.forEach({slash in
                        sequence.append(SKAction.wait(forDuration: 0.3))
                        sequence.append(MenuScene.slash2Sound)
                        sequence.append(SKAction.run({[weak self] in
                            self?.addChild(slash)
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
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: 2.0), SKAction.run {[weak self] in
                BattleManager.level += 1
                let reveal = SKTransition.crossFade(withDuration: 1.0)
                let scene = MenuScene(frame: (self?.frame)!, opponents:BattleManager.opponentNames, startWith:0)
                self?.view?.presentScene(scene, transition: reveal)
                }]))
            
            return
        }
        
        let button = self.opponents?[startWith]
        
        
        
        button?.run(SKAction.sequence([SKAction.wait(forDuration: 1.0), SKAction.run({[weak self] in
            self?.run(MenuScene.buzzSound)
            button?.texture = SKTexture(imageNamed: "\(button?.userData?["name"] as! String)_reg")
        }),SKAction.wait(forDuration: 0.5), SKAction.run({
            button?.texture = SKTexture(imageNamed: "\(button?.userData?["name"] as! String)_rol")
        }),SKAction.wait(forDuration: 0.1), SKAction.run({[weak self] in
            self?.run(MenuScene.buzzSound)
            button?.texture = SKTexture(imageNamed: "\(button?.userData?["name"] as! String)_reg")
        }),SKAction.wait(forDuration: 0.2), SKAction.run({
            button?.texture = SKTexture(imageNamed: "\(button?.userData?["name"] as! String)_rol")
        }),SKAction.wait(forDuration: 0.1), SKAction.run({[weak self] in
            self?.run(MenuScene.buzzSound)
            button?.texture = SKTexture(imageNamed: "\(button?.userData?["name"] as! String)_reg")
        }), SKAction.wait(forDuration: 1.0), SKAction.run({[weak self] in
            let scene = FightScene(frame: (self?.frame)!, backgroundColor: UIColor.black, opponent: button?.userData?["name"] as! String, BattleManager.level)
            
            self?.view?.presentScene(scene)
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

        if let gear = self.settingsButton, gear.frame.insetBy(dx: -8, dy: -8).contains(pos) {
            let scene = SettingsScene(frame: frame)
            self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.25))
            return
        }

        self.fightButton?.isHidden = false
        if self.checkFightPressed(atPoint: pos) {
            self.run(MenuScene.selectSound)
            //            let reveal = SKTransition.push(with: SKTransitionDirection.right, duration: 2.0)
            self.fightButtonRol?.isHidden = true
            logo?.run(SKAction.moveBy(x: -self.frame.size.width/2, y: 0, duration: 0.2))
            fightButton?.run(SKAction.sequence([SKAction.moveBy(x: -self.frame.size.width/2, y: 0, duration: 0.2),
                                                SKAction.run({[weak self] in
//                                                   BattleManager.level  = 3
//                                                    BattleManager.multiplier = 2
                                                    let scene = MenuScene(frame: (self?.frame)!, opponents:BattleManager.opponentNames, startWith:0)
                                                    self?.view?.presentScene(scene)
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

// MARK: - SettingsScene

final class SettingsScene: SKScene {
    private struct Row {
        let key: String
        let label: String
        let getter: () -> Bool
        let setter: (Bool) -> Void
    }

    private var rows: [Row] = []
    private var rowNodes: [SKNode] = []
    private var sfxKnob: SKShapeNode?
    private var musicKnob: SKShapeNode?
    private var sfxTrack: SKShapeNode?
    private var musicTrack: SKShapeNode?
    private var draggingKnob: SKShapeNode?

    init(frame: CGRect) {
        super.init(size: frame.size)
        self.backgroundColor = SKColor(white: 0.05, alpha: 1)

        let title = SKLabelNode(text: "Settings")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: frame.midX, y: frame.size.height - 44)
        addChild(title)

        let settings = GameSettings.shared

        rows = [
            Row(key: "tilt", label: "Tilt to Dodge",
                getter: { settings.tiltControls },
                setter: { settings.tiltControls = $0 }),
            Row(key: "haptics", label: "Haptic Feedback",
                getter: { settings.haptics },
                setter: { settings.haptics = $0 }),
            Row(key: "reduceMotion", label: "Reduce Motion",
                getter: { settings.reduceMotion },
                setter: { settings.reduceMotion = $0 }),
            Row(key: "largeTargets", label: "Larger Buttons",
                getter: { settings.largeTargets },
                setter: { settings.largeTargets = $0 }),
        ]

        let startY = frame.size.height - 100
        let leftX = frame.size.width * 0.18
        let rightX = frame.size.width * 0.82
        let rowHeight: CGFloat = 36

        addSlider(title: "SFX Volume",
                  y: startY,
                  leftX: leftX, rightX: rightX,
                  value: CGFloat(settings.sfxVolume),
                  isSfx: true)

        addSlider(title: "Music Volume",
                  y: startY - rowHeight,
                  leftX: leftX, rightX: rightX,
                  value: CGFloat(settings.musicVolume),
                  isSfx: false)

        for (i, row) in rows.enumerated() {
            let y = startY - rowHeight * CGFloat(i + 2)
            let node = makeToggleRow(row: row, y: y, leftX: leftX, rightX: rightX)
            rowNodes.append(node)
            addChild(node)
        }

        let replay = SKLabelNode(text: "Replay Tutorial")
        replay.fontName = "AvenirNext-DemiBold"
        replay.fontSize = 16
        replay.fontColor = SKColor(white: 0.8, alpha: 1)
        replay.position = CGPoint(x: frame.midX, y: 72)
        replay.name = "replayTutorial"
        addChild(replay)

        let back = SKLabelNode(text: "Back")
        back.fontName = "AvenirNext-DemiBold"
        back.fontSize = 18
        back.fontColor = .white
        back.position = CGPoint(x: frame.midX, y: 36)
        back.name = "back"
        addChild(back)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSlider(title: String, y: CGFloat, leftX: CGFloat, rightX: CGFloat, value: CGFloat, isSfx: Bool) {
        let label = SKLabelNode(text: title)
        label.fontName = "AvenirNext-DemiBold"
        label.fontSize = 16
        label.fontColor = .white
        label.position = CGPoint(x: leftX, y: y - 6)
        label.horizontalAlignmentMode = .left
        addChild(label)

        let trackWidth: CGFloat = 180
        let track = SKShapeNode(rectOf: CGSize(width: trackWidth, height: 4), cornerRadius: 2)
        track.fillColor = SKColor(white: 0.3, alpha: 1)
        track.strokeColor = .clear
        track.position = CGPoint(x: rightX - trackWidth / 2, y: y)
        track.name = isSfx ? "sfxTrack" : "musicTrack"
        addChild(track)

        let knob = SKShapeNode(circleOfRadius: 11)
        knob.fillColor = .white
        knob.strokeColor = .clear
        let knobX = (rightX - trackWidth) + trackWidth * value
        knob.position = CGPoint(x: knobX, y: y)
        knob.name = isSfx ? "sfxKnob" : "musicKnob"
        knob.zPosition = 1
        addChild(knob)

        if isSfx {
            sfxKnob = knob
            sfxTrack = track
        } else {
            musicKnob = knob
            musicTrack = track
        }
    }

    private func makeToggleRow(row: Row, y: CGFloat, leftX: CGFloat, rightX: CGFloat) -> SKNode {
        let container = SKNode()
        container.name = "row.\(row.key)"

        let label = SKLabelNode(text: row.label)
        label.fontName = "AvenirNext-DemiBold"
        label.fontSize = 16
        label.fontColor = .white
        label.position = CGPoint(x: leftX, y: y - 6)
        label.horizontalAlignmentMode = .left
        container.addChild(label)

        let track = SKShapeNode(rectOf: CGSize(width: 48, height: 24), cornerRadius: 12)
        track.position = CGPoint(x: rightX - 24, y: y)
        track.name = "track.\(row.key)"
        track.fillColor = row.getter() ? SKColor.systemGreen : SKColor(white: 0.3, alpha: 1)
        track.strokeColor = .clear
        container.addChild(track)

        let knob = SKShapeNode(circleOfRadius: 10)
        knob.fillColor = .white
        knob.strokeColor = .clear
        knob.position = CGPoint(x: track.position.x + (row.getter() ? 12 : -12), y: y)
        knob.name = "knob.\(row.key)"
        container.addChild(knob)

        return container
    }

    private func refreshToggle(rowKey: String) {
        guard let row = rows.first(where: { $0.key == rowKey }),
              let container = rowNodes.first(where: { $0.name == "row.\(rowKey)" }),
              let track = container.childNode(withName: "track.\(rowKey)") as? SKShapeNode,
              let knob = container.childNode(withName: "knob.\(rowKey)") as? SKShapeNode else { return }
        let value = row.getter()
        track.fillColor = value ? SKColor.systemGreen : SKColor(white: 0.3, alpha: 1)
        knob.position = CGPoint(x: track.position.x + (value ? 12 : -12), y: knob.position.y)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pos = touch.location(in: self)

        if let sfx = sfxKnob, sfx.frame.insetBy(dx: -12, dy: -12).contains(pos) {
            draggingKnob = sfx
            return
        }
        if let music = musicKnob, music.frame.insetBy(dx: -12, dy: -12).contains(pos) {
            draggingKnob = music
            return
        }

        for row in rows {
            if let container = rowNodes.first(where: { $0.name == "row.\(row.key)" }),
               let track = container.childNode(withName: "track.\(row.key)") as? SKShapeNode,
               track.frame.insetBy(dx: -16, dy: -16).contains(pos) {
                row.setter(!row.getter())
                refreshToggle(rowKey: row.key)
                return
            }
        }

        let nodes = self.nodes(at: pos)
        if nodes.contains(where: { $0.name == "back" }) {
            let menu = MenuScene(frame: frame)
            self.view?.presentScene(menu, transition: SKTransition.fade(withDuration: 0.25))
            return
        }
        if nodes.contains(where: { $0.name == "replayTutorial" }) {
            GameSettings.shared.tutorialCompleted = false
            let tutorial = TutorialScene(frame: frame)
            self.view?.presentScene(tutorial, transition: SKTransition.fade(withDuration: 0.25))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let knob = draggingKnob else { return }
        let pos = touch.location(in: self)
        let track = (knob == sfxKnob) ? sfxTrack : musicTrack
        guard let trackNode = track else { return }
        let trackWidth: CGFloat = 180
        let minX = trackNode.position.x - trackWidth / 2
        let maxX = trackNode.position.x + trackWidth / 2
        let clamped = min(max(pos.x, minX), maxX)
        knob.position = CGPoint(x: clamped, y: trackNode.position.y)
        let value = Float((clamped - minX) / trackWidth)
        if knob == sfxKnob {
            GameSettings.shared.sfxVolume = value
        } else {
            GameSettings.shared.musicVolume = value
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggingKnob = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggingKnob = nil
    }
}

// MARK: - TutorialScene

final class TutorialScene: SKScene {
    private enum Step: Int, CaseIterable {
        case jabLeft
        case jabRight
        case block
        case dodgeLeft
        case dodgeRight
        case done

        var prompt: String {
            switch self {
            case .jabLeft:   return "Tap the LEFT side to jab"
            case .jabRight:  return "Tap the RIGHT side to jab"
            case .block:     return "Tap and HOLD both sides to block"
            case .dodgeLeft: return "Swipe LEFT to dodge"
            case .dodgeRight:return "Swipe RIGHT to dodge"
            case .done:      return "You're ready. Tap to fight."
            }
        }
    }

    private var step: Step = .jabLeft
    private var promptLabel: SKLabelNode!
    private var dummy: SKShapeNode!
    private var leftHoldStart: TimeInterval = 0
    private var rightHoldStart: TimeInterval = 0
    private var lastTouchTime: TimeInterval = 0
    private var swipeStartX: CGFloat = 0
    private var swipeActive: Bool = false

    init(frame: CGRect) {
        super.init(size: frame.size)
        self.backgroundColor = SKColor(red: 0.04, green: 0.04, blue: 0.07, alpha: 1)

        let title = SKLabelNode(text: "Training")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 22
        title.fontColor = SKColor(white: 0.7, alpha: 1)
        title.position = CGPoint(x: frame.midX, y: frame.size.height - 44)
        addChild(title)

        dummy = SKShapeNode(circleOfRadius: 80)
        dummy.fillColor = SKColor(red: 0.35, green: 0.1, blue: 0.15, alpha: 1)
        dummy.strokeColor = SKColor(white: 1, alpha: 0.3)
        dummy.lineWidth = 2
        dummy.position = CGPoint(x: frame.midX, y: frame.midY + 24)
        addChild(dummy)

        let face = SKLabelNode(text: ":|")
        face.fontName = "Menlo-Bold"
        face.fontSize = 36
        face.fontColor = .white
        face.verticalAlignmentMode = .center
        face.position = CGPoint(x: 0, y: 0)
        dummy.addChild(face)

        promptLabel = SKLabelNode(text: step.prompt)
        promptLabel.fontName = "AvenirNext-DemiBold"
        promptLabel.fontSize = 22
        promptLabel.fontColor = .white
        promptLabel.position = CGPoint(x: frame.midX, y: 80)
        addChild(promptLabel)

        let skip = SKLabelNode(text: "Skip")
        skip.fontName = "AvenirNext-Regular"
        skip.fontSize = 14
        skip.fontColor = SKColor(white: 0.6, alpha: 1)
        skip.position = CGPoint(x: frame.size.width - 40, y: 28)
        skip.name = "skip"
        addChild(skip)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func advance() {
        flashSuccess()
        let next = Step(rawValue: step.rawValue + 1) ?? .done
        step = next
        promptLabel.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.15),
            SKAction.run { [weak self] in self?.promptLabel.text = self?.step.prompt },
            SKAction.fadeIn(withDuration: 0.15)
        ]))
    }

    private func flashSuccess() {
        dummy.run(SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.12),
        ]))
        let flash = SKAction.sequence([
            SKAction.run { [weak self] in self?.dummy.strokeColor = .systemGreen },
            SKAction.wait(forDuration: 0.25),
            SKAction.run { [weak self] in self?.dummy.strokeColor = SKColor(white: 1, alpha: 0.3) }
        ])
        dummy.run(flash)
    }

    private func finish() {
        GameSettings.shared.tutorialCompleted = true
        let menu = MenuScene(frame: frame, opponents: BattleManager.opponentNames, startWith: 0)
        self.view?.presentScene(menu, transition: SKTransition.fade(withDuration: 0.4))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let pos = touch.location(in: self)

        if nodes(at: pos).contains(where: { $0.name == "skip" }) {
            finish()
            return
        }

        let isLeft = pos.x < frame.midX
        let now = touch.timestamp
        lastTouchTime = now
        swipeStartX = pos.x
        swipeActive = true

        switch step {
        case .jabLeft where isLeft:  advance()
        case .jabRight where !isLeft: advance()
        case .block:
            if isLeft { leftHoldStart = now } else { rightHoldStart = now }
            if leftHoldStart > 0 && rightHoldStart > 0 {
                advance()
            }
        case .done:
            finish()
        default:
            break
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, swipeActive else { return }
        let pos = touch.location(in: self)
        let dx = pos.x - swipeStartX
        guard abs(dx) > 50 else { return }
        switch step {
        case .dodgeLeft where dx < 0:  swipeActive = false; advance()
        case .dodgeRight where dx > 0: swipeActive = false; advance()
        default: break
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if step == .block {
            leftHoldStart = 0
            rightHoldStart = 0
        }
        swipeActive = false
    }
}
