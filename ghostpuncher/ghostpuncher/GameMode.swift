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
import CoreHaptics
import UIKit

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

// MARK: - Haptics

final class HapticsService {
    static let shared = HapticsService()

    private var engine: CHHapticEngine?
    private let supportsCoreHaptics: Bool

    private let lightGen  = UIImpactFeedbackGenerator(style: .light)
    private let mediumGen = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGen  = UIImpactFeedbackGenerator(style: .heavy)

    private init() {
        supportsCoreHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        if supportsCoreHaptics {
            do {
                let e = try CHHapticEngine()
                e.resetHandler = { [weak self] in try? self?.engine?.start() }
                e.stoppedHandler = { _ in }
                try e.start()
                engine = e
            } catch {
                // Fall back to UIImpactFeedbackGenerator below.
            }
        }
        [lightGen, mediumGen, heavyGen].forEach { $0.prepare() }
    }

    func punchConnect(power: CGFloat) {
        if !supportsCoreHaptics || engine == nil {
            if power < 3 { lightGen.impactOccurred() }
            else if power < 7 { mediumGen.impactOccurred() }
            else { heavyGen.impactOccurred() }
            return
        }
        if power < 3 { playTransient(intensity: 0.5, sharpness: 0.6) }
        else if power < 7 { playTransient(intensity: 0.75, sharpness: 0.7) }
        else { playTransient(intensity: 1.0, sharpness: 0.85) }
    }

    func playerHit() {
        if !supportsCoreHaptics || engine == nil { heavyGen.impactOccurred(); return }
        playContinuous(intensity: 0.85, sharpness: 0.35, duration: 0.18)
    }

    func cancelChainTick() {
        if !supportsCoreHaptics || engine == nil { lightGen.impactOccurred(); return }
        playTransient(intensity: 0.45, sharpness: 0.95)
    }

    func bossIntro() {
        if !supportsCoreHaptics || engine == nil { heavyGen.impactOccurred(); return }
        playContinuous(intensity: 0.85, sharpness: 0.15, duration: 0.9)
    }

    func telegraphTell() {
        if !supportsCoreHaptics || engine == nil { return }
        playTransient(intensity: 0.3, sharpness: 0.5)
    }

    private func playTransient(intensity: Float, sharpness: Float) {
        guard let engine = engine else { return }
        let i = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let s = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [i, s], relativeTime: 0)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }

    private func playContinuous(intensity: Float, sharpness: Float, duration: TimeInterval) {
        guard let engine = engine else { return }
        let i = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let s = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        let event = CHHapticEvent(eventType: .hapticContinuous,
                                  parameters: [i, s],
                                  relativeTime: 0,
                                  duration: duration)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {}
    }
}
