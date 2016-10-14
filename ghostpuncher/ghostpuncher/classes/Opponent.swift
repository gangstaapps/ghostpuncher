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
    var head:SKNode?
    
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
            self.head =  self.opponent.childNode(withName: "body")?.childNode(withName: "head")
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
    }
    
    func hitRecoil(_ direction:Direction){
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.2)
        
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        self.opponent?.run(sequence)
        
        let rotate1 = SKAction.rotate(byAngle: (direction == .right ? CGFloat(10).degreesToRadians : CGFloat(-10).degreesToRadians), duration: 0.1)
        let rotate2 = SKAction.rotate(toAngle: CGFloat(0).degreesToRadians, duration: 0.1)
        let headSequence = SKAction.sequence([rotate1, rotate2])
        
        self.head?.run(headSequence)
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
    
    func checkDodging()->Bool {
        
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
        
        return false
    }
    
    func checkLast(_ amount:Int, eventsEqual event:GameEvents)->Bool {
        return self.checkLast(amount, eventsEqual: event, excluding: [])
    }
    
    func checkLast(_ amount:Int, eventsEqual event:GameEvents, excluding:[GameEvents] )->Bool{
        
        let count = Opponent.LENGTH_OF_MEMORY - 1
        var countdown = amount
        
        for index in stride(from: count, to: 0, by: -1) {
            if excluding.contains(event) {
                continue
            }
            countdown -= 1
            if ghostMemory[index] != event {
                return false
            }
            if countdown <= 0 {
                break
            }
        }
        
        return true
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
        if Int(arc4random_uniform(UInt32(100))) == 13 && self.leftArm?.action(forKey: LEFT_ARM_KEY) == nil{
            delegate?.opponentAttackLeft()
            return
        }
        
        if Int(arc4random_uniform(UInt32(100))) == 7  && self.rightArm?.action(forKey: RIGHT_ARM_KEY) == nil{
            delegate?.opponentAttackRight()
            return
        }
        if currentSceneTime - lastActivityCheck > INACTIVITY_TIME_TO_CHECK {
            self.addEvent(event: .nothing)
        }
    }
    
    func willRightPunchConnect() ->Bool {
        print(self.opponent.position.x)
        let willConnect = self.opponent.position.x > 10 && self.opponent.position.x < 60
        if willConnect {
            self.addEvent(event: .playerRightPunchConnect)
        } else {
            self.addEvent(event: .playerRightPunchFail)
        }
        return willConnect
    }
    func willLeftPunchConnect() ->Bool {
        let willConnect = self.opponent.position.x < 10 && self.opponent.position.x > -50
        if willConnect {
            self.addEvent(event: .playerLeftPunchConnect)
        } else {
            self.addEvent(event: .playerLeftPunchFail)
        }
        return willConnect
    }
    func willLeftKickConnect() ->Bool {
        let willConnect = self.opponent.position.x < 12 && self.opponent.position.x > -12
        if willConnect {
            self.addEvent(event: .playerLeftKickConnect)
        } else {
            self.addEvent(event: .playerLeftKickFail)
        }
        return willConnect
    }
    
    func willRightKickConnect() ->Bool {
        let willConnect = self.opponent.position.x < 12 && self.opponent.position.x > -12
        if willConnect {
            self.addEvent(event: .playerRightKickConnect)
        } else {
            self.addEvent(event: .playerRightKickFail)
        }
        return willConnect
    }
}
