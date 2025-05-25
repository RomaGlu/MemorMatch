//
//  SoundManager.swift
//  MemoMatch
//
//  Created by Роман Глухарев on 24.05.25.
//

import AVFoundation
import SpriteKit

class SoundManager {
    static let shared = SoundManager()
    
    private init() {
        configureAudioSession()
    }
    
    var soundActions: [String: SKAction] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundsPlayer: AVAudioPlayer?
    
    // MARK: - Audio Setup
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    // MARK: - Sound Effects
    func preloadSoundEffects(_ names: [String]) {
        for name in names {
            if Bundle.main.path(forResource: name, ofType: nil) != nil {
                let soundAction = SKAction.playSoundFileNamed(name, waitForCompletion: false)
                soundActions[name] = soundAction
            }
        }
    }
    
    func playSoundEffect(named name: String) {
        guard GameConfiguration.shared.soundEnabled else { return }
        
        // First verify file exists
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else { return }
        
        do {
            let url = URL(fileURLWithPath: path)
            soundsPlayer = try AVAudioPlayer(contentsOf: url)
            soundsPlayer?.numberOfLoops = 0
            soundsPlayer?.volume = 0.3
            soundsPlayer?.prepareToPlay()
            soundsPlayer?.play()
        } catch {
        }
    }
    
    // MARK: - Background Music
    func playBackgroundMusic(named name: String) {
        guard GameConfiguration.shared.soundEnabled else { return }
        
        // First verify file exists
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else { return }
        
        stopBackgroundMusic()
        
        do {
            let url = URL(fileURLWithPath: path)
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Infinite loop
            backgroundMusicPlayer?.volume = 0.1
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch {
            print("Failed to play background music: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
}

// MARK: - Scene Extension
extension SKScene {
    static var current: SKScene? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let skView = window.rootViewController?.view as? SKView else {
            return nil
        }
        return skView.scene
    }
}
