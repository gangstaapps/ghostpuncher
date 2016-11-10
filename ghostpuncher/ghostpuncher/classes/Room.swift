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
//    let portalEffect:SKAction
//    let portal:SKSpriteNode
    var targetPortalScale:CGSize?
    let portalAtlas:SKTextureAtlas
    let portalFrames:[SKTexture]
    let portalEffect:SKAction
    let portal:SKSpriteNode
    static var framesLoaded = false
    
    init(frame: CGRect, name:String) {
        self.roomFrame = frame
        self.background = SKSpriteNode(imageNamed:"\(name)_background")
//        self.foreground = SKSpriteNode(imageNamed:"foreground")
        
        
//        for i in 1...24 {
//            portalFrames.append(portalAtlas.textureNamed("portal\(i).png"))
//        }
        portalAtlas = SKTextureAtlas(named: "portal.atlas")
        portalFrames = [portalAtlas.textureNamed("portal1.png"),
                                        portalAtlas.textureNamed("portal2.png"),
                                        portalAtlas.textureNamed("portal3.png"),
                                        portalAtlas.textureNamed("portal4.png"),
                                        portalAtlas.textureNamed("portal5.png"),
                                        portalAtlas.textureNamed("portal6.png"),
                                        portalAtlas.textureNamed("portal7.png"),
                                        portalAtlas.textureNamed("portal8.png"),
                                        portalAtlas.textureNamed("portal9.png"),
                                        portalAtlas.textureNamed("portal10.png"),
                                        portalAtlas.textureNamed("portal11.png"),
                                        portalAtlas.textureNamed("portal12.png"),
                                        portalAtlas.textureNamed("portal13.png"),
                                        portalAtlas.textureNamed("portal14.png"),
                                        portalAtlas.textureNamed("portal15.png"),
                                        portalAtlas.textureNamed("portal16.png"),
                                        portalAtlas.textureNamed("portal17.png"),
                                        portalAtlas.textureNamed("portal18.png"),
                                        portalAtlas.textureNamed("portal19.png"),
                                        portalAtlas.textureNamed("portal20.png"),
                                        portalAtlas.textureNamed("portal21.png"),
                                        portalAtlas.textureNamed("portal22.png"),
                                        portalAtlas.textureNamed("portal23.png"),
                                        portalAtlas.textureNamed("portal24.png")]
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
        
        portal.size = CGSize(width: self.roomFrame.size.width, height: self.roomFrame.size.height)
        portal.position = CGPoint(x: frame.midX, y: frame.midY)
        portal.alpha = 0.0
        targetPortalScale = CGSize(width: portal.xScale, height: portal.yScale)
        
//        if !Room.framesLoaded {
            Room.framesLoaded = true
            let backgroundQueue = DispatchQueue(label: "com.app.queue",
                                                qos: .background,
                                                target: nil)
            
            backgroundQueue.async {
                SKTexture.preload(self.portalFrames, withCompletionHandler: {
    //                DispatchQueue.main.async {
    //                    self.portal.run(self.portalEffect)
    //                    self.addChild(self.portal)
    //                }
                })
            }
//        }
        
    }
    
    func openPortal (){
        portal.run(portalEffect)
        if portal.parent != nil {
            portal.removeFromParent()
//            Room.portal.alpha = 1.0
        }
        portal.alpha = 1.0
            self.addChild(portal)
        
//        Room.portal.run(SKAction.fadeIn(withDuration: 0.4))
    }
    func closePortal(){
        portal.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.4), SKAction.removeFromParent()]))
        
    }
    
    func lunge(){
        self.background.run(SKAction.sequence([SKAction.scale(to: 0.9, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.1)]))
        
//        self.foreground.run(SKAction.sequence([SKAction.scale(to: 0.95, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.1)]))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
