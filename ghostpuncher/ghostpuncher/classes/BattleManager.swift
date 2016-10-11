//
//  BattleManager.swift
//  ghostpuncher
//
//  Created by Erik James on 10/11/16.
//  Copyright © 2016 Erik James. All rights reserved.
//

import SpriteKit

protocol BattleManagerDelegate: class {
    func playerHealthUpdated(newAmount:CGFloat)
    func opponentHealthUpdated(newAmount:CGFloat)
    func playerWon()
    func playerLost()
    func opponentAttackLeft()
    func opponentAttackRight()
}

class BattleManager
{
    var playerHealth:CGFloat?
    var opponentHealth:CGFloat?
    
    weak var delegate:BattleManagerDelegate?
    
    init(opponentHealth:CGFloat = 100.0, playerHealth:CGFloat = 100.0){
        self.playerHealth = playerHealth
        self.opponentHealth = opponentHealth
    }
    
    func playerConnect(power:CGFloat = 5.0){
        opponentHealth = max(opponentHealth! - power, 0.0)
        delegate?.opponentHealthUpdated(newAmount: opponentHealth!)
        self.checkForWinner()
    }
    
    func opponentConnect(power:CGFloat = 5.0){
        playerHealth = max(playerHealth! - power, 0.0)
        delegate?.playerHealthUpdated(newAmount: playerHealth!)
        self.checkForWinner()
    }
    
    
    func checkForWinner(){
        if opponentHealth! <= 0 {
            delegate?.playerWon()
        } else if playerHealth! <= 0 {
            delegate?.playerLost()
        }
    }
    
    func update(_ currentTime: TimeInterval) {
        //
        if Int(arc4random_uniform(UInt32(100))) == 13 {
//            self.opponent?.doLeftArmAttack()
            delegate?.opponentAttackLeft()
        }
        
        if Int(arc4random_uniform(UInt32(100))) == 7 {
//            self.opponent?.doRightArmAttack()
            delegate?.opponentAttackRight()
        }
        
    }
}
