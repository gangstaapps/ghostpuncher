//
//  Controls.swift
//  ghostpuncher
//
//  Created by Erik James on 10/9/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

protocol ControlsDelegate:class {
    func punchRight(power:CGFloat)
    func punchLeft(power:CGFloat)
    func blockStart()
    func checkBlockEndLeft()->Bool
    func checkBlockEndRight()->Bool
    func comboRight()
    func comboLeft()
    func jukeRight()
    func jukeLeft()
}

class Controls:SKNode
{
    let roomFrame:CGRect
    
    
    
    let leftPunch:SKSpriteNode
    let rightPunch:SKSpriteNode
    
    let energyBarHolderPlayer:SKSpriteNode
    let energyBarHolderOpponent:SKSpriteNode
    
    let energyBarPlayer:SKSpriteNode
    let energyBarOpponent:SKSpriteNode
    
    var leftButtonPowerMeter:SKShapeNode
    var rightButtonPowerMeter:SKShapeNode
    
    var leftButtonPowerSmoke:SKEmitterNode
    var rightButtonPowerSmoke:SKEmitterNode
    
    var leftButtonGainingPower = false
    var rightButtonGainingPower = false
    var leftButtonPower:CGFloat = 1.0
    var rightButtonPower:CGFloat = 1.0
    
    weak var delegate:ControlsDelegate?
    
    static let LENGTH_OF_MEMORY = 100
    let INACTIVITY_TIME_TO_CHECK = 0.2
    
    var lastActivityCheck = 0.0
    var currentSceneTime = 0.0
    
    var buttonHistory:[Button] = Array(repeating: .nothing, count: LENGTH_OF_MEMORY)
    
    enum Button:UInt32 {
        case punchLeft = 1
        case punchRight = 2
        case nothing = 4
        case combo = 8
        case jukeLeft = 16
        case jukeRight = 32
    }
    
    func addEvent(event:Button){
        let count = Controls.LENGTH_OF_MEMORY - 1
        var prev:Button = event
        var current:Button = event
        for index in stride(from: count, to: 0, by: -1) {
            current = buttonHistory[index]
            buttonHistory[index] = prev
            prev = current
        }
        lastActivityCheck = currentSceneTime
        
//        self.checkForCombo()
    }
    
    
    
    
    init(frame: CGRect, opponent:String) {
        self.roomFrame = frame
        
        self.leftPunch  = SKSpriteNode(imageNamed: "punch_reg")
        self.rightPunch   = SKSpriteNode(imageNamed: "punch_reg")
       
        self.energyBarHolderPlayer = SKSpriteNode(imageNamed: "left_health")
        self.energyBarHolderOpponent = SKSpriteNode(imageNamed: "right_health")
        
        self.energyBarHolderPlayer.position = CGPoint(x: self.roomFrame.size.width * 0.15, y: self.roomFrame.size.height * 0.95)
        self.energyBarHolderPlayer.setScale(0.5)
        self.energyBarHolderOpponent.position = CGPoint(x: self.roomFrame.size.width * 0.85, y: self.roomFrame.size.height * 0.95)
        self.energyBarHolderOpponent.setScale(0.5)
        
        let opponentIcon:SKSpriteNode = SKSpriteNode(texture: SKTextureAtlas(named: "\(opponent)Head.atlas").textureNamed("\(opponent)_head_frontopen_punch.png"))
        
        opponentIcon.setScale(0.2)
        
        
        
        energyBarPlayer = SKSpriteNode(imageNamed: "green_meter")
        energyBarPlayer.anchorPoint = CGPoint(x: 0, y: 0.5)
//        energyBarPlayer.fillColor = UIColor.orange
        
        energyBarOpponent = SKSpriteNode(imageNamed: "orange_meter")
        energyBarOpponent.anchorPoint = CGPoint(x: 0, y: 0.5)
//        energyBarOpponent.fillColor = UIColor.green
        
        
        
        
        let leftPunchRoll = SKSpriteNode(imageNamed: "punch_rol")
        leftPunchRoll.position = CGPoint(x: self.roomFrame.size.width * 0.1, y: self.roomFrame.size.height * 0.15)
        self.leftPunch.position = leftPunchRoll.position
        
        leftButtonPowerMeter = SKShapeNode()
        
        rightButtonPowerMeter = SKShapeNode()
        
        leftButtonPowerSmoke = SKEmitterNode(fileNamed: "ButtonPowerMeter.sks")!
//        leftButtonPowerSmoke.position = leftPunch.position
        leftButtonPowerSmoke.name = "sparkEmmitterLeft"
        leftButtonPowerSmoke.particleZPosition = -2
        leftButtonPowerSmoke.targetNode = leftPunchRoll
        leftButtonPowerSmoke.alpha = 0.25
        leftButtonPowerSmoke.particleAlpha = 0.5
        leftButtonPowerSmoke.particleSpeed = 0
//        leftButtonPowerSmoke.particlePositionRange = CGVector(dx: leftPunchRoll.frame.size.width * 0.7, dy: 20.0)
        
        leftPunchRoll.addChild(leftButtonPowerSmoke)
        
        let rightPunchRoll = SKSpriteNode(imageNamed: "punch_rol")
        rightPunchRoll.position = CGPoint(x: self.roomFrame.size.width * 0.9, y: self.roomFrame.size.height * 0.15)
        
        
        rightButtonPowerSmoke = SKEmitterNode(fileNamed: "ButtonPowerMeter.sks")!
//        rightButtonPowerSmoke.position = rightPunch.position
        rightButtonPowerSmoke.name = "sparkEmmitterRight"
        rightButtonPowerSmoke.particleZPosition = -2
        rightButtonPowerSmoke.targetNode = rightPunchRoll
        rightButtonPowerSmoke.alpha = 0.25
        rightButtonPowerSmoke.particleAlpha = 0.5
        rightButtonPowerSmoke.particleSpeed = 0
//        rightButtonPowerSmoke.particlePositionRange = CGVector(dx: rightPunchRoll.frame.size.width * 0.7, dy: 20.0)
        
        rightPunchRoll.addChild(rightButtonPowerSmoke)
        
        
        super.init()
        
        
        
        leftButtonPowerMeter.fillColor = SKColor.clear
        leftButtonPowerMeter.strokeColor = SKColor.init(hex: 0xff9b14)
        leftButtonPowerMeter.lineWidth = 4
        leftButtonPowerMeter.glowWidth = 5
        self.addChild(leftButtonPowerMeter)
        
        rightButtonPowerMeter.fillColor = SKColor.clear
        rightButtonPowerMeter.strokeColor = SKColor.init(hex: 0xff9b14)
        rightButtonPowerMeter.lineWidth = 4
        rightButtonPowerMeter.glowWidth = 5
        self.addChild(rightButtonPowerMeter)
        
        opponentIcon.position = CGPoint(x: self.energyBarHolderOpponent.frame.origin.x - 16, y: self.roomFrame.size.height * 0.95)
        
        self.addChild(opponentIcon)
        
        self.addChild(leftPunchRoll)
        
        self.addChild(self.leftPunch)
        
        
        self.addChild(rightPunchRoll)
        
        self.rightPunch.position = CGPoint(x: self.roomFrame.size.width * 0.9, y: self.roomFrame.size.height * 0.15)
        self.addChild(self.rightPunch)
        
        self.addChild(self.energyBarHolderPlayer)
        self.addChild(self.energyBarHolderOpponent)
        
        self.addChild(self.energyBarPlayer)
        self.addChild(self.energyBarOpponent)
        
        self.setPlayerHealth(percent:1.00)
        self.setOpponentHealth(percent:1.00)
    }
    
    
    
