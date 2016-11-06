//
//  Room.swift
//  ghostpuncher
//
//  Created by Erik James on 10/7/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

class Room: SKNode
{
    let roomFrame:CGRect
    let background:SKSpriteNode
//    let foreground:SKSpriteNode
    let portalEffect:SKAction
    let portal:SKSpriteNode
    var targetPortalScale:CGSize?
    
    init(frame: CGRect, name:String) {
        self.roomFrame = frame
        self.background = SKSpriteNode(imageNamed:"\(name)_background")
//        self.foreground = SKSpriteNode(imageNamed:"foreground")
        
        let portalAtlas = SKTextureAtlas(named: "portal.atlas")
        var portalFrames:[SKTexture] = []
        for i in 1...24 {
            portalFrames.append(portalAtlas.textureNamed("portal\(i).png"))
        }
        
        portalEffect = SKAction.repeatForever(SKAction.animate(with: portalFrames, timePerFrame: 0.05))
        portal = SKSpriteNode(texture: portalFrames[0])
        
        super.init()
        self.background.size = CGSize(width: self.roomFrame.size.height * 2.2, height: self.roomFrame.size.height * 1.1)
        self.background.position = CGPoint(x: frame.midX, y: frame.midY)
        self.addChild(self.background)
        
//        self.foreground.size = CGSize(width: self.roomFrame.size.width * 1.5,
//                                      height: ((self.roomFrame.size.width * 1.5) / self.foreground.frame.size.width) * self.roomFrame.size.height )
//        self.foreground.position = CGPoint(x: frame.midX, y: frame.size.height * 0.25)
//        self.addChild(self.foreground)
        
        self.portal.size = CGSize(width: self.roomFrame.size.width, height: self.roomFrame.size.height)
        self.portal.position = CGPoint(x: frame.midX, y: frame.midY)
        self.portal.alpha = 0.0
        targetPortalScale = CGSize(width: self.portal.xScale, height: self.portal.yScale)
        
        let backgroundQueue = DispatchQueue(label: "com.app.queue",
                                            qos: .background,
                                            target: nil)
        
        backgroundQueue.async {
            SKTexture.preload(portalFrames, withCompletionHandler: {
//                DispatchQueue.main.async {
//                    self.portal.run(self.portalEffect)
//                    self.addChild(self.portal)
//                }
            })
        }
        
        
    }
    
    func openPortal (){
        self.portal.run(self.portalEffect)
        if self.portal.parent == nil {
            self.addChild(self.portal)
        }
        self.portal.run(SKAction.fadeIn(withDuration: 0.4))
    }
    func closePortal(){
        self.portal.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.4), SKAction.removeFromParent()]))
        
    }
    
    func lunge(){
        self.background.run(SKAction.sequence([SKAction.scale(to: 0.9, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.1)]))
        
//        self.foreground.run(SKAction.sequence([SKAction.scale(to: 0.95, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.1)]))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
