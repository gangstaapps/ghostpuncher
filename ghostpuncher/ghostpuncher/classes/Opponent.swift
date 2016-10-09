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
    
    init(frame: CGRect, name:String) {
        self.opponentFrame = frame
        self.opponentName = name
        super.init()
        
        if let ghostScene:SKScene = SKScene(fileNamed: self.opponentName){
            self.opponent = ghostScene.childNode(withName: "opponent")!
            
            self.opponent.removeFromParent();
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
}
