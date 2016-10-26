//
//  Devil.swift
//  ghostpuncher
//
//  Created by Erik James on 10/24/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class Devil: Opponent {
    init(frame:CGRect) {
        super.init(frame: frame, name: "devil")
    }
    
    override func hitRecoil(_ direction:Direction, power:CGFloat){
        self.opponent.alpha = 1.0
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
        
        self.opponent?.run(SKAction.group([sequence, SKAction.moveBy(x: (direction == .right ? -moveAmount : moveAmount), y: 0, duration: 0.1)]), withKey: MOVEMENT_KEY )
        
    }
    
    override func returnGlowColor()->SKColor {
        return SKColor.red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
