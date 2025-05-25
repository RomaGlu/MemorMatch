import SpriteKit

class SettingsOverlay: SKNode {
    
    // MARK: - Properties
    private var background: SKSpriteNode!
    private var closeButton: SKSpriteNode!
    weak var gameScene: GameScene?
    var onDifficultyChanged: ((GameConfiguration.BoardDifficulty) -> Void)?
    
    // MARK: - Initialization
    init(size: CGSize, scene: GameScene) {
        super.init()
        self.gameScene = scene
        self.zPosition = 1000
        setupOverlay(size: size)
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupOverlay(size: CGSize) {
        background = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: size)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = 0
        addChild(background)
        
        // Settings panel
        let panel = SKSpriteNode(color: UIColor(red: 0.6, green: 0.1, blue: 0.1, alpha: 1.0),
                        size: CGSize(width: 300, height: 400))
        panel.position = CGPoint(x: size.width/2, y: size.height/2)
        panel.zPosition = 1
        panel.addGoldenBorder()
        addChild(panel)
        
        // Settings title
        let title = SKLabelNode(text: "SETTINGS")
        title.fontName = "AvenirNext-Bold"
        title.fontSize = 30
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 150)
        title.zPosition = 2
        panel.addChild(title)
        
        // Close button
        closeButton = SKSpriteNode(imageNamed: "close")
        closeButton.name = "closeSettings"
        closeButton.size = CGSize(width: 30, height: 30)
        closeButton.position = CGPoint(x: 120, y: 150)
        closeButton.zPosition = 2
        panel.addChild(closeButton)
        
        // Add settings options
        setupSettingsOptions(panel: panel)
    }
    
    private func setupSettingsOptions(panel: SKSpriteNode) {
        // Sound toggle
        let soundLabel = SKLabelNode(text: "Sound Effects")
        soundLabel.fontName = "AvenirNext-Regular"
        soundLabel.fontSize = 20
        soundLabel.fontColor = .white
        soundLabel.horizontalAlignmentMode = .left
        soundLabel.position = CGPoint(x: -120, y: 80)
        panel.addChild(soundLabel)
        
        let soundToggle = ToggleSwitch(isOn: GameConfiguration.shared.soundEnabled, type: .sound, position: CGPoint(x: 80, y: 80))
        soundToggle.zPosition = 2
        soundToggle.onToggle = { isOn in
            GameConfiguration.shared.soundEnabled = isOn
        }
        panel.addChild(soundToggle)
        
        // Vibration toggle
        let vibrationLabel = SKLabelNode(text: "Vibration")
        vibrationLabel.fontName = "AvenirNext-Regular"
        vibrationLabel.fontSize = 20
        vibrationLabel.fontColor = .white
        vibrationLabel.horizontalAlignmentMode = .left
        vibrationLabel.position = CGPoint(x: -120, y: 30)
        panel.addChild(vibrationLabel)
        
        let vibrationToggle = ToggleSwitch(isOn: GameConfiguration.shared.vibrationEnabled, type: .vibration, position: CGPoint(x: 80, y: 30))
        vibrationToggle.zPosition = 2
        vibrationToggle.onToggle = { isOn in
            GameConfiguration.shared.vibrationEnabled = isOn
        }
        panel.addChild(vibrationToggle)
        
        // Music toggle
        let musicLabel = SKLabelNode(text: "Music")
        musicLabel.fontName = "AvenirNext-Regular"
        musicLabel.fontSize = 20
        musicLabel.fontColor = .white
        musicLabel.horizontalAlignmentMode = .left
        musicLabel.position = CGPoint(x: -120, y: -20)
        panel.addChild(musicLabel)
        
        let musicToggle = ToggleSwitch(isOn: GameConfiguration.shared.musicEnabled, type: .music, position: CGPoint(x: 80, y: -20))
        musicToggle.zPosition = 2
        musicToggle.onToggle = { isOn in
            GameConfiguration.shared.musicEnabled = isOn
            if !isOn {
                SoundManager.shared.stopBackgroundMusic()
            } else {
                SoundManager.shared.playBackgroundMusic(named: "backgroundMusic.mp3")
            }
        }
        panel.addChild(musicToggle)
        
        // Difficulty selector
        let difficultyLabel = SKLabelNode(text: "Difficulty")
        difficultyLabel.fontName = "AvenirNext-Regular"
        difficultyLabel.fontSize = 20
        difficultyLabel.fontColor = .white
        difficultyLabel.horizontalAlignmentMode = .left
        difficultyLabel.position = CGPoint(x: -120, y: -60)
        panel.addChild(difficultyLabel)
        
        // Difficulty buttons
        let easyButton = createDifficultyButton(
            text: "Easy",
            isSelected: GameConfiguration.shared.currentBoardDifficulty == .easy,
            difficulty: .easy
        )
        easyButton.position = CGPoint(x: -80, y: -100)
        panel.addChild(easyButton)
        
        let mediumButton = createDifficultyButton(
            text: "Medium",
            isSelected: GameConfiguration.shared.currentBoardDifficulty == .medium,
            difficulty: .medium
        )
        mediumButton.position = CGPoint(x: 0, y: -100)
        panel.addChild(mediumButton)
        
        let hardButton = createDifficultyButton(
            text: "Hard",
            isSelected: GameConfiguration.shared.currentBoardDifficulty == .hard,
            difficulty: .hard
        )
        hardButton.position = CGPoint(x: 80, y: -100)
        panel.addChild(hardButton)
    }
    
    private func createDifficultyButton(text: String, isSelected: Bool, difficulty: GameConfiguration.BoardDifficulty) -> SKNode {
        let button = SKSpriteNode(color: isSelected ? .orange : .darkGray, size: CGSize(width: 80, height: 35))
        button.name = "difficulty_\(difficulty.rawValue)"
        
        let label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Regular"
        label.fontSize = 16
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        button.addChild(label)
        
        return button
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "closeSettings" {
                removeFromParent()
                return
            }
            
            if let name = node.name, name.hasPrefix("difficulty_") {
                let rawValue = name.replacingOccurrences(of: "difficulty_", with: "")
                if let difficulty = GameConfiguration.BoardDifficulty(rawValue: rawValue) {
                    for child in children {
                        if let panel = child as? SKSpriteNode, panel.name == nil {
                            for button in panel.children {
                                if let button = button as? SKSpriteNode, button.name?.hasPrefix("difficulty_") == true {
                                    button.color = (button.name == name) ? .orange : .darkGray
                                }
                            }
                        }
                    }
                    GameConfiguration.shared.currentBoardDifficulty = difficulty
                    onDifficultyChanged?(difficulty)
                }
            }
        }
    }
}