    func circlePathWith(angle:CGFloat, forButton sprite:SKSpriteNode)->CGPath{
        return UIBezierPath(arcCenter:
            CGPoint(x:sprite.position.x,y:sprite.position.y ) , radius: (sprite.frame.size.width + 10)/2, startAngle: 0.0, endAngle: CGFloat(angle).degreesToRadians, clockwise: true).cgPath
    }
    
    func setPlayerHealth(percent:CGFloat){
        let energyBarFrame = self.energyBarHolderPlayer.frame
        let barRect = CGRect(x: energyBarFrame.origin.x,
                             y: energyBarFrame.origin.y + energyBarFrame.height/3,
                             width: (energyBarFrame.size.width - 12) * percent, height: energyBarFrame.size.height/2)
//        energyBarPlayer.path = UIBezierPath(rect: barRect).cgPath
        energyBarPlayer.size = barRect.size
         energyBarPlayer.position = barRect.origin
        
        energyBarPlayer.run(SKAction.sequence([SKAction.moveBy(x: -15, y: 0, duration: 0.2),SKAction.moveBy(x: 15, y: 0, duration: 0.1)]))
        energyBarHolderPlayer.run(SKAction.sequence([SKAction.moveBy(x: -15, y: 0, duration: 0.2),SKAction.moveBy(x: 15, y: 0, duration: 0.1)]))
    }
    func setOpponentHealth(percent:CGFloat){
        let energyBarFrame = self.energyBarHolderOpponent.frame
        let barRect = CGRect(x: energyBarFrame.origin.x + 12,
                             y: energyBarFrame.origin.y + energyBarFrame.height/3,
                             width: (energyBarFrame.size.width - 12) * percent, height: energyBarFrame.size.height/2)
//        energyBarOpponent.path = UIBezierPath(rect: barRect).cgPath
        energyBarOpponent.size = barRect.size
        energyBarOpponent.position = barRect.origin
        
        energyBarOpponent.run(SKAction.sequence([SKAction.moveBy(x: 15, y: 0, duration: 0.2),SKAction.moveBy(x: -15, y: 0, duration: 0.1)]))
        energyBarHolderOpponent.run(SKAction.sequence([SKAction.moveBy(x: 15, y: 0, duration: 0.2),SKAction.moveBy(x: -15, y: 0, duration: 0.1)]))
    }
    func checkButtonHit(_ touches:Set<UITouch> ){
        
        var hitBitMask:UInt32 = 0
        
        for touch in touches {
        
            let location = touch.location(in: self)
            
            if self.leftPunch.contains(location) {
                hitBitMask |= Button.punchLeft.rawValue
                self.leftPunch.userData = ["touch":touch]
                
//                self.addEvent(event: .punchLeft)
            } else if self.leftPunch.isHidden {
                hitBitMask |= Button.punchLeft.rawValue
            }
            
            if self.rightPunch.contains(location) {
                hitBitMask |= Button.punchRight.rawValue
                self.rightPunch.userData = ["touch":touch]
//                self.rightPunch.isHidden = true
//                self.addEvent(event: .punchRight)
                
            }  else if self.rightPunch.isHidden {
                hitBitMask |= Button.punchRight.rawValue
            }
            
        }
        
        switch hitBitMask {
        case Button.punchRight.rawValue | Button.punchLeft.rawValue:
            delegate?.blockStart()
            rightButtonGainingPower = false
            leftButtonGainingPower = false
            rightButtonPowerMeter.path = nil
            leftButtonPowerMeter.path = nil
         case Button.punchRight.rawValue:
            if self.checkForCombo(event: .punchRight){
                self.rightPunch.userData = nil
                return
            }
            self.rightPunch.isHidden = true
            rightButtonGainingPower = true
            rightButtonPower = 1
        case Button.punchLeft.rawValue:
            if self.checkForCombo(event: .punchLeft){
                self.leftPunch.userData = nil
                return
            }
            self.leftPunch.isHidden = true
            leftButtonGainingPower = true
            leftButtonPower = 1
        default:
            break
        }
        
    }
    
