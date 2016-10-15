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
    func kickRight()
    func kickLeft()
    func blockStart()
    func checkBlockEnd()->Bool
}

class Controls:SKNode
{
    let roomFrame:CGRect
    
    let leftPunch:SKSpriteNode
    let leftKick:SKSpriteNode
    let rightPunch:SKSpriteNode
    let rightKick:SKSpriteNode
    
    let energyBarHolderPlayer:SKSpriteNode
    let energyBarHolderOpponent:SKSpriteNode
    
    let energyBarPlayer:SKShapeNode
    let energyBarOpponent:SKShapeNode
    
    var leftButtonPowerMeter:SKShapeNode
    var rightButtonPowerMeter:SKShapeNode
    
    var leftButtonGainingPower = false
    var rightButtonGainingPower = false
    var leftButtonPower:CGFloat = 1.0
    var rightButtonPower:CGFloat = 1.0
    
    weak var delegate:ControlsDelegate?
    
    enum Button:UInt32 {
        case punchLeft = 1
        case punchRight = 2
        case kickLeft = 4
        case kickRight = 8
    }
    
    
    init(frame: CGRect) {
        self.roomFrame = frame
        
        self.leftPunch  = SKSpriteNode(imageNamed: "punch_reg")
        self.rightPunch   = SKSpriteNode(imageNamed: "punch_reg")
        self.leftKick = SKSpriteNode(imageNamed: "kick_reg")
        self.rightKick  = SKSpriteNode(imageNamed: "kick_reg")
        
        self.energyBarHolderPlayer = SKSpriteNode(imageNamed: "control_bar")
        self.energyBarHolderOpponent = SKSpriteNode(imageNamed: "control_bar")
        
        self.energyBarHolderPlayer.position = CGPoint(x: self.roomFrame.size.width * 0.15, y: self.roomFrame.size.height * 0.95)
        self.energyBarHolderPlayer.setScale(0.5)
        self.energyBarHolderOpponent.position = CGPoint(x: self.roomFrame.size.width * 0.85, y: self.roomFrame.size.height * 0.95)
        self.energyBarHolderOpponent.setScale(0.5)
        
        energyBarPlayer = SKShapeNode()
        energyBarPlayer.fillColor = UIColor.orange
        
        energyBarOpponent = SKShapeNode()
        energyBarOpponent.fillColor = UIColor.green
        
        let leftPunchRoll = SKSpriteNode(imageNamed: "punch_roll")
        leftPunchRoll.position = CGPoint(x: self.roomFrame.size.width * 0.1, y: self.roomFrame.size.height * 0.15)
        self.leftPunch.position = leftPunchRoll.position
        
        
        leftButtonPowerMeter = SKShapeNode()
        
        rightButtonPowerMeter = SKShapeNode()
        
        super.init()
        
//        leftButtonPower = SKShapeNode(path: self.circlePathWith(angle: 0, forButton: self.leftPunch), centered: false)
        leftButtonPowerMeter.fillColor = SKColor.clear
        leftButtonPowerMeter.strokeColor = SKColor.red
        leftButtonPowerMeter.lineWidth = 4
        leftButtonPowerMeter.glowWidth = 5
        self.addChild(leftButtonPowerMeter)
        
        rightButtonPowerMeter.fillColor = SKColor.clear
        rightButtonPowerMeter.strokeColor = SKColor.red
        rightButtonPowerMeter.lineWidth = 4
        rightButtonPowerMeter.glowWidth = 5
        self.addChild(rightButtonPowerMeter)
        
        self.addChild(leftPunchRoll)
        
        self.addChild(self.leftPunch)
        
        
        
        let rightPunchRoll = SKSpriteNode(imageNamed: "punch_roll")
        rightPunchRoll.position = CGPoint(x: self.roomFrame.size.width * 0.9, y: self.roomFrame.size.height * 0.15)
        self.addChild(rightPunchRoll)
        
        self.rightPunch.position = CGPoint(x: self.roomFrame.size.width * 0.9, y: self.roomFrame.size.height * 0.15)
        self.addChild(self.rightPunch)
        
//        rightButtonPower = SKShapeNode(path: self.circlePathWith(angle: 0, forButton: self.rightPunch), centered: false)
        
        
        let leftKickRoll = SKSpriteNode(imageNamed: "kick_roll")
        leftKickRoll.position = CGPoint(x: self.roomFrame.size.width * 0.2, y: self.roomFrame.size.height * 0.15)
//        self.addChild(leftKickRoll)
        
        self.leftKick.position = CGPoint(x: self.roomFrame.size.width * 0.2, y: self.roomFrame.size.height * 0.15)
//        self.addChild(self.leftKick)
        
        let rightKickRoll = SKSpriteNode(imageNamed: "kick_roll")
        rightKickRoll.position = CGPoint(x: self.roomFrame.size.width * 0.8, y: self.roomFrame.size.height * 0.15)
//        self.addChild(rightKickRoll)
        
        self.rightKick.position = CGPoint(x: self.roomFrame.size.width * 0.8, y: self.roomFrame.size.height * 0.15)
//        self.addChild(self.rightKick)
        
        
        
        self.addChild(self.energyBarHolderPlayer)
        self.addChild(self.energyBarHolderOpponent)
        
        self.addChild(self.energyBarPlayer)
        self.addChild(self.energyBarOpponent)
        
        self.setPlayerHealth(percent:1.00)
        self.setOpponentHealth(percent:1.00)
    }
    
