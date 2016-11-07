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
}



class BattleManager
{
    static var playerHealth:CGFloat?
    static var opponentHealth:CGFloat?
    
    static let opponentNames = ["ghost", "witch", "devil"]
    
    static var level = 1
    static var multiplier = 1
    
    let opponentHealthStart:CGFloat = 100.0
    let playerHealthStart:CGFloat = 100.0
    
    weak var delegate:BattleManagerDelegate?
    
    init(opponentHealth:CGFloat = 100.0, playerHealth:CGFloat = 100.0){
        BattleManager.playerHealth = playerHealth
        BattleManager.opponentHealth = opponentHealth
    }
    
    func playerConnect(power:CGFloat = 5.0){
//        print("playerConnect")
        BattleManager.opponentHealth = max(BattleManager.opponentHealth! - power, 0.0)
        delegate?.opponentHealthUpdated(newAmount: BattleManager.opponentHealth!/opponentHealthStart)
        self.checkForWinner()
    }
    
    func opponentConnect(power:CGFloat = 5.0){
        BattleManager.playerHealth = max(BattleManager.playerHealth! - power, 0.0)
        delegate?.playerHealthUpdated(newAmount: BattleManager.playerHealth!/playerHealthStart)
        self.checkForWinner()
    }
    
    func checkForWinner(){
        if BattleManager.opponentHealth! <= 0 {
            delegate?.playerWon()
        } else if BattleManager.playerHealth! <= 0 {
            delegate?.playerLost()
        }
    }
    
  
}