    func touchEnded(location:CGPoint, touch:UITouch){
        
        if let data = self.leftPunch.userData {
            if (data["touch"] as! UITouch) === touch {
                self.leftPunch.isHidden = false
                self.leftPunch.userData = nil
                if !(delegate?.checkBlockEndLeft())! {
                    delegate?.punchLeft(power: leftButtonPower)
                    leftButtonPowerMeter.path = nil
                    leftButtonGainingPower = false
                    leftButtonPowerSmoke.particleSpeed = 0
                }
            }
        }
       
        if let data = self.rightPunch.userData {
            if (data["touch"] as! UITouch) === touch {
                self.rightPunch.isHidden = false
                self.rightPunch.userData = nil
                if !(delegate?.checkBlockEndRight())! {
                    delegate?.punchRight(power: rightButtonPower)
                    rightButtonPowerMeter.path = nil
                    rightButtonGainingPower = false
                    rightButtonPowerSmoke.particleSpeed = 0
                }
            }
        }
        
    }
    func update(_ currentTime: TimeInterval){
        currentSceneTime = currentTime
        
        if rightButtonGainingPower {
            rightButtonPower += 0.1
            let degrees = (rightButtonPower/10.0) * 360
            rightButtonPowerMeter.path = self.circlePathWith(angle: CGFloat(degrees), forButton: self.rightPunch)
            rightButtonPowerSmoke.particleSpeed = rightButtonPower * 20
            if rightButtonPower >= 10 {
                rightButtonGainingPower = false
                delegate?.punchRight(power:rightButtonPower)
                self.rightPunch.isHidden = false
                self.rightPunch.userData = nil
                rightButtonPowerMeter.path = nil
                rightButtonPowerSmoke.particleSpeed = 0
            }
        }
        
        if leftButtonGainingPower {
            leftButtonPower += 0.1
            let degrees = (leftButtonPower/10.0) * 360
            leftButtonPowerMeter.path = self.circlePathWith(angle: CGFloat(degrees), forButton: self.leftPunch)
           leftButtonPowerSmoke.particleSpeed = leftButtonPower * 20
            if leftButtonPower >= 10 {
                leftButtonGainingPower = false
                delegate?.punchLeft(power:leftButtonPower)
                self.leftPunch.isHidden = false
                self.leftPunch.userData = nil
                leftButtonPowerMeter.path = nil
                leftButtonPowerSmoke.particleSpeed = 0
            }
        }
        if currentSceneTime - lastActivityCheck > INACTIVITY_TIME_TO_CHECK {
            self.addEvent(event: .nothing)
        }
    }
    