    func circlePathWith(angle:CGFloat, forButton sprite:SKSpriteNode)->CGPath{
        return UIBezierPath(arcCenter:
            CGPoint(x:sprite.position.x,y:sprite.position.y + 10) , radius: (sprite.frame.size.width + 10)/2, startAngle: 0.0, endAngle: CGFloat(angle).degreesToRadians, clockwise: true).cgPath
    }
    
    func setPlayerHealth(percent:CGFloat){
        let energyBarFrame = self.energyBarHolderPlayer.frame
        let barRect = CGRect(x: energyBarFrame.origin.x + 10,
                             y: energyBarFrame.origin.y + energyBarFrame.height/3,
                             width: (energyBarFrame.size.width - 20) * percent, height: energyBarFrame.size.height/3)
        energyBarPlayer.path = UIBezierPath(rect: barRect).cgPath
    }
    func setOpponentHealth(percent:CGFloat){
        let energyBarFrame = self.energyBarHolderOpponent.frame
        let barRect = CGRect(x: energyBarFrame.origin.x + 10,
                             y: energyBarFrame.origin.y + energyBarFrame.height/3,
                             width: (energyBarFrame.size.width - 20) * percent, height: energyBarFrame.size.height/3)
        energyBarOpponent.path = UIBezierPath(rect: barRect).cgPath
    }
    func checkButtonHit(_ touches:Set<UITouch> ){
        
        var hitBitMask:UInt32 = 0
        
        for touch in touches {
        
            let location = touch.location(in: self)
            
            if self.leftPunch.contains(location) {
                hitBitMask |= Button.punchLeft.rawValue
                
                self.leftPunch.userData = ["touch":touch]
                self.leftPunch.isHidden = true
                
            } else if self.leftPunch.isHidden {
                hitBitMask |= Button.punchLeft.rawValue
            }
            if self.leftKick.contains(location) {
                hitBitMask |= Button.kickLeft.rawValue
                self.leftKick.userData = ["touch":touch]
                self.leftKick.isHidden = true
                
            }
            if self.rightPunch.contains(location) {
                hitBitMask |= Button.punchRight.rawValue
                self.rightPunch.userData = ["touch":touch]
                self.rightPunch.isHidden = true
                
            }  else if self.rightPunch.isHidden {
                hitBitMask |= Button.punchRight.rawValue
            }
            if self.rightKick.contains(location) {
                hitBitMask |= Button.kickRight.rawValue
                self.rightKick.userData = ["touch":touch]
                self.rightKick.isHidden = true
                
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
            rightButtonGainingPower = true
            rightButtonPower = 1
        case Button.punchLeft.rawValue:
            leftButtonGainingPower = true
            leftButtonPower = 1
        case Button.kickRight.rawValue:
            delegate?.kickRight()
        case Button.kickLeft.rawValue:
            delegate?.kickLeft()
        default:
            break
        }
        
    }
    
    func touchEnded(location:CGPoint, touch:UITouch){
        
        if let data = self.leftPunch.userData {
            if (data["touch"] as! UITouch) === touch {
                self.leftPunch.isHidden = false
                self.leftPunch.userData = nil
                if !(delegate?.checkBlockEnd())! {
                    delegate?.punchLeft(power: leftButtonPower)
                    leftButtonPowerMeter.path = nil
                    leftButtonGainingPower = false

                }
            }
        }
        if let data = self.leftKick.userData {
            if (data["touch"] as! UITouch) === touch {
                self.leftKick.isHidden = false
                self.leftKick.userData = nil
//                delegate?.checkBlockEnd()
            }
        }
        if let data = self.rightPunch.userData {
            if (data["touch"] as! UITouch) === touch {
                self.rightPunch.isHidden = false
                self.rightPunch.userData = nil
                if !(delegate?.checkBlockEnd())! {
                    delegate?.punchRight(power: rightButtonPower)
                    rightButtonPowerMeter.path = nil
                    rightButtonGainingPower = false
                }
            }
        }
        if let data = self.rightKick.userData {
            if (data["touch"] as! UITouch) === touch {
                self.rightKick.isHidden = false
                self.rightKick.userData = nil
            }
        }
    }
    func update(_ currentTime: TimeInterval){
        if rightButtonGainingPower {
            rightButtonPower += 0.1
            let degrees = (rightButtonPower/10.0) * 360
            rightButtonPowerMeter.path = self.circlePathWith(angle: CGFloat(degrees), forButton: self.rightPunch)
            if rightButtonPower >= 10 {
                rightButtonGainingPower = false
                delegate?.punchRight(power:rightButtonPower)
                self.rightPunch.isHidden = false
                self.rightPunch.userData = nil
                rightButtonPowerMeter.path = nil
            }
        }
        
        if leftButtonGainingPower {
            leftButtonPower += 0.1
            let degrees = (leftButtonPower/10.0) * 360
            leftButtonPowerMeter.path = self.circlePathWith(angle: CGFloat(degrees), forButton: self.leftPunch)
            if leftButtonPower >= 10 {
                leftButtonGainingPower = false
                delegate?.punchLeft(power:leftButtonPower)
                self.leftPunch.isHidden = false
                self.leftPunch.userData = nil
                leftButtonPowerMeter.path = nil
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
