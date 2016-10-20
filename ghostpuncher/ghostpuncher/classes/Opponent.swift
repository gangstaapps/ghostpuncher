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
    func ghostIsGone()
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
    
    let ghostDeathCycle:SKAction
    let ghostDeath:SKSpriteNode
    
    var headRightPunchAnimation:SKAction?
    var headLeftPunchAnimation:SKAction?
    var headRightPunchAnimationSlow:SKAction?
    var headLeftPunchAnimationSlow:SKAction?
    
    var headFrontPunchAnimation:SKAction?
    var headFrontPunchAnimationSlow:SKAction?
    
    var leftArm:SKNode?
    var rightArm:SKNode?
    var head:SKSpriteNode?
    var body:SKNode?
    
    var ghostEffectNode:SKEffectNode
    
    let startPosition:CGPoint
    
    weak var delegate:OpponentDelegate?
    
    let MOVEMENT_KEY  = "movementKey"
    let LEFT_ARM_KEY  = "leftArmKey"
    let RIGHT_ARM_KEY = "rightArmKey"
    let COMBO_ATTACK_KEY = "comboAttack"
    
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
    }
    
    init(frame: CGRect, name:String) {
        self.opponentFrame = frame
        self.opponentName = name
        startPosition = CGPoint(x: 0, y: -self.opponentFrame.size.height * 0.3)
        ghostEffectNode = SKEffectNode()
        
//        blurFilter = CIFilter(name: "CIBoxBlur")
//        blurFilter?.setDefaults()
//        blurFilter?.setValue(7, forKey: "inputRadius")
        
        let deathAtlas = SKTextureAtlas(named: "ghost_portal.atlas")
        var deathFrames:[SKTexture] = []
        for i in 1...3 {
            deathFrames.append(deathAtlas.textureNamed("ghost\(i).png"))
        }
        
        ghostDeathCycle = SKAction.repeatForever(SKAction.animate(with: deathFrames, timePerFrame: 0.2))
        ghostDeath = SKSpriteNode(texture: deathFrames[0])
        
        super.init()
        
        if let ghostScene:SKScene = SKScene(fileNamed: self.opponentName){
            self.opponent = ghostScene.childNode(withName: "opponent")!
            
            self.opponent.removeFromParent();
            self.opponent.position = startPosition
            
            
            
//            ghostEffectNode.filter = self.blurFilter
//            ghostEffectNode.addChild(self.opponent)
//            
//            self.addChild(ghostEffectNode)
            
            self.addChild(self.opponent)
            
            let leftArmAtlas = SKTextureAtlas(named: "ghostLeftArm.atlas")
            let armFrames:[SKTexture] = [
                leftArmAtlas.textureNamed("ghost_left1.png"),
                leftArmAtlas.textureNamed("ghost_left2.png"),
                leftArmAtlas.textureNamed("ghost_left3.png"),
                leftArmAtlas.textureNamed("ghost_left4.png"),
                leftArmAtlas.textureNamed("ghost_left2.png"),
                leftArmAtlas.textureNamed("ghost_left1.png")]
            
            
            self.leftArmAttack = SKAction.animate(with: armFrames, timePerFrame: 0.1)
            self.leftArm =  self.opponent.childNode(withName: "body")?.childNode(withName: "leftarm")
            
            
            let rightArmAtlas = SKTextureAtlas(named: "ghostRightArm.atlas")
            let rightarmFrames:[SKTexture] = [
                rightArmAtlas.textureNamed("ghost_right1.png"),
                rightArmAtlas.textureNamed("ghost_right2.png"),
                rightArmAtlas.textureNamed("ghost_right3.png"),
                rightArmAtlas.textureNamed("ghost_right4.png"),
                rightArmAtlas.textureNamed("ghost_right2.png"),
                rightArmAtlas.textureNamed("ghost_right1.png")]
            
            
            self.rightArmAttack = SKAction.animate(with: rightarmFrames, timePerFrame: 0.1)
            self.rightArm =  self.opponent.childNode(withName: "body")?.childNode(withName: "rightarm")
            
            let headAtlas = SKTextureAtlas(named: "ghostHead.atlas")
            let headFrames:[SKTexture] = [
                headAtlas.textureNamed("ghost_head_frontopen_punch.png"),
                headAtlas.textureNamed("ghost_head_front.png")]
            
            self.headAnimation = SKAction.animate(with: headFrames, timePerFrame: 0.4)
            
            let headLeftPunchFrames:[SKTexture] = [
                headAtlas.textureNamed("ghost_head_leftpunch.png"),
                headAtlas.textureNamed("ghost_head_front.png")]
            
            self.headLeftPunchAnimation = SKAction.animate(with: headLeftPunchFrames, timePerFrame: 0.4)
            self.headLeftPunchAnimationSlow = SKAction.animate(with: headLeftPunchFrames, timePerFrame: 1.0)
            
            let headRightPunchFrames:[SKTexture] = [
                headAtlas.textureNamed("ghost_head_rightpunch.png"),
                headAtlas.textureNamed("ghost_head_front.png")]
            
            self.headRightPunchAnimation = SKAction.animate(with: headRightPunchFrames, timePerFrame: 0.4)
            self.headRightPunchAnimationSlow = SKAction.animate(with: headRightPunchFrames, timePerFrame: 1.0)
            
            
            let headFrontPunchFrames:[SKTexture] = [
                headAtlas.textureNamed("ghost_head_uppercut.png"),
                headAtlas.textureNamed("ghost_head_front.png")]
            
            self.headFrontPunchAnimation = SKAction.animate(with: headFrontPunchFrames, timePerFrame: 0.4)
            self.headFrontPunchAnimationSlow = SKAction.animate(with: headFrontPunchFrames, timePerFrame: 1.0)
            
            self.head =  self.opponent.childNode(withName: "body")?.childNode(withName: "head") as! SKSpriteNode?
            self.body =  self.opponent.childNode(withName: "body")
            
            
            let sparkEmmiter = SKEmitterNode(fileNamed: "Smoke.sks")!
            sparkEmmiter.position = CGPoint(x: 10, y: 200)
            sparkEmmiter.name = "sparkEmmitter"
            sparkEmmiter.particleZPosition = -1
            sparkEmmiter.targetNode = self.opponent!
            sparkEmmiter.alpha = 0.5
            sparkEmmiter.particlePositionRange = CGVector(dx: 40.0, dy: 40.0)
            self.opponent?.addChild(sparkEmmiter)
            
            let bodyGlow = SKEmitterNode(fileNamed: "Smoke.sks")!
            bodyGlow.position = CGPoint(x: 0, y: 10)
            bodyGlow.name = "sparkEmmitter"
            bodyGlow.particleZPosition = -1
            bodyGlow.targetNode = self.opponent!
            bodyGlow.alpha = 0.5
            bodyGlow.particlePositionRange = CGVector(dx: 240.0, dy: 290.0)
            self.opponent?.addChild(bodyGlow)
        }
    }
    
    func returnFullPowerHit()->CGFloat
    {
        return 3.0
    }
    
    func returnBlockedHit()->CGFloat
    {
        return 1.0
    }
    
    func defeated(){
        self.ghostDeath.position = self.opponent!.position
        self.opponent?.removeFromParent()
        self.addChild(self.ghostDeath)
        self.ghostDeath.run(self.ghostDeathCycle)
        
        let scaleMoveGroup:SKAction = SKAction.group([SKAction.scale(to: 0.0, duration: 2.0), SKAction.move(to: CGPoint(x:0, y:0), duration: 2.0)])
        
        self.ghostDeath.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            scaleMoveGroup, SKAction.run({self.delegate?.ghostIsGone()})
            ]))
    }
    
    func doLeftArmAttack(connected:Bool){
        self.leftArm?.run(self.leftArmAttack!, withKey: LEFT_ARM_KEY)
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.05)
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
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.05)
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
                                          SKAction.run({self.randomAttack()}),
                                          SKAction.fadeAlpha(to: 1.0, duration: 0.1)])
        
        let sequence2 = SKAction.sequence([SKAction.wait(forDuration: 0.25),
                                           SKAction.scale(to: 0.0, duration: 0.05),
                                          SKAction.wait(forDuration: 0.5),
                                          SKAction.scale(to: 1.0, duration: 0.05),
                                          SKAction.wait(forDuration: 0.25)])
        
        self.opponent?.run(SKAction.group([sequence, sequence2]))
        
        self.addEvent(event: .ghostGoInvisible)
    }
    
    func comboAttack1(){
        self.addEvent(event: .ghostComboAttack1)
        
        if self.opponent.action(forKey: MOVEMENT_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        if self.opponent.action(forKey: COMBO_ATTACK_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }

        
        
        let startPos = self.opponent.position
        
        self.delegate?.turnOffLights()
        self.opponent.position = startPosition
        
        
        let scaleUp = SKAction.scale(to: 2.0, duration: 0.2)
        let fadeUp = SKAction.fadeAlpha(to: 0.9, duration: 0.3)
        let moveIn = SKAction.moveBy(x: startPosition.x, y: startPosition.y - 100, duration: 0.2)
        let group1 = SKAction.group([SKAction.run({ self.head?.texture = SKTextureAtlas(named: "ghostHead.atlas").textureNamed("ghost_head_uppercut.png") }),scaleUp, fadeUp,moveIn])
        
        let attackLeft = SKAction.sequence([SKAction.run({ self.delegate?.opponentAttackLeft() }), SKAction.wait(forDuration: 0.3)])
        let attackRight = SKAction.sequence([SKAction.run({ self.delegate?.opponentAttackRight() }), SKAction.wait(forDuration: 0.3)])
        let lightsOn = SKAction.run({self.delegate?.turnOnLights()})
        let lightsOff = SKAction.run({self.delegate?.turnOffLights()})
        
        let attack = SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.run({ self.opponent.setScale(0.0) }), SKAction.wait(forDuration: 3.0), group1, SKAction.run({ self.opponent.position = startPos }), attackLeft, attackRight,attackLeft,attackRight,attackLeft,attackRight,attackLeft,attackRight,lightsOn,SKAction.scale(to: 1.0, duration: 0.2),SKAction.fadeIn(withDuration: 0.1)])
        
        let flashPause = SKAction.wait(forDuration: 0.3)
        