    func checkForCombo(event:Button) -> Bool{
        self.addEvent(event: event)
        
        if self.checkFor(combo: [.punchLeft, .punchLeft, .punchRight, .punchLeft]) && !self.checkFor(events: [.combo], withinLast: 10)  {
            self.addEvent(event: .combo)
            self.delegate?.comboLeft()
            
            leftButtonPowerMeter.removeAllActions()
            
            leftButtonPowerMeter.strokeColor = SKColor.green
            leftButtonPowerMeter.lineWidth = 14
            leftButtonPowerMeter.glowWidth = 15
            leftButtonPowerMeter.path = self.circlePathWith(angle: CGFloat(360), forButton: self.leftPunch)
            
            leftButtonPowerMeter.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run({
                    self.leftButtonPowerMeter.path = nil
                    self.leftButtonPowerMeter.strokeColor = SKColor.red
                    self.leftButtonPowerMeter.lineWidth = 4
                    self.leftButtonPowerMeter.glowWidth = 5
                })
                ]))
            
            return true
        }
        
        if self.checkFor(combo: [.punchRight, .punchRight, .punchLeft, .punchRight]) && !self.checkFor(events: [.combo], withinLast: 10) {
            self.addEvent(event: .combo)
            self.delegate?.comboRight()
            
            rightButtonPowerMeter.removeAllActions()
            
            rightButtonPowerMeter.strokeColor = SKColor.green
            rightButtonPowerMeter.lineWidth = 14
            rightButtonPowerMeter.glowWidth = 15
            rightButtonPowerMeter.path = self.circlePathWith(angle: CGFloat(360), forButton: self.rightPunch)
            
            rightButtonPowerMeter.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run({
                    self.rightButtonPowerMeter.path = nil
                    self.rightButtonPowerMeter.strokeColor = SKColor.red
                    self.rightButtonPowerMeter.lineWidth = 4
                    self.rightButtonPowerMeter.glowWidth = 5
                })
            ]))
            
            return true
        }
        
//        if self.checkFor(combo: [.punchLeft, .punchLeft, .punchLeft]) && !self.checkFor(events: [.jukeLeft], withinLast: 5)  {
//            self.addEvent(event: .jukeLeft)
//            self.delegate?.jukeLeft()
//            
//            leftButtonPowerMeter.removeAllActions()
//            
//            leftButtonPowerMeter.strokeColor = SKColor.green
//            leftButtonPowerMeter.lineWidth = 14
//            leftButtonPowerMeter.glowWidth = 15
//            leftButtonPowerMeter.path = self.circlePathWith(angle: CGFloat(360), forButton: self.leftPunch)
//            
//            leftButtonPowerMeter.run(SKAction.sequence([
//                SKAction.wait(forDuration: 0.5),
//                SKAction.run({
//                    self.leftButtonPowerMeter.path = nil
//                    self.leftButtonPowerMeter.strokeColor = SKColor.red
//                    self.leftButtonPowerMeter.lineWidth = 4
//                    self.leftButtonPowerMeter.glowWidth = 5
//                })
//                ]))
//            
//            return true
//        }
//        
//        if self.checkFor(combo: [.punchRight, .punchRight, .punchRight]) && !self.checkFor(events: [.jukeRight], withinLast: 5)  {
//            self.addEvent(event: .jukeRight)
//            self.delegate?.jukeRight()
//            
//            leftButtonPowerMeter.removeAllActions()
//            
//            leftButtonPowerMeter.strokeColor = SKColor.green
//            leftButtonPowerMeter.lineWidth = 14
//            leftButtonPowerMeter.glowWidth = 15
//            leftButtonPowerMeter.path = self.circlePathWith(angle: CGFloat(360), forButton: self.leftPunch)
//            
//            leftButtonPowerMeter.run(SKAction.sequence([
//                SKAction.wait(forDuration: 0.5),
//                SKAction.run({
//                    self.leftButtonPowerMeter.path = nil
//                    self.leftButtonPowerMeter.strokeColor = SKColor.red
//                    self.leftButtonPowerMeter.lineWidth = 4
//                    self.leftButtonPowerMeter.glowWidth = 5
//                })
//                ]))
//            
//            return true
//        }
        
        return false
    }
    
    func checkFor(combo:[Button] )->Bool{
        
        let count = Controls.LENGTH_OF_MEMORY - 1
        for index in stride(from: count, to: count - (combo.count - 1), by: -1) {
            if buttonHistory[index] != combo[index - (count - (combo.count - 1))] {
                return false
            }
        }
        
        return true
    }
    
    func checkFor(events:[Button], withinLast amount:Int)->Bool {
        let count = Opponent.LENGTH_OF_MEMORY - 1
        let lower = count - amount
        
        for index in stride(from: count, to: lower, by: -1) {
            
            if events.contains(buttonHistory[index]){
                return true
            }
        }
        
        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
