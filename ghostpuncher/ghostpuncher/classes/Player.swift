//
//  Player.swift
//  ghostpuncher
//
//  Created by Erik James on 10/7/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class Player:SKNode
{
    
    var leftPunch:SKSpriteNode?
    var rightPunch:SKSpriteNode?
    var leftUpperCut:SKSpriteNode?
    var rightUpperCut:SKSpriteNode?
    var frontKick:SKSpriteNode?
    var leftKick:SKSpriteNode?
    
    var opponentFrame:CGRect
    
    init(frame: CGRect) {
        self.opponentFrame = frame
        
        super.init()
        
        self.leftPunch = SKSpriteNode(imageNamed: "leftpunch")
        self.rightPunch = SKSpriteNode(imageNamed: "rightpunch")
        self.leftUpperCut = SKSpriteNode(imageNamed: "leftuppercut")
        self.rightUpperCut = SKSpriteNode(imageNamed: "rightuppercut")
        self.frontKick = SKSpriteNode(imageNamed: "frontkick")
        self.leftKick = SKSpriteNode(imageNamed: "leftkick")
        
        self.frontKick?.position = CGPoint(x: frame.size.width/2, y: 0)
        self.frontKick?.anchorPoint = CGPoint(x:0.5, y:0)
        
        self.leftKick?.position = CGPoint(x: frame.size.width * 0.4, y: -frame.size.height * 0.2)
        self.leftKick?.anchorPoint = CGPoint(x:0.5, y:0)
        
        self.leftUpperCut?.position = CGPoint(x: frame.size.width/2, y: 0)
        self.leftUpperCut?.anchorPoint = CGPoint(x:0.5, y:0)
        
        self.rightPunch?.position = CGPoint(x: frame.size.width * 0.75, y: 0)
        self.rightPunch?.anchorPoint = CGPoint(x:0.5, y:0)
        
        self.leftPunch?.position = CGPoint(x: frame.size.width * 0.25, y: 0)
        self.leftPunch?.anchorPoint = CGPoint(x:0.5, y:0)

    }
    
    func punchRight(){
        if self.rightPunch?.parent != nil {
            return
        }
        self.addChild(self.rightPunch!)
        let pause = SKAction.wait(forDuration: 0.1)
        let sequence = SKAction.sequence([pause, SKAction.removeFromParent()])
        self.rightPunch?.run(sequence)
        
    }
    
    func punchLeft(){
        if self.leftPunch?.parent != nil {
            return
        }
        self.addChild(self.leftPunch!)
        let pause = SKAction.wait(forDuration: 0.1)
        let sequence = SKAction.sequence([pause, SKAction.removeFromParent()])
        self.leftPunch?.run(sequence)
        
    }
    
    func kickLeft(){
        if self.leftKick?.parent != nil {
            return
        }
        self.addChild(self.leftKick!)
        let pause = SKAction.wait(forDuration: 0.1)
        let sequence = SKAction.sequence([pause, SKAction.removeFromParent()])
        self.leftKick?.run(sequence)
        
    }
    
    func kickRight(){
        if self.frontKick?.parent != nil {
            return
        }
        self.addChild(self.frontKick!)
        let pause = SKAction.wait(forDuration: 0.1)
        let sequence = SKAction.sequence([pause, SKAction.removeFromParent()])
        self.frontKick?.run(sequence)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
