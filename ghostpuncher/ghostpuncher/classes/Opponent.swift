//
//  Opponent.swift
//  ghostpuncher
//
//  Created by Erik James on 10/7/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

protocol OpponentDelegate: class {
    func opponentAttackLeft()
    func opponentAttackRight()
    func turnOffLights()
    func turnOnLights()
}

enum GameEvents:UInt8
{
    case empty
    case nothing
    case playerRightPunchConnect
    case playerRightPunchFail
    case playerLeftPunchConnect
    case playerLeftPunchFail
    case playerLeftKickConnect
    case playerLeftKickFail
    case playerRightKickConnect
    case playerRightKickFail
    case ghostRightAttackConnect
    case ghostRightAttackFail
    case ghostLeftAttackConnect
    case ghostLeftAttackFail
    case ghostDodgeRight
    case ghostDodgeLeft
    case ghostGoInvisible
    case ghostComboAttack1
}
enum Direction:UInt8
{
    case left
    case right
}

class Opponent:SKNode
{
    var opponent:SKNode!
    var opponentName:String
    var opponentFrame:CGRect
    var rightArmAttack:SKAction?
    var leftArmAttack:SKAction?
    var headAnimation:SKAction?
    
    var leftArm:SKNode?
    var rightArm:SKNode?
    var head:SKSpriteNode?
    var body:SKNode?
    
    let startPosition:CGPoint
    
    weak var delegate:OpponentDelegate?
    
    let MOVEMENT_KEY  = "movementKey"
    let LEFT_ARM_KEY  = "leftArmKey"
    let RIGHT_ARM_KEY = "rightArmKey"
    
    static let LENGTH_OF_MEMORY = 100
    let INACTIVITY_TIME_TO_CHECK = 1.0
    
    var lastActivityCheck = 0.0
    var currentSceneTime = 0.0
    
    var ghostMemory:[GameEvents] = Array(repeating: .empty, count: LENGTH_OF_MEMORY)
    
    func addEvent(event:GameEvents){
        let count = Opponent.LENGTH_OF_MEMORY - 1
        var prev:GameEvents = event
        var current:GameEvents = event
        for index in stride(from: count, to: 0, by: -1) {
            current = ghostMemory[index]
            ghostMemory[index] = prev
            prev = current
        }
        lastActivityCheck = currentSceneTime
        
//        dump(ghostMemory)
        
        
    }
    
    init(frame: CGRect, name:String) {
        self.opponentFrame = frame
        self.opponentName = name
        startPosition = CGPoint(x: 0, y: -self.opponentFrame.size.height * 0.3)
        super.init()
        
        if let ghostScene:SKScene = SKScene(fileNamed: self.opponentName){
            self.opponent = ghostScene.childNode(withName: "opponent")!
            
            self.opponent.removeFromParent();
            self.opponent.position = startPosition
            self.addChild(self.opponent)
            
            let leftArmAtlas = SKTextureAtlas(named: "ghostleftarm.atlas")
            let armFrames:[SKTexture] = [
                leftArmAtlas.textureNamed("left1.png"),
                leftArmAtlas.textureNamed("left2.png"),
                leftArmAtlas.textureNamed("left3.png"),
                leftArmAtlas.textureNamed("left4.png"),
                leftArmAtlas.textureNamed("left2.png"),
                leftArmAtlas.textureNamed("left1.png")]
            
            
            self.leftArmAttack = SKAction.animate(with: armFrames, timePerFrame: 0.1)
            self.leftArm =  self.opponent.childNode(withName: "body")?.childNode(withName: "leftarm")
            
            
            let rightArmAtlas = SKTextureAtlas(named: "ghostrightarm.atlas")
            let rightarmFrames:[SKTexture] = [
                rightArmAtlas.textureNamed("right1.png"),
                rightArmAtlas.textureNamed("right2.png"),
                rightArmAtlas.textureNamed("right3.png"),
                rightArmAtlas.textureNamed("right4.png"),
                rightArmAtlas.textureNamed("right2.png"),
                rightArmAtlas.textureNamed("right1.png")]
            
            
            self.rightArmAttack = SKAction.animate(with: rightarmFrames, timePerFrame: 0.1)
            self.rightArm =  self.opponent.childNode(withName: "body")?.childNode(withName: "rightarm")
            
            let headAtlas = SKTextureAtlas(named: "ghostHead.atlas")
            let headFrames:[SKTexture] = [
                headAtlas.textureNamed("head2.png"),
                headAtlas.textureNamed("head1.png")]
            
            
            self.headAnimation = SKAction.animate(with: headFrames, timePerFrame: 0.4)
            self.head =  self.opponent.childNode(withName: "body")?.childNode(withName: "head") as! SKSpriteNode?
            self.body =  self.opponent.childNode(withName: "body")
        }
    }
    
