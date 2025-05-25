//
//  BoardSize.swift
//  MemoMatch
//
//  Created by Роман Глухарев on 22.05.25.
//

import Foundation

class GameConfiguration {
    static let shared = GameConfiguration()
    
    enum BoardDifficulty: String, CaseIterable {
            case easy // 4x4 (16 cards)
            case medium // 5x4 (20 cards)
            case hard // 6x4 (24 cards)
            
            var rows: Int {
                switch self {
                case .easy: return 4
                case .medium: return 5
                case .hard: return 6
                }
            }
            
            var columns: Int {
                return 4
            }
            
            var cardSize: CGSize {
                switch self {
                case .easy: return CGSize(width: 80, height: 120)
                case .medium: return CGSize(width: 65, height: 100)
                case .hard: return CGSize(width: 50, height: 800)
                }
            }
        }
    
    var currentBoardDifficulty: BoardDifficulty = .easy
    var soundEnabled = true
    var vibrationEnabled = true
    var musicEnabled = true
}

