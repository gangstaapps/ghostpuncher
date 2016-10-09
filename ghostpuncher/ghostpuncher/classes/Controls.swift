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
}

class Controls:SKNode
{
    let roomFrame:CGRect
    
    let leftPunch:SKSpriteNode
    let leftKick:SKSpriteNode
    let rightPunch:SKSpriteNode
    let rightKick:SKSpriteNode
    
    weak var delegate:ControlsDelegate?
    
    init(frame: CGRect) {
        self.roomFrame = frame
        
        self.leftPunch  = SKSpriteNode(imageNamed: "punch_reg")
        self.rightPunch   = SKSpriteNode(imageNamed: "punch_reg")
        self.leftKick = SKSpriteNode(imageNamed: "kick_reg")
        self.rightKick  = SKSpriteNode(imageNamed: "kick_reg")
        
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
    }
    
    func checkButtonHit(location:CGPoint, touch:UITouch){
        if self.leftPunch.contains(location) {
            self.leftPunch.userData = ["touch":touch]
            self.leftPunch.isHidden = true
            delegate?.punchLeft()
        }
        if self.leftKick.contains(location) {
            self.leftKick.userData = ["touch":touch]
            self.leftKick.isHidden = true
            delegate?.kickLeft()
        }
        if self.rightPunch.contains(location) {
            self.rightPunch.userData = ["touch":touch]
            self.rightPunch.isHidden = true
            delegate?.punchRight()
        }
        if self.rightKick.contains(location) {
            self.rightKick.userData = ["touch":touch]
            self.rightKick.isHidden = true
            delegate?.kickRight()
        }
    }
    
    func touchEnded(location:CGPoint, touch:UITouch){
        
        if let data = self.leftPunch.userData {
            if (data["touch"] as! UITouch) === touch {
                self.leftPunch.isHidden = false
                self.leftPunch.userData = nil
            }
        }
        if let data = self.leftKick.userData {
            if (data["touch"] as! UITouch) === touch {
                self.leftKick.isHidden = false
                self.leftKick.userData = nil
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
