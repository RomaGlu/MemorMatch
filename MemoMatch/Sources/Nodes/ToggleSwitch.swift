import SpriteKit

class ToggleSwitch: SKNode {
    enum ToggleType {
        case sound
        case vibration
        case music
        
        var title: String {
            switch self {
            case .sound: return "Sound"
            case .vibration: return "Vibration"
            case .music: return "Music"
            }
        }
    }
    
    private let background = SKShapeNode()
    private let thumb = SKShapeNode()
    private var isOn: Bool
    private let type: ToggleType
    private let width: CGFloat = 60
    private let height: CGFloat = 30
    private let padding: CGFloat = 3
    
    var onToggle: ((Bool) -> Void)?
    
    init(isOn: Bool, type: ToggleType, position: CGPoint) {
        self.isOn = isOn
        self.type = type
        super.init()
        self.position = position
        setupUI()
        updateVisuals()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        isUserInteractionEnabled = true
        
        // Background
        background.path = CGPath(roundedRect: CGRect(x: -width/2, y: -height/2, width: width, height: height),
                                cornerWidth: height/2, cornerHeight: height/2, transform: nil)
        background.lineWidth = 2
        background.strokeColor = .white
        addChild(background)
        
        // Thumb
        thumb.path = CGPath(ellipseIn: CGRect(x: -height/2 + padding, y: -height/2 + padding,
                                           width: height - 2*padding, height: height - 2*padding), transform: nil)
        thumb.lineWidth = 0
        thumb.fillColor = .white
        addChild(thumb)
    }
    
    private func updateVisuals() {
        let backgroundOnColor = SKColor(red: 0.29, green: 0.85, blue: 0.39, alpha: 1.0)
        let backgroundOffColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        background.fillColor = isOn ? backgroundOnColor : backgroundOffColor
        
        let thumbDestination = isOn ? width/2 - height/2 : -width/2 + height/2
        let moveAction = SKAction.moveTo(x: thumbDestination, duration: 0.2)
        moveAction.timingMode = .easeOut
        thumb.run(moveAction)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        run(scaleDown)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        run(scaleUp)
        toggle()
    }
    
    func toggle() {
        isOn.toggle()
        updateVisuals()
        onToggle?(isOn)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
