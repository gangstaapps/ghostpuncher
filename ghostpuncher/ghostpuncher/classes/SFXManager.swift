//
//  SFXManager.swift
//  ghostpuncher
//
//  Created by Erik James on 10/18/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

enum SFX:String
{
    case PLAYER_CONNECT = "playerConnect"
    case BUTTON_CLICK = "click.wav"
}

class SFXManager:SKNode {
    
    static let PLAY_SFX = "playSFX"
    
    override init(){
       
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playSFX(_:)), name: NSNotification.Name(rawValue: SFXManager.PLAY_SFX), object: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playSFX(_ notification : NSNotification){
        
         guard let sfxType = notification.userInfo!["sfxType"] as? SFX else {
                print("No userInfo found in notification")
                return
        }
        
        let sound =
            SKAction.playSoundFileNamed("\(sfxType.rawValue)",
                                        waitForCompletion: true)
        
        self.run(sound)
        
    }
}
