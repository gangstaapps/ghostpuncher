//
//  Controls.swift
//  ghostpuncher
//
//  Created by Erik James on 10/9/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

protocol ControlsDelegate:class {
    func punchRight()
    func punchLeft()
    func kickRight()
    func kickLeft()
    func blockStart()
    func checkBlockEnd()
}

class Controls:SKNode
{
    let roomFrame:CGRect
    
    let leftPunch:SKSpriteNode
    let leftKick:SKSpriteNode
    let rightPunch:SKSpriteNode
    let rightKick:SKSpriteNode
    
    let energyBarPlayer:SKSpriteNode
    let energyBarOpponent:SKSpriteNode
    
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
        
        self.energyBarPlayer = SKSpriteNode(imageNamed: "control_bar")
        self.energyBarOpponent = SKSpriteNode(imageNamed: "control_bar")
        
        super.init()
        
        let leftPunchRoll = SKSpriteNode(imageNamed: "punch_roll")
        leftPunchRoll.position = CGPoint(x: self.roomFrame.size.width * 0.1, y: self.roomFrame.size.height * 0.45)
        self.addChild(leftPunchRoll)
        
        self.leftPunch.position = CGPoint(x: self.roomFrame.size.width * 0.1, y: self.roomFrame.size.height * 0.45)
        self.addChild(self.leftPunch)
        
        let rightPunchRoll = SKSpriteNode(imageNamed: "punch_roll")
        rightPunchRoll.position = CGPoint(x: self.roomFrame.size.width * 0.9, y: self.roomFrame.size.height * 0.45)
        self.addChild(rightPunchRoll)
        
        self.rightPunch.position = CGPoint(x: self.roomFrame.size.width * 0.9, y: self.roomFrame.size.height * 0.45)
        self.addChild(self.rightPunch)
        
        let leftKickRoll = SKSpriteNode(imageNamed: "kick_roll")
        leftKickRoll.position = CGPoint(x: self.roomFrame.size.width * 0.2, y: self.roomFrame.size.height * 0.15)
        self.addChild(leftKickRoll)
        
        self.leftKick.position = CGPoint(x: self.roomFrame.size.width * 0.2, y: self.roomFrame.size.height * 0.15)
        self.addChild(self.leftKick)
        
        let rightKickRoll = SKSpriteNode(imageNamed: "kick_roll")
        rightKickRoll.position = CGPoint(x: self.roomFrame.size.width * 0.8, y: self.roomFrame.size.height * 0.15)
        self.addChild(rightKickRoll)
        
        self.rightKick.position = CGPoint(x: self.roomFrame.size.width * 0.8, y: self.roomFrame.size.height * 0.15)
        self.addChild(self.rightKick)
        
        self.energyBarPlayer.position = CGPoint(x: self.roomFrame.size.width * 0.15, y: self.roomFrame.size.height * 0.95)
        self.energyBarPlayer.setScale(0.5)
        self.energyBarOpponent.position = CGPoint(x: self.roomFrame.size.width * 0.85, y: self.roomFrame.size.height * 0.95)
        self.energyBarOpponent.setScale(0.5)
        
        self.addChild(self.energyBarPlayer)
        self.addChild(self.energyBarOpponent)
    }
    
    func checkButtonHit(_ touches:Set<UITouch> ){
        
        var hitBitMask:UInt32 = 0
        
        for touch in touches {
        
            let location = touch.location(in: self)
            
            if self.leftPunch.contains(location) {
                hitBitMask |= Button.punchLeft.rawValue
                
                self.leftPunch.userData = ["touch":touch]
                self.leftPunch.isHidden = true
                
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
        case Button.punchRight.rawValue:
            delegate?.punchRight()
        case Button.punchLeft.rawValue:
            delegate?.punchLeft()
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
                delegate?.checkBlockEnd()
            }
        }
        if let data = self.leftKick.userData {
            if (data["touch"] as! UITouch) === touch {
                self.leftKick.isHidden = false
                self.leftKick.userData = nil
                delegate?.checkBlockEnd()
            }
        }
        if let data = self.rightPunch.userData {
            if (data["touch"] as! UITouch) === touch {
                self.rightPunch.isHidden = false
                self.rightPunch.userData = nil
            }
        }
        if let data = self.rightKick.userData {
            if (data["touch"] as! UITouch) === touch {
                self.rightKick.isHidden = false
                self.rightKick.userData = nil
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
