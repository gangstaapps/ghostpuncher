//
//  GameMode.swift
//  ghostpuncher
//
//  Created by Erik James on 10/18/16.
//  Copyright © 2016 Erik James. All rights reserved.
//
//  2026 modernization: replaced the 2-state GameModes enum with a real
//  FightState machine. File name kept stable so the pbxproj does not
//  need to be touched.

import SpriteKit

enum FightState: UInt8 {
    case intro
    case fighting
    case paused
    case victory
    case defeat

    var acceptsInput: Bool {
        return self == .fighting
    }

    var runsSimulation: Bool {
        return self == .fighting
    }
}

final class FightStateMachine {
    private(set) var current: FightState = .intro

    var onChange: ((_ previous: FightState, _ next: FightState) -> Void)?

    func transition(to next: FightState) {
        guard next != current else { return }
        let previous = current
        current = next
        onChange?(previous, next)
    }
}
