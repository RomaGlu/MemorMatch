//
//  GameSettings.swift
//  MemoMatch
//
//  Created by Роман Глухарев on 17.05.25.
//

import Foundation
import UIKit
import SpriteKit

class GameSettings {
    static let shared = GameSettings()
    
    private let soundKey = "soundEffectsEnabled"
    private let vibrationKey = "vibrationsEnabled"
    private let musicKey = "musicEffectsEnabled"
    private let defaults = UserDefaults.standard
    
    var isSoundEnabled: Bool {
        get { defaults.bool(forKey: soundKey) }
        set {
            defaults.set(newValue, forKey: soundKey)
            NotificationCenter.default.post(name: .soundSettingChanged, object: nil)
        }
    }
    
    var isMusicEnabled: Bool {
        get { defaults.bool(forKey: musicKey) }
        set {
            defaults.set(newValue, forKey: musicKey)
            NotificationCenter.default.post(name: .musicSettingChanged, object: nil)
        }
    }
    
    var isVibrationEnabled: Bool {
        get { defaults.bool(forKey: vibrationKey) }
        set {
            defaults.set(newValue, forKey: vibrationKey)
            NotificationCenter.default.post(name: .vibrationSettingChanged, object: nil)
        }
    }
    
    private init() {
        if !defaults.hasKey(soundKey) {
            defaults.set(true, forKey: soundKey)
        }
        
        if !defaults.hasKey(vibrationKey) {
            defaults.set(true, forKey: vibrationKey)
        }
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let soundSettingChanged = Notification.Name("soundSettingChanged")
    static let vibrationSettingChanged = Notification.Name("vibrationSettingChanged")
    static let musicSettingChanged = Notification.Name("musicSettingChanged")
}

// MARK: - UserDefaults Extension
extension UserDefaults {
    func hasKey(_ key: String) -> Bool {
        return object(forKey: key) != nil
    }
}
