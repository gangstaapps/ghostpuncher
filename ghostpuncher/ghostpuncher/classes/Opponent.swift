//
//  Opponent.swift
//  ghostpuncher
//
//  Created by Erik James on 10/7/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class Opponent:SKNode
{
    var opponent:SKNode!
    var opponentName:String
    var opponentFrame:CGRect
    var rightArmAttack:SKAction?
    var leftArmAttack:SKAction?
    
    var leftArm:SKNode?
    var rightArm:SKNode?
    
    let startPosition:CGPoint
    var currentlyMoving:Bool = false
    
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
        }
    }
    
    func doLeftArmAttack(){
        self.leftArm?.run(self.leftArmAttack!)
    }
    
    func doRightArmAttack(){
        self.rightArm?.run(self.rightArmAttack!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(){
        if !currentlyMoving {
            currentlyMoving = true
            let newPos:CGPoint = CGPoint(x: startPosition.x + CGFloat(arc4random_uniform(UInt32(30))) - CGFloat(arc4random_uniform(UInt32(30))), y: startPosition.y + CGFloat(arc4random_uniform(UInt32(30))) - CGFloat(arc4random_uniform(UInt32(30))))
            
            let movement:SKAction = SKAction.move(to: newPos, duration: 4)
            self.opponent.run(movement, completion: {() -> Void in
                self.currentlyMoving = false
            })
        }
        
    }
}