//        let flashingLights = SKAction.sequence([SKAction.wait(forDuration: 3.2),lightsOn,flashPause,lightsOff,flashPause,lightsOn,flashPause
//            ,lightsOff,flashPause,lightsOn,flashPause,lightsOff,flashPause,lightsOn,flashPause,lightsOff,flashPause,lightsOn])
        
        self.opponent.run(attack, withKey:COMBO_ATTACK_KEY)
        
//        self.run(flashingLights)
    }
    
    func hitRecoil(_ direction:Direction, power:CGFloat){
        print(power)
        let moveAmount = power * 2
        
        if self.opponent.action(forKey: MOVEMENT_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        if self.opponent.action(forKey: COMBO_ATTACK_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        
        let scaleDown:SKAction
        let headAnimation:SKAction
        
        if power > 8 {
            scaleDown = SKAction.scale(to: 0.85, duration: 0.3)
            if abs(self.opponent.position.x) > 30 {
                headAnimation = direction == .right ? self.headRightPunchAnimationSlow! : self.headLeftPunchAnimationSlow!
            } else {
                headAnimation = self.headFrontPunchAnimationSlow!
            }
            
        } else {
            scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
            if abs(self.opponent.position.x) > 30 {
                headAnimation = direction == .right ? self.headRightPunchAnimation! : self.headLeftPunchAnimation!
            } else {
                headAnimation = self.headFrontPunchAnimation!
            }
        }
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.2)
        
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        
        let fadeDown = SKAction.fadeAlpha(to: 0.6, duration: 0.2)
        let fadeUp = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let fadeSequence = SKAction.sequence([fadeDown, fadeUp])
        
        let headRotate1 = SKAction.rotate(byAngle: (direction == .right ? CGFloat(power).degreesToRadians : CGFloat(-power).degreesToRadians), duration: 0.1)
        let headRotate2 = SKAction.rotate(toAngle: CGFloat(0).degreesToRadians, duration: 0.1)
        let headSequence = SKAction.group([SKAction.sequence([headRotate1, headRotate2]),  headAnimation])
        
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
       
        
        let newPos:CGPoint = CGPoint(x: startPosition.x - 200, y: startPosition.y + CGFloat(arc4random_uniform(UInt32(30))) - CGFloat(arc4random_uniform(UInt32(30))))
        
        let movement:SKAction = SKAction.move(to: newPos, duration: 0.2)
        
        if self.opponent.action(forKey: MOVEMENT_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        
        self.opponent.run(SKAction.sequence([ SKAction.wait(forDuration: 0.3) ,movement]), withKey: MOVEMENT_KEY)
        
        self.goInvisible()
    }
    
    func dodgeRight(){
        
        
        let newPos:CGPoint = CGPoint(x: startPosition.x + 200, y: startPosition.y + CGFloat(arc4random_uniform(UInt32(30))) - CGFloat(arc4random_uniform(UInt32(30))))
        
        let movement:SKAction = SKAction.move(to: newPos, duration: 0.2)
        
        if self.opponent.action(forKey: MOVEMENT_KEY) != nil {
            self.opponent.removeAction(forKey: MOVEMENT_KEY)
        }
        
        self.opponent.run(SKAction.sequence([ SKAction.wait(forDuration: 0.3) ,movement]) , withKey: MOVEMENT_KEY)
        self.goInvisible()
    }
    
    func checkForAttackTime()->Bool{
        
        let attackDeficit:CGFloat
        
        
        if Int(arc4random_uniform(UInt32(4))) == 1 {
            attackDeficit = (100 - (BattleManager.playerHealth! - BattleManager.opponentHealth!))/30
        } else {
            attackDeficit = CGFloat(arc4random_uniform(UInt32(10))) + 10
        }
        
        print("attackDeficit = \(attackDeficit)")
        
        return !self.checkFor(events: [.ghostLeftAttackFail, .ghostRightAttackFail,.ghostLeftAttackConnect, .ghostRightAttackConnect,
                                       .ghostDodgeLeft, .ghostDodgeRight], withinLast: Int(attackDeficit))
        
    }
    
    func checkDodging()->Bool {
        
        if self.checkLast(10, eventsEqualAny: [.playerRightPunchConnect, .playerLeftPunchConnect, .playerLeftKickConnect, .playerRightKickConnect],
                          excluding: [.nothing, .playerRightPunchFail, .playerLeftPunchFail, .playerRightKickFail, .playerLeftKickFail, .ghostGoInvisible, .ghostLeftAttackFail, .ghostRightAttackFail]){
            
            self.addEvent(event: .ghostComboAttack1)
            
            return true
        }
        
        if self.checkLast(3, eventsEqual: .playerRightPunchConnect){
            self.addEvent(event: .ghostDodgeLeft)
            return true
        }
        
        if self.checkLast(3, eventsEqual: .playerRightKickConnect){
           self.addEvent(event: .ghostDodgeLeft)
            return true
        }
        
        if self.checkLast(3, eventsEqual: .playerLeftPunchConnect){
            self.addEvent(event: .ghostDodgeRight)
            return true
        }
        
        if self.checkLast(3, eventsEqual: .playerLeftKickConnect){
            self.addEvent(event: .ghostDodgeRight)
            return true
        }
        
        if self.checkLast(3, eventsEqualAny: [.playerRightPunchConnect, .playerLeftPunchConnect, .playerLeftKickConnect, .playerRightKickConnect],
                          excluding: [.nothing, .playerRightPunchFail, .playerLeftPunchFail, .playerRightKickFail, .playerLeftKickFail]){
            
            if self.checkMoreRecent(events: [.playerLeftPunchConnect, .playerRightPunchConnect]) == .playerLeftPunchConnect {
                self.addEvent(event: .ghostDodgeRight)
            } else {
                self.addEvent(event: .ghostDodgeLeft)
            }
            
            return true
        }
        
        if self.checkLast(1, eventsEqual: .ghostDodgeRight){
            self.dodgeRight()
            return true
        }
        
        if self.checkLast(1, eventsEqual: .ghostDodgeLeft){
            self.dodgeLeft()
            return true
        }
        
        if self.checkLast(1, eventsEqual: .ghostComboAttack1){
            self.comboAttack1()
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
    
    func spark(_ direction:Direction, _ power:CGFloat){
        
        let sparkEmmiter = SKEmitterNode(fileNamed: "ectoPlasm.sks")!
        sparkEmmiter.position = CGPoint(x: (direction == .right ? -30 : 30), y: 25)
        sparkEmmiter.name = "sparkEmmitter"
        sparkEmmiter.zPosition = 200
        sparkEmmiter.targetNode = self
        sparkEmmiter.particleLifetime = 3
        sparkEmmiter.emissionAngle = (CGFloat(direction == .right ? 180.0.radiansToDegrees : 0.0.radiansToDegrees))
        sparkEmmiter.xAcceleration = (direction == .right ? -900 : 900)
        sparkEmmiter.numParticlesToEmit = Int(power.multiplied(by: 10))
        
        
        self.head?.addChild(sparkEmmiter)
    }
    func randomAttack(){
        
        if Int(arc4random_uniform(UInt32(2))) == 1 {
            delegate?.opponentAttackLeft()
        } else {
            delegate?.opponentAttackRight()
        }
        
    }
    func update(_ currentTime: TimeInterval){
        
       currentSceneTime = currentTime
        
        if self.opponent.action(forKey: COMBO_ATTACK_KEY) != nil {
            return
        }
        
        if self.checkDodging() {
            return
        }
        
        if self.opponent.action(forKey: MOVEMENT_KEY) == nil {
            let newPos:CGPoint = CGPoint(x: startPosition.x + CGFloat(arc4random_uniform(UInt32(100))) - CGFloat(arc4random_uniform(UInt32(100))), y: startPosition.y + CGFloat(arc4random_uniform(UInt32(20))) - CGFloat(arc4random_uniform(UInt32(20))))
            
            let movement:SKAction = SKAction.move(to: newPos, duration: 4)
            self.opponent.run(movement, withKey: MOVEMENT_KEY)
        }
        
        if self.opponent.alpha < 1.0 {
            return
        }
        
        if self.checkForAttackTime()
        {
            let amount = max(arc4random_uniform(UInt32(2)), 1)
            
            for _ in 0...amount {
                self.randomAttack()
            }
            return
        }
        
        if !self.checkFor(events: [.ghostComboAttack1], withinLast: 40){
            self.addEvent(event: .ghostComboAttack1)
            return
        }
        

        
        if currentSceneTime - lastActivityCheck > INACTIVITY_TIME_TO_CHECK {
            self.addEvent(event: .nothing)
        }
    }
    
    func showDamage(direction:Direction){
        
        let node:SKSpriteNode
        let xPositionAdjust:CGFloat
        if direction == .right {
            node = SKSpriteNode(imageNamed: "ghost_slash_right")
            xPositionAdjust = (self.body?.frame.size.width)!/2
        } else {
            node = SKSpriteNode(imageNamed: "ghost_slash_left")
            xPositionAdjust = -(self.body?.frame.size.width)!/2
        }
        node.position = CGPoint(x: self.opponent.position.x + xPositionAdjust, y: 0)
        node.zPosition = 20
        self.addChild(node)
        node.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.removeFromParent()]))
    }
    
    func willRightPunchConnect(_ power:CGFloat) ->Bool {
        let willConnect = self.opponent?.alpha == 1 && self.opponent.position.x > -45 && self.opponent.position.x < 150 && self.opponent.action(forKey: COMBO_ATTACK_KEY) == nil
        if willConnect {
            self.addEvent(event: .playerRightPunchConnect)
            self.spark(.right, power)
            
        } else {
            self.addEvent(event: .playerRightPunchFail)
        }
        return willConnect
    }
    func willLeftPunchConnect(_ power:CGFloat) ->Bool {
        let willConnect = self.opponent?.alpha == 1 && self.opponent.position.x < 25 && self.opponent.position.x > -150 && self.opponent.action(forKey: COMBO_ATTACK_KEY) == nil
        if willConnect {
            self.spark(.left, power)
            self.addEvent(event: .playerLeftPunchConnect)
            
        } else {
            self.addEvent(event: .playerLeftPunchFail)
        }
        return willConnect
    }
    func willComboBreakerConnect() -> (Bool, Direction) {
        
        if self.opponent.action(forKey: COMBO_ATTACK_KEY) == nil {
            return (false, .right)
        }
        self.opponent.removeAllActions()
        self.delegate?.turnOnLights()
        self.opponent?.setScale(1.0)
        self.opponent?.alpha = 1.0
//        self.spark(self.opponent.position.x < 0 ? .left : .right, 10)
        return (true, self.opponent.position.x < 0 ? .left : .right)
    }
}
