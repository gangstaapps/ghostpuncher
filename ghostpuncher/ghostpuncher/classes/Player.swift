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
    
    let leftFist:SKSpriteNode
    let rightFist:SKSpriteNode
   
    let fistAtlas:SKTextureAtlas
    var leftJab:SKAction?
    var rightJab:SKAction?
    var leftHaymaker:SKAction?
    var rightHaymaker:SKAction?
    
    var opponentFrame:CGRect
    
    var blockingLeft:Bool = false
    var blockingRight:Bool = false
    
    let MOVEMENT_KEY  = "movementKey"
    
    let fistMovementDegree = 10
    
    init(frame: CGRect) {
        self.opponentFrame = frame
        fistAtlas = SKTextureAtlas(named: "fists.atlas")
        
        let leftJabFrames:[SKTexture] = [
            fistAtlas.textureNamed("left_head1.png"),
            fistAtlas.textureNamed("left_head2.png"),
            fistAtlas.textureNamed("left_head1.png")]
        
        let leftHaymakerJabFrames:[SKTexture] = [
            fistAtlas.textureNamed("left_haymaker1.png"),
            fistAtlas.textureNamed("left_haymaker2.png"),
            fistAtlas.textureNamed("left_haymaker1.png")]
        
        let rightJabFrames:[SKTexture] = [
            fistAtlas.textureNamed("right_head1.png"),
            fistAtlas.textureNamed("right_head2.png"),
            fistAtlas.textureNamed("right_head1.png")]
        
        let rightHaymakerJabFrames:[SKTexture] = [
            fistAtlas.textureNamed("right_haymaker1.png"),
            fistAtlas.textureNamed("right_haymaker2.png"),
            fistAtlas.textureNamed("right_haymaker1.png")]
        
        leftFist = SKSpriteNode(texture: fistAtlas.textureNamed("left_upper2.png"))
        leftFist.anchorPoint = CGPoint(x:0.5, y:0)
        leftFist.position = CGPoint(x: frame.size.width * 0.45, y: -leftFist.frame.size.height * 0.35)
        rightFist = SKSpriteNode(texture: fistAtlas.textureNamed("right_upper2.png"))
        rightFist.anchorPoint = CGPoint(x:0.5, y:0)
        rightFist.position = CGPoint(x: frame.size.width * 0.55, y: -rightFist.frame.size.height * 0.35)
        
        super.init()
        
        let animationTime = 0.08
        
        leftJab = SKAction.sequence([SKAction.run({
            self.leftFist.texture = self.fistAtlas.textureNamed("left_head1.png")
            self.leftFist.position = CGPoint(x: frame.size.width * 0.45, y: 0)
        }),SKAction.animate(with: leftJabFrames, timePerFrame: animationTime), SKAction.run({
            self.leftFist.texture = self.fistAtlas.textureNamed("left_upper2.png")
            self.leftFist.position = CGPoint(x: frame.size.width * 0.4, y: -self.leftFist.frame.size.height * 0.35)
        })])
        
        leftHaymaker = SKAction.sequence([SKAction.run({
            self.leftFist.texture = self.fistAtlas.textureNamed("left_haymaker1.png")
            self.leftFist.position = CGPoint(x: frame.size.width * 0.5, y: 0)
        }),SKAction.animate(with: leftHaymakerJabFrames, timePerFrame: animationTime), SKAction.run({
            self.leftFist.texture = self.fistAtlas.textureNamed("left_upper2.png")
            self.leftFist.position = CGPoint(x: frame.size.width * 0.4, y: -self.leftFist.frame.size.height * 0.35)
        })])
        
        rightJab = SKAction.sequence([SKAction.run({
            self.rightFist.texture = self.fistAtlas.textureNamed("right_head1.png")
            self.rightFist.position = CGPoint(x: frame.size.width * 0.55, y: 0)
        }),SKAction.animate(with: rightJabFrames, timePerFrame: animationTime), SKAction.run({
            self.rightFist.texture = self.fistAtlas.textureNamed("right_upper2.png")
            self.rightFist.position = CGPoint(x: frame.size.width * 0.6, y: -self.leftFist.frame.size.height * 0.35)
        })])
        
        rightHaymaker = SKAction.sequence([SKAction.run({
            self.rightFist.texture = self.fistAtlas.textureNamed("left_upper2.png")
            self.rightFist.position = CGPoint(x: frame.size.width * 0.5, y: 0)
        }),SKAction.animate(with: rightHaymakerJabFrames, timePerFrame: animationTime), SKAction.run({
            self.rightFist.texture = self.fistAtlas.textureNamed("right_upper2.png")
            self.rightFist.position = CGPoint(x: frame.size.width * 0.6, y: -self.leftFist.frame.size.height * 0.35)
        })])
        
        self.addChild(leftFist)
        self.addChild(rightFist)
    
    }
    
    func punchRight(_ power:CGFloat = 1.0){
        if self.checkBlocking() {
            return
        }
        
        if self.rightFist.action(forKey: MOVEMENT_KEY) != nil {
            self.rightFist.removeAction(forKey: MOVEMENT_KEY)
        }
        
        rightFist.run(power > 5 ? rightHaymaker! : rightJab!, withKey: MOVEMENT_KEY)

    }
    
    func punchLeft(_ power:CGFloat = 1.0){
        if self.checkBlocking() {
            return
        }
        
        if self.leftFist.action(forKey: MOVEMENT_KEY) != nil {
            self.leftFist.removeAction(forKey: MOVEMENT_KEY)
        }
        
        leftFist.run(power > 5 ? leftHaymaker! : leftJab!, withKey: MOVEMENT_KEY)
    }
    
    func update(){
        if self.checkBlocking() {
            return
        }
        if self.leftFist.action(forKey: MOVEMENT_KEY) == nil {
            let newPos:CGPoint = CGPoint(x: self.opponentFrame.size.width * 0.4 + CGFloat(arc4random_uniform(UInt32(fistMovementDegree))) - CGFloat(arc4random_uniform(UInt32(fistMovementDegree))), y: (-self.leftFist.frame.size.height * 0.35) + CGFloat(arc4random_uniform(UInt32(fistMovementDegree))) - CGFloat(arc4random_uniform(UInt32(fistMovementDegree))))
            
            let movement:SKAction = SKAction.move(to: newPos, duration: 4)
            self.leftFist.run(movement, withKey: MOVEMENT_KEY)
        }
        if self.rightFist.action(forKey: MOVEMENT_KEY) == nil {
            let newPos:CGPoint = CGPoint(x: self.opponentFrame.size.width * 0.6 + CGFloat(arc4random_uniform(UInt32(fistMovementDegree))) - CGFloat(arc4random_uniform(UInt32(fistMovementDegree))), y: (-self.rightFist.frame.size.height * 0.35) + CGFloat(arc4random_uniform(UInt32(fistMovementDegree))) - CGFloat(arc4random_uniform(UInt32(fistMovementDegree))))
            
            let movement:SKAction = SKAction.move(to: newPos, duration: 4)
            self.rightFist.run(movement, withKey: MOVEMENT_KEY)
        }
    }
    
    func blockStart(){
        if self.leftFist.action(forKey: MOVEMENT_KEY) != nil {
            self.leftFist.removeAction(forKey: MOVEMENT_KEY)
        }
        if self.rightFist.action(forKey: MOVEMENT_KEY) != nil {
            self.rightFist.removeAction(forKey: MOVEMENT_KEY)
        }
        self.leftFist.texture = self.fistAtlas.textureNamed("left_upper2.png")
        self.rightFist.texture = self.fistAtlas.textureNamed("right_upper2.png")
        blockingLeft = true
        blockingRight = true;
        self.leftFist.position.y = 0
        self.rightFist.position.y = 0
    }
    
    func checkBlocking() -> Bool{
        return blockingLeft || blockingRight
    }
    func blockEndRight()->Bool{
        if !blockingRight {
            return false
        }
        blockingRight = false
        self.leftFist.position.y = -self.leftFist.frame.size.height * 0.35
        self.rightFist.position.y = -self.rightFist.frame.size.height * 0.35
        return true
    }
    func blockEndLeft()->Bool{
        if !blockingLeft {
            return false
        }
        blockingLeft = false
        self.leftFist.position.y = -self.leftFist.frame.size.height * 0.35
        self.rightFist.position.y = -self.rightFist.frame.size.height * 0.35
        return true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