    func doLeftArmAttack(connected:Bool){
        self.leftArm?.run(self.leftArmAttack!, withKey: LEFT_ARM_KEY)
        
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        self.opponent?.run(sequence)
        
        self.head?.run(self.headAnimation!)
        
        if connected {
            self.addEvent(event: .ghostLeftAttackConnect)
        } else {
            self.addEvent(event: .ghostLeftAttackFail)
        }
    }
    
    func doRightArmAttack(connected:Bool){
        self.rightArm?.run(self.rightArmAttack!, withKey: RIGHT_ARM_KEY)
        
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        self.opponent?.run(sequence)
        
        self.head?.run(self.headAnimation!)
        
        if connected {
            self.addEvent(event: .ghostRightAttackConnect)
        } else {
            self.addEvent(event: .ghostRightAttackFail)
        }
    }
    
    func goInvisible() {
        let sequence = SKAction.sequence([SKAction.fadeAlpha(to: 0.1, duration: 0.1),
                                          SKAction.wait(forDuration: 1.0),
                                          SKAction.fadeAlpha(to: 1.0, duration: 0.1)])
        self.opponent?.run(sequence)
        
        self.addEvent(event: .ghostGoInvisible)
    }
    
    func comboAttack1(){
        self.addEvent(event: .ghostComboAttack1)
        
        let startPos = self.opponent.position
        
        self.delegate?.turnOffLights()
        self.opponent.position = startPosition
        
        
        
        let scaleUp = SKAction.scale(to: 2.0, duration: 0.2)
        let fadeUp = SKAction.fadeAlpha(to: 0.9, duration: 0.3)
        let moveIn = SKAction.moveBy(x: startPosition.x, y: startPosition.y - 100, duration: 0.2)
        let group1 = SKAction.group([SKAction.run({ self.head?.texture = SKTextureAtlas(named: "ghostHead.atlas").textureNamed("head2.png") }),scaleUp, fadeUp,moveIn])
        
        let attackLeft = SKAction.sequence([SKAction.run({ self.delegate?.opponentAttackLeft() }), SKAction.wait(forDuration: 0.3)])
        let attackRight = SKAction.sequence([SKAction.run({ self.delegate?.opponentAttackRight() }), SKAction.wait(forDuration: 0.3)])
        let lightsOn = SKAction.run({self.delegate?.turnOnLights()})
        let lightsOff = SKAction.run({self.delegate?.turnOffLights()})
        
        let attack = SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.run({ self.opponent.setScale(0.0) }), SKAction.wait(forDuration: 3.0), group1, SKAction.run({ self.opponent.position = startPos }), attackLeft, attackRight,attackLeft,attackRight,attackLeft,attackRight,attackLeft,attackRight,lightsOn,SKAction.scale(to: 1.0, duration: 0.2),SKAction.fadeIn(withDuration: 0.1)])
        
        let flashPause = SKAction.wait(forDuration: 0.3)
        
        let flashingLights = SKAction.sequence([SKAction.wait(forDuration: 3.2),lightsOn,flashPause,lightsOff,flashPause,lightsOn,flashPause
            ,lightsOff,flashPause,lightsOn,flashPause,lightsOff,flashPause,lightsOn,flashPause,lightsOff,flashPause,lightsOn,flashPause,lightsOff,flashPause,lightsOn])
        
        self.opponent.run(attack, withKey:MOVEMENT_KEY)
        
        self.run(flashingLights)
    }
    
    func hitRecoil(_ direction:Direction, power:CGFloat){
        
        let moveAmount = power * 2
        
        if self.opponent.action(forKey: MOVEMENT_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.2)
        
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        
        let fadeDown = SKAction.fadeAlpha(to: 0.6, duration: 0.2)
        let fadeUp = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let fadeSequence = SKAction.sequence([fadeDown, fadeUp])
        
        let headRotate1 = SKAction.rotate(byAngle: (direction == .right ? CGFloat(power).degreesToRadians : CGFloat(-power).degreesToRadians), duration: 0.1)
        let headRotate2 = SKAction.rotate(toAngle: CGFloat(0).degreesToRadians, duration: 0.1)
        let headSequence = SKAction.sequence([headRotate1, headRotate2])
        
        self.head?.run(headSequence)
        
        let bodyRotate1 = SKAction.rotate(byAngle: (direction == .right ? CGFloat(1).degreesToRadians : CGFloat(-1).degreesToRadians), duration: 0.1)
        let bodyRotate2 = SKAction.rotate(toAngle: CGFloat(0).degreesToRadians, duration: 0.1)
        let bodySequence = SKAction.sequence([bodyRotate1, bodyRotate2])
        
        self.body?.run(bodySequence)
        
        
        let leftArmRotate1 = SKAction.rotate(byAngle: (direction == .right ? CGFloat(moveAmount).degreesToRadians : CGFloat(-moveAmount).degreesToRadians), duration: 0.1)
        let leftArmRotate2 = SKAction.rotate(toAngle: CGFloat(0).degreesToRadians, duration: 0.2)
        let leftArmSequence = SKAction.sequence([leftArmRotate1, leftArmRotate2])
        
        self.leftArm?.run(leftArmSequence)
        self.rightArm?.run(leftArmSequence)
        
        self.opponent?.run(SKAction.group([fadeSequence,sequence, SKAction.moveBy(x: (direction == .right ? -moveAmount : moveAmount), y: 0, duration: 0.1)]), withKey: MOVEMENT_KEY )
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dodgeLeft(){
        self.addEvent(event: .ghostDodgeLeft)
        
        let newPos:CGPoint = CGPoint(x: startPosition.x - 200, y: startPosition.y + CGFloat(arc4random_uniform(UInt32(30))) - CGFloat(arc4random_uniform(UInt32(30))))
        
        let movement:SKAction = SKAction.move(to: newPos, duration: 0.2)
        
        if self.opponent.action(forKey: MOVEMENT_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        
        self.opponent.run(movement, withKey: MOVEMENT_KEY)
        
        self.goInvisible()
    }
    
    func dodgeRight(){
        self.addEvent(event: .ghostDodgeRight)
        
        let newPos:CGPoint = CGPoint(x: startPosition.x + 200, y: startPosition.y + CGFloat(arc4random_uniform(UInt32(30))) - CGFloat(arc4random_uniform(UInt32(30))))
        
        let movement:SKAction = SKAction.move(to: newPos, duration: 0.2)
        
        if self.opponent.action(forKey: MOVEMENT_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        
        self.opponent.run(movement, withKey: MOVEMENT_KEY)
        self.goInvisible()
    }
    
    func checkForAttackTime()->Bool{
        
        return !self.checkFor(events: [.ghostLeftAttackFail, .ghostRightAttackFail,.ghostLeftAttackConnect, .ghostRightAttackConnect], withinLast: 5)
        
    }
    
    func checkDodging()->Bool {
        
        if self.checkLast(10, eventsEqualAny: [.playerRightPunchConnect, .playerLeftPunchConnect, .playerLeftKickConnect, .playerRightKickConnect],
                          excluding: [.nothing, .playerRightPunchFail, .playerLeftPunchFail, .playerRightKickFail, .playerLeftKickFail, .ghostDodgeLeft, .ghostDodgeRight, .ghostGoInvisible, .ghostLeftAttackFail, .ghostRightAttackFail]){
            
            self.comboAttack1()
            
            return true
        }
        
        if self.checkLast(3, eventsEqual: .playerRightPunchConnect){
            self.dodgeLeft()
            return true
        }
        
        if self.checkLast(3, eventsEqual: .playerRightKickConnect){
            self.dodgeLeft()
            return true
        }
        
        if self.checkLast(3, eventsEqual: .playerLeftPunchConnect){
            self.dodgeRight()
            return true
        }
        
        if self.checkLast(3, eventsEqual: .playerLeftKickConnect){
            self.dodgeRight()
            return true
        }
        
        if self.checkLast(3, eventsEqualAny: [.playerRightPunchConnect, .playerLeftPunchConnect, .playerLeftKickConnect, .playerRightKickConnect],
                          excluding: [.nothing, .playerRightPunchFail, .playerLeftPunchFail, .playerRightKickFail, .playerLeftKickFail]){
            
            if self.checkMoreRecent(events: [.playerLeftPunchConnect, .playerRightPunchConnect]) == .playerLeftPunchConnect {
                self.dodgeRight()
            } else {
                self.dodgeLeft()
            }
            
            return true
        }
        
        return false
    }
    
    func checkMoreRecent(events:[GameEvents])->GameEvents
    {
        let count = Opponent.LENGTH_OF_MEMORY - 1
        
        for index in stride(from: count, to: 0, by: -1) {
            if events.contains(ghostMemory[index]){
                return ghostMemory[index]
            }
        }
        
        return .nothing
    }
    
    func checkFor(events:[GameEvents], withinLast amount:Int)->Bool {
        let count = Opponent.LENGTH_OF_MEMORY - 1
        let lower = count - amount
        
        for index in stride(from: count, to: lower, by: -1) {
            if ghostMemory[index] == .empty {
                return true
            }
            if events.contains(ghostMemory[index]){
                return true
            }
        }
        
        return false
    }
    
    func checkLast(_ amount:Int, eventsEqual event:GameEvents)->Bool {
        return self.checkLast(amount, eventsEqual: event, excluding: [])
    }
    
    func checkLast(_ amount:Int, eventsEqual events:[GameEvents])->Bool {
        return self.checkLast(amount, eventsEqualAny: events, excluding: [])
    }
    
    func checkLast(_ amount:Int, eventsEqual event:GameEvents, excluding:[GameEvents] )->Bool{
        return self.checkLast(amount, eventsEqualAny: [event], excluding: excluding)
    }
    
    func checkLast(_ amount:Int, eventsEqualAny events:[GameEvents], excluding:[GameEvents] )->Bool{
        
        let count = Opponent.LENGTH_OF_MEMORY - 1
        var countdown = amount
        
        for index in stride(from: count, to: 0, by: -1) {
            let thisEvent = ghostMemory[index]
            if excluding.contains(thisEvent) {
                continue
            }
            countdown -= 1
            if !events.contains(thisEvent) {
                return false
            }
            if countdown <= 0 {
                break
            }
        }
        
        return true
    }
    
    func spark(){
        let sparkEmmiter = SKEmitterNode(fileNamed: "ectoPlasm.sks")!
        sparkEmmiter.position = CGPoint(x: -8, y: 100)
        sparkEmmiter.name = "sparkEmmitter"
        sparkEmmiter.zPosition = 200
        sparkEmmiter.targetNode = self.head!
        sparkEmmiter.particleLifetime = 1
        
        self.head?.addChild(sparkEmmiter)
    }
    
    func update(_ currentTime: TimeInterval){
        currentSceneTime = currentTime
        
        if self.checkDodging() {
            return
        }
        
        if self.opponent.action(forKey: MOVEMENT_KEY) == nil {
            let newPos:CGPoint = CGPoint(x: startPosition.x + CGFloat(arc4random_uniform(UInt32(100))) - CGFloat(arc4random_uniform(UInt32(100))), y: startPosition.y + CGFloat(arc4random_uniform(UInt32(30))) - CGFloat(arc4random_uniform(UInt32(30))))
            
            let movement:SKAction = SKAction.move(to: newPos, duration: 4)
            self.opponent.run(movement, withKey: MOVEMENT_KEY)
        }
        
        if self.opponent.alpha < 1.0 {
            return
        }
        
        if self.checkForAttackTime()
        {
            if Int(arc4random_uniform(UInt32(1))) == 1 {
                delegate?.opponentAttackLeft()
            } else {
                delegate?.opponentAttackRight()
            }
            
            return
        }
        
        if !self.checkFor(events: [.ghostComboAttack1], withinLast: 40){
            self.comboAttack1()
            return
        }
        

        
        if currentSceneTime - lastActivityCheck > INACTIVITY_TIME_TO_CHECK {
            self.addEvent(event: .nothing)
        }
    }
    
    func willRightPunchConnect() ->Bool {
        print(self.opponent.position.x)
        let willConnect = self.opponent?.alpha == 1 && self.opponent.position.x > -5 && self.opponent.position.x < 150
        if willConnect {
            self.addEvent(event: .playerRightPunchConnect)
            self.spark()
        } else {
            self.addEvent(event: .playerRightPunchFail)
        }
        return willConnect
    }
    func willLeftPunchConnect() ->Bool {
        let willConnect = self.opponent?.alpha == 1 && self.opponent.position.x < 5 && self.opponent.position.x > -150
        if willConnect {
            self.spark()
            self.addEvent(event: .playerLeftPunchConnect)
        } else {
            self.addEvent(event: .playerLeftPunchFail)
        }
        return willConnect
    }
    func willLeftKickConnect() ->Bool {
        let willConnect = self.opponent?.alpha == 1 && self.opponent.position.x < 12 && self.opponent.position.x > -12
        if willConnect {
            self.addEvent(event: .playerLeftKickConnect)
        } else {
            self.addEvent(event: .playerLeftKickFail)
        }
        return willConnect
    }
    
    func willRightKickConnect() ->Bool {
        let willConnect = self.opponent?.alpha == 1 && self.opponent.position.x < 12 && self.opponent.position.x > -12
        if willConnect {
            self.addEvent(event: .playerRightKickConnect)
        } else {
            self.addEvent(event: .playerRightKickFail)
        }
        return willConnect
    }
}
