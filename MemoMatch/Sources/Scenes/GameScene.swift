import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var boardDifficulty: GameConfiguration.BoardDifficulty = .easy {
        didSet {
            restartGame()
        }
    }
    
    // MARK: - Properties
    weak var viewController: UIViewController?
    private var cardNodes: [CardNode] = []
    private var cards: [SKSpriteNode] = []
    private var firstSelectedCard: CardNode?
    private var secondSelectedCard: CardNode?
    private var canFlipCards = true
    private var flippedCards: [SKSpriteNode] = []
    private var cardValues: [Int] = []
    var soundManager: SoundManager!
    
    private var timeElapsed: TimeInterval = 0
    private var timerLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var matchesFound = 0
    private var movesDone = 0
    var timer: Timer?
    
    private var pauseButton: SKSpriteNode!
    private var backButton: SKSpriteNode!
    private var resetButton: SKSpriteNode!
    private var settingsButton: SKSpriteNode!
    
    // Card grid configuration
    private let cardSize = CGSize(width: 60, height: 60)
    private let spacing: CGFloat = 20
    
    var cardTypes = ["card1", "card2", "card3", "card4", "card5", "card6", "card7", "card8", "card9", "card10"]
    
    // Theme colors
    private let headerColor = UIColor(red: 0.6, green: 0.1, blue: 0.1, alpha: 1.0)
    
    // MARK: - Lifecycle Methods
    override func didMove(to view: SKView) {
        setupBackground()
        setupHeader()
        setupControls()
        setupGame(columns: boardDifficulty.columns, rows: boardDifficulty.rows)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        for card in cardNodes where card.contains(location) {
            handleCardTap(card)
        }
        
        if pauseButton.contains(location) {
            handlePauseButtonTap()
        } else if backButton.contains(location) {
            handleBackButtonTap()
        } else if resetButton.contains(location) {
            handleResetButtonTap()
        } else if settingsButton.contains(location) {
            handleSettingsButtonTap()
        }
    }
    
    func preloadSoundEffects(_ names: [String]) {
        names.forEach { name in
            if Bundle.main.path(forResource: name, ofType: nil) != nil {
                let soundAction = SKAction.playSoundFileNamed(name, waitForCompletion: false)
                soundManager.soundActions[name] = soundAction
                print("Preloaded: \(name)")
            } else {
                print("Missing: \(name)")
            }
        }
    }
    
    // MARK: - Setup Methods
    private func setupBackground() {
        let backgroundImage = SKSpriteNode(imageNamed: "BG_2")
        backgroundImage.size = self.size
        backgroundImage.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        backgroundImage.zPosition = -0.9
        backgroundImage.alpha = 0.3
        addChild(backgroundImage)
    }
    
    private func setupHeader() {
        // Header background
        let headerBackground = SKSpriteNode(color: headerColor, size: CGSize(width: self.size.width - 20, height: 60))
        headerBackground.position = CGPoint(x: self.size.width / 2, y: self.size.height - 90)
        headerBackground.zPosition = 1
        addChild(headerBackground)
        
        // Add border to header
        headerBackground.addGoldenBorder()
        
        // Settings button
        settingsButton = SKSpriteNode(imageNamed: "settings")
        settingsButton.size = CGSize(width: 40, height: 40)
        settingsButton.position = CGPoint(x: 40, y: self.size.height - 30)
        settingsButton.zPosition = 1
        addChild(settingsButton)
        
        // Score label
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "MOVES: 0"
        scoreLabel.fontSize = 22
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: self.size.width / 4, y: self.size.height - 100)
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        
        // Timer label
        timerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        timerLabel.text = "TIME: 00:00"
        timerLabel.fontSize = 22
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: 3 * self.size.width / 4, y: self.size.height - 100)
        timerLabel.zPosition = 1
        addChild(timerLabel)
    }
    
    func setupGame(columns: Int, rows: Int) {
        // Clear previous game
        cardNodes.forEach { $0.removeFromParent() }
        cardNodes.removeAll()
        cardValues.removeAll()
        flippedCards.removeAll()
        matchesFound = 0
        movesDone = 0
        timeElapsed = 0
        canFlipCards = true
        
        // Update UI
        scoreLabel.text = "MOVES: 0"
        timerLabel.text = "TIME: 00:00"
        
        // Create new board
        createBoard()
        startTimer()
    }
    
    private func createBoard() {
        let totalPairs = boardDifficulty.columns * boardDifficulty.rows / 2
        var cardTypesToUse: [String] = []
        
        // Create pairs
        for i in 0..<totalPairs {
            let typeIndex = i % cardTypes.count
            cardTypesToUse.append(contentsOf: [cardTypes[typeIndex], cardTypes[typeIndex]])
        }
        
        // Shuffle
        cardTypesToUse = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: cardTypesToUse) as! [String]
        
        // Calculate positions
        let totalWidth = CGFloat(boardDifficulty.columns) * (cardSize.width + spacing)
        let totalHeight = CGFloat(boardDifficulty.rows) * (cardSize.height + spacing)
        let startX = (size.width - totalWidth) / 2 + cardSize.width/2
        let startY = (size.height + totalHeight) / 2 - cardSize.height/2 - 50 // Adjust for header
        
        // Create cards
        for row in 0..<boardDifficulty.rows {
            for col in 0..<boardDifficulty.columns {
                let index = row * boardDifficulty.columns + col
                guard index < cardTypesToUse.count else { continue }
                
                let card = CardNode(type: cardTypesToUse[index], size: cardSize)
                card.position = CGPoint(
                    x: startX + CGFloat(col) * (cardSize.width + spacing),
                    y: startY - CGFloat(row) * (cardSize.height + spacing)
                )
                card.zPosition = 1
                addChild(card)
                cardNodes.append(card)
            }
        }
    }
    
    private func setupControls() {
        let controlsY = cardSize.height / 2 + 40
        
        // Pause button
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.size = CGSize(width: 50, height: 50)
        pauseButton.position = CGPoint(x: self.size.width / 4 - 30, y: controlsY - 45)
        pauseButton.zPosition = 2
        addChild(pauseButton)
        
        // Back button
        backButton = SKSpriteNode(imageNamed: "back")
        backButton.size = CGSize(width: 50, height: 50)
        backButton.position = CGPoint(x: self.size.width / 2, y: controlsY - 45)
        backButton.zPosition = 2
        addChild(backButton)
        
        // Reset button
        resetButton = SKSpriteNode(imageNamed: "redo")
        resetButton.size = CGSize(width: 50, height: 50)
        resetButton.position = CGPoint(x: 3 * self.size.width / 4 + 30, y: controlsY - 45)
        resetButton.zPosition = 2
        addChild(resetButton)
    }
    
    // MARK: - Game Logic
    private func handleCardTap(_ card: CardNode) {
        
        guard canFlipCards, !card.isFaceUp else { return }
        
        card.flip()
        
        if firstSelectedCard == nil {
            firstSelectedCard = card
            SoundManager.shared.playSoundEffect(named: "flipSound.wav")
        } else {
            secondSelectedCard = card
            canFlipCards = false
            SoundManager.shared.playSoundEffect(named: "flipSound.wav")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.checkForMatch()
            }
        }
    }
    
    private func checkForMatch() {
        guard let firstCard = firstSelectedCard, let secondCard = secondSelectedCard else { return }
        
        if firstCard.cardType == secondCard.cardType {
            // Match found
            SoundManager.shared.playSoundEffect(named: "matchSound.wav")
            matchesFound += 1
            movesDone += 1
            scoreLabel.text = "MOVES: \(movesDone)"
            
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            let fadeAlpha = SKAction.fadeAlpha(to: 0.7, duration: 0.2)
            let sequence = SKAction.sequence([scaleUp, scaleDown, fadeAlpha])
            
            firstCard.run(sequence)
            secondCard.run(sequence)
            
            if matchesFound == cardNodes.count / 2 {
                gameComplete()
            }
        } else {
            // No match
            SoundManager.shared.playSoundEffect(named: "noMatchSound.wav")
            firstCard.flip()
            secondCard.flip()
            movesDone += 1
            scoreLabel.text = "MOVES: \(movesDone)"
        }
        
        firstSelectedCard = nil
        secondSelectedCard = nil
        canFlipCards = true
    }
    
    private func gameComplete() {
        SoundManager.shared.stopBackgroundMusic()
        SoundManager.shared.playSoundEffect(named: "winSound.wav")
        timer?.invalidate()
        
        let winOverlay = WinOverlay(size: self.size)
        winOverlay.zPosition = 20
        winOverlay.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        winOverlay.movesLabel.text = "MOVES: \(movesDone)"
        winOverlay.timerLabel.text = "Time elapsed: \(formatTime(timeElapsed))"
        addChild(winOverlay)
        
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Control Button Handlers
    private func handlePauseButtonTap() {
        if isPaused {
            // Resume game
            isPaused = false
            canFlipCards = true
            startTimer()
            childNode(withName: "pauseOverlay")?.removeFromParent()
        } else {
            // Pause game
            isPaused = true
            timer?.invalidate()
            canFlipCards = false
            
            let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: self.size)
            overlay.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            overlay.zPosition = 10
            overlay.name = "pauseOverlay"
            
            let pauseLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
            pauseLabel.text = "PAUSED"
            pauseLabel.fontSize = 40
            pauseLabel.fontColor = .white
            pauseLabel.position = CGPoint(x: 0, y: 0)
            overlay.addChild(pauseLabel)
            
            addChild(overlay)
        }
    }
    
    private func handleBackButtonTap() {
        timer?.invalidate()
        let transition = SKTransition.fade(withDuration: 0.5)
        let menuScene = MenuScene(size: self.size)
        self.view?.presentScene(menuScene, transition: transition)
    }
    
    func handleResetButtonTap() {
        timer?.invalidate()
        restartGame()
    }
    
    private func handleSettingsButtonTap() {
        let settingsOverlay = SettingsOverlay(size: self.size, scene: self)
        settingsOverlay.zPosition = 20
        settingsOverlay.position = CGPoint(x: self.size.width / 1000, y: self.size.height / 2000)
        settingsOverlay.onDifficultyChanged = { [weak self] newDifficulty in
            self?.boardDifficulty = newDifficulty
        }
        addChild(settingsOverlay)
    }
    
    // MARK: - Timer Methods
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeElapsed += 1
            self.updateTimerDisplay()
        }
    }
    
    private func updateTimerDisplay() {
        timerLabel.text = "TIME: \(formatTime(timeElapsed))"
    }
    
    func restartGame() {
        timer?.invalidate()
        setupGame(columns: boardDifficulty.columns, rows: boardDifficulty.rows)
    }
}
