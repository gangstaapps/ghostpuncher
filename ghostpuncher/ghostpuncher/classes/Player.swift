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

    // Cancel-window timing. Tapping a punch this many seconds after the
    // previous punch chains into a combo cancel — each successive cancel
    // builds a damage multiplier. Tapping outside the window resets the chain.
    private let CANCEL_WINDOW_OPEN: TimeInterval  = 0.14
    private let CANCEL_WINDOW_CLOSE: TimeInterval = 0.28
    private let MAX_CHAIN_BONUS: CGFloat = 0.6  // +60% at full chain
    private let BONUS_PER_LINK:  CGFloat = 0.15

    private var lastPunchTime: TimeInterval = 0
    private(set) var cancelChain: Int = 0

    // Stamina — tapping too often burns out player damage. Encourages
    // rhythm-based play instead of pure button mash.
    private let STAMINA_MAX: CGFloat = 100
    private let STAMINA_REGEN_PER_SEC: CGFloat = 28
    private let LIGHT_PUNCH_COST: CGFloat = 8
    private let HAYMAKER_COST: CGFloat = 14
    private var lastStaminaTickTime: TimeInterval = 0

    private(set) var stamina: CGFloat = 100

    var staminaPercent: CGFloat { return stamina / STAMINA_MAX }

    /// Returns the damage multiplier the current stamina level produces.
    /// Full bar = 1.0. Low stamina punches deal less.
    var staminaPowerMultiplier: CGFloat {
        let pct = staminaPercent
        if pct > 0.4 { return 1.0 }
        if pct > 0.2 { return 0.7 }
        if pct > 0.05 { return 0.4 }
        return 0.15
    }

    func consumeStamina(forHaymaker: Bool) {
        let cost = forHaymaker ? HAYMAKER_COST : LIGHT_PUNCH_COST
        stamina = max(0, stamina - cost)
    }

    func updateStamina(currentTime: TimeInterval) {
        if lastStaminaTickTime == 0 { lastStaminaTickTime = currentTime; return }
        let dt = CGFloat(currentTime - lastStaminaTickTime)
        lastStaminaTickTime = currentTime
        stamina = min(STAMINA_MAX, stamina + STAMINA_REGEN_PER_SEC * dt)
    }
    
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
        
        leftJab = SKAction.sequence([SKAction.run({[weak self] in
            self?.leftFist.texture = self?.fistAtlas.textureNamed("left_head1.png")
            self?.leftFist.position = CGPoint(x: frame.size.width * 0.45, y: 0)
        }),SKAction.animate(with: leftJabFrames, timePerFrame: animationTime), SKAction.run({[weak self] in
            self?.leftFist.texture = self?.fistAtlas.textureNamed("left_upper2.png")
            self?.leftFist.position = CGPoint(x: frame.size.width * 0.4, y: -(self?.leftFist.frame.size.height)! * 0.35)
        })])
        
        leftHaymaker = SKAction.sequence([SKAction.run({[weak self] in
            self?.leftFist.texture = self?.fistAtlas.textureNamed("left_haymaker1.png")
            self?.leftFist.position = CGPoint(x: frame.size.width * 0.5, y: 0)
        }),SKAction.animate(with: leftHaymakerJabFrames, timePerFrame: animationTime), SKAction.run({[weak self] in
            self?.leftFist.texture = self?.fistAtlas.textureNamed("left_upper2.png")
            self?.leftFist.position = CGPoint(x: frame.size.width * 0.4, y: -(self?.leftFist.frame.size.height)! * 0.35)
        })])
        
        rightJab = SKAction.sequence([SKAction.run({[weak self] in
            self?.rightFist.texture = self?.fistAtlas.textureNamed("right_head1.png")
            self?.rightFist.position = CGPoint(x: frame.size.width * 0.55, y: 0)
        }),SKAction.animate(with: rightJabFrames, timePerFrame: animationTime), SKAction.run({[weak self] in
            self?.rightFist.texture = self?.fistAtlas.textureNamed("right_upper2.png")
            self?.rightFist.position = CGPoint(x: frame.size.width * 0.6, y: -(self?.leftFist.frame.size.height)! * 0.35)
        })])
        
        rightHaymaker = SKAction.sequence([SKAction.run({[weak self] in
            self?.rightFist.texture = self?.fistAtlas.textureNamed("left_upper2.png")
            self?.rightFist.position = CGPoint(x: frame.size.width * 0.5, y: 0)
        }),SKAction.animate(with: rightHaymakerJabFrames, timePerFrame: animationTime), SKAction.run({[weak self] in
            self?.rightFist.texture = self?.fistAtlas.textureNamed("right_upper2.png")
            self?.rightFist.position = CGPoint(x: frame.size.width * 0.6, y: -(self?.leftFist.frame.size.height)! * 0.35)
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

        if cancelChain >= 2 {
            playCancelFlash(on: rightFist)
        }
    }

    func punchLeft(_ power:CGFloat = 1.0){
        if self.checkBlocking() {
            return
        }

        if self.leftFist.action(forKey: MOVEMENT_KEY) != nil {
            self.leftFist.removeAction(forKey: MOVEMENT_KEY)
        }

        leftFist.run(power > 5 ? leftHaymaker! : leftJab!, withKey: MOVEMENT_KEY)

        if cancelChain >= 2 {
            playCancelFlash(on: leftFist)
        }
    }

    /// Consumes the timing of an incoming punch and returns a power
    /// multiplier. Within the cancel window the chain extends; outside it
    /// resets to zero. Call this exactly once per punch input.
    func consumePunchTiming() -> CGFloat {
        let now = CACurrentMediaTime()
        let dt = now - lastPunchTime
        lastPunchTime = now

        if dt >= CANCEL_WINDOW_OPEN && dt <= CANCEL_WINDOW_CLOSE {
            cancelChain += 1
            let bonus = min(BONUS_PER_LINK * CGFloat(cancelChain), MAX_CHAIN_BONUS)
            return 1.0 + bonus
        }
        cancelChain = 0
        return 1.0
    }

    private func playCancelFlash(on fist: SKSpriteNode) {
        fist.run(SKAction.sequence([
            SKAction.colorize(with: SKColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1),
                              colorBlendFactor: 0.7, duration: 0.04),
            SKAction.wait(forDuration: 0.08),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.10)
        ]))
    }
    
    func update(){
        if blockingLeft && blockingRight {
            
            if self.leftFist.action(forKey: MOVEMENT_KEY) == nil {
                let newPos:CGPoint = CGPoint(x: self.opponentFrame.size.width * 0.4 + CGFloat(arc4random_uniform(UInt32(fistMovementDegree))) - CGFloat(arc4random_uniform(UInt32(fistMovementDegree))), y: -CGFloat(arc4random_uniform(UInt32(fistMovementDegree))))
                
                let movement:SKAction = SKAction.move(to: newPos, duration: 4)
                self.leftFist.run(movement, withKey: MOVEMENT_KEY)
            }
            if self.rightFist.action(forKey: MOVEMENT_KEY) == nil {
                let newPos:CGPoint = CGPoint(x: self.opponentFrame.size.width * 0.6 + CGFloat(arc4random_uniform(UInt32(fistMovementDegree))) - CGFloat(arc4random_uniform(UInt32(fistMovementDegree))), y: -CGFloat(arc4random_uniform(UInt32(fistMovementDegree))))
                
                let movement:SKAction = SKAction.move(to: newPos, duration: 4)
                self.rightFist.run(movement, withKey: MOVEMENT_KEY)
            }
            
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
        self.leftFist.removeAllActions()
        self.rightFist.removeAllActions()
        blockingRight = false
//        blockingLeft = false
        self.leftFist.position.y = -self.leftFist.frame.size.height * 0.35
        self.rightFist.position.y = -self.rightFist.frame.size.height * 0.35
        return true
    }
    func blockEndLeft()->Bool{
        if !blockingLeft {
            return false
        }
        self.leftFist.removeAllActions()
        self.rightFist.removeAllActions()
//        blockingRight = false
        blockingLeft = false
        self.leftFist.position.y = -self.leftFist.frame.size.height * 0.35
        self.rightFist.position.y = -self.rightFist.frame.size.height * 0.35
        return true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
