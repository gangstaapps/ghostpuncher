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

// MARK: - GameSettings

final class GameSettings {
    static let shared = GameSettings()

    private enum Keys {
        static let sfxVolume = "settings.sfxVolume"
        static let musicVolume = "settings.musicVolume"
        static let tiltControls = "settings.tiltControls"
        static let haptics = "settings.haptics"
        static let reduceMotion = "settings.reduceMotion"
        static let largeTargets = "settings.largeTargets"
        static let tutorialCompleted = "settings.tutorialCompleted"
    }

    static let changedNotification = Notification.Name("GameSettingsChanged")

    private let defaults = UserDefaults.standard

    private init() {
        defaults.register(defaults: [
            Keys.sfxVolume: 1.0,
            Keys.musicVolume: 0.6,
            Keys.tiltControls: true,
            Keys.haptics: true,
            Keys.reduceMotion: false,
            Keys.largeTargets: false,
            Keys.tutorialCompleted: false,
        ])
    }

    private func notify() {
        NotificationCenter.default.post(name: GameSettings.changedNotification, object: self)
    }

    var sfxVolume: Float {
        get { defaults.float(forKey: Keys.sfxVolume) }
        set { defaults.set(newValue, forKey: Keys.sfxVolume); notify() }
    }

    var musicVolume: Float {
        get { defaults.float(forKey: Keys.musicVolume) }
        set { defaults.set(newValue, forKey: Keys.musicVolume); notify() }
    }

    var tiltControls: Bool {
        get { defaults.bool(forKey: Keys.tiltControls) }
        set { defaults.set(newValue, forKey: Keys.tiltControls); notify() }
    }

    var haptics: Bool {
        get { defaults.bool(forKey: Keys.haptics) }
        set { defaults.set(newValue, forKey: Keys.haptics); notify() }
    }

    var reduceMotion: Bool {
        get { defaults.bool(forKey: Keys.reduceMotion) }
        set { defaults.set(newValue, forKey: Keys.reduceMotion); notify() }
    }

    var largeTargets: Bool {
        get { defaults.bool(forKey: Keys.largeTargets) }
        set { defaults.set(newValue, forKey: Keys.largeTargets); notify() }
    }

    var tutorialCompleted: Bool {
        get { defaults.bool(forKey: Keys.tutorialCompleted) }
        set { defaults.set(newValue, forKey: Keys.tutorialCompleted); notify() }
    }
}
