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
//    var leftFistReady:SKSpriteNode?
//    var rightFistReady:SKSpriteNode?
   
    let fistAtlas:SKTextureAtlas
    var leftJab:SKAction?
    var rightJab:SKAction?
    var leftHaymaker:SKAction?
    var rightHaymaker:SKAction?
    
    var opponentFrame:CGRect
    
    var blockingLeft:Bool = false
    var blockingRight:Bool = false
    
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
        
//        self.leftPunch = SKSpriteNode(texture: fistAtlas.textureNamed("right_upper2.png"))
//        self.rightPunch = SKSpriteNode(texture: fistAtlas.textureNamed("right_upper2.png"))
//        self.leftFistReady = SKSpriteNode(texture: fistAtlas.textureNamed("left_upper2.png"))
//        self.rightFistReady = SKSpriteNode(texture: fistAtlas.textureNamed("right_upper2.png"))
//        
//        
//        self.leftFistReady?.position = CGPoint(x: frame.size.width * 0.4, y: 0)
//        self.leftFistReady?.anchorPoint = CGPoint(x:0.5, y:0)
//        
//        self.rightFistReady?.position = CGPoint(x: frame.size.width * 0.6, y: 0)
//        self.rightFistReady?.anchorPoint = CGPoint(x:0.5, y:0)
//        
//        self.rightPunch?.position = CGPoint(x: frame.size.width * 0.75, y: 0)
//        self.rightPunch?.anchorPoint = CGPoint(x:0.5, y:0)
//        
//        self.leftPunch?.position = CGPoint(x: frame.size.width * 0.25, y: 0)
//        self.leftPunch?.anchorPoint = CGPoint(x:0.5, y:0)

    }
    
    func punchRight(_ power:CGFloat = 1.0){
        if self.checkBlocking() {
            return
        }
        if self.rightFist.position.y == 0 {
            return
        }
        
        
//        rightFist.position.y = 0
        rightFist.run(power > 5 ? rightHaymaker! : rightJab!)
        
//        if self.rightPunch?.parent != nil {
//            return
//        }
//        self.addChild(self.rightPunch!)
//        let pause = SKAction.wait(forDuration: 0.1)
//        let sequence = SKAction.sequence([pause, SKAction.removeFromParent()])
//        self.rightPunch?.run(sequence)
        
    }
    
    func punchLeft(_ power:CGFloat = 1.0){
        if self.checkBlocking() {
            return
        }
        
        if self.leftFist.position.y == 0 {
            return
        }
        
//        leftFist.position.y = 0
        leftFist.run(power > 5 ? leftHaymaker! : leftJab!)
//        if self.leftPunch?.parent != nil {
//            return
//        }
//        self.addChild(self.leftPunch!)
//        let pause = SKAction.wait(forDuration: 0.1)
//        let sequence = SKAction.sequence([pause, SKAction.removeFromParent()])
//        self.leftPunch?.run(sequence)
        
    }
    
    
    func blockStart(){
//        if self.rightFist.position.y == 0 {
//            return
//        }
        blockingLeft = true
        blockingRight = true;
        self.leftFist.position.y = 0
        self.rightFist.position.y = 0
//        self.addChild(self.rightFistReady!)
//        self.addChild(self.leftFistReady!)
        
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
