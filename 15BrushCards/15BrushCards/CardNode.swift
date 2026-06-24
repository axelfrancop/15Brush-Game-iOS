import SpriteKit

class CardNode: SKNode {
    let cardId: String
    let cardDisplay: String
    var isSelected = false
    var cardSize: CGSize
    private let cardShape: SKShapeNode

    init(cardId: String, display: String, size: CGSize) {
        self.cardId = cardId
        self.cardDisplay = display
        self.cardSize = size
        self.cardShape = SKShapeNode(rectOf: size, cornerRadius: 8)
        super.init()

        name = cardId
        zPosition = 5

        cardShape.fillColor = .white
        cardShape.strokeColor = .black
        cardShape.lineWidth = 1
        cardShape.zPosition = 5
        addChild(cardShape)

        let label = SKLabelNode(fontNamed: "Arial")
        label.text = display
        label.fontSize = 20
        label.fontColor = .black
        label.position = CGPoint(x: 0, y: 0)
        label.zPosition = 10
        addChild(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var color: SKColor {
        get { cardShape.fillColor }
        set { cardShape.fillColor = newValue }
    }

    func select() {
        isSelected = true
        alpha = 0.7
        setScale(1.1)
    }

    func deselect() {
        isSelected = false
        alpha = 1.0
        setScale(1.0)
    }

    func animateCollection() {
        let scaleAction = SKAction.scale(to: 0.5, duration: 0.2)
        let fadeAction = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleAction, fadeAction])
        run(group) { [weak self] in
            self?.removeFromParent()
        }
    }
}
