import SpriteKit

class CardNode: SKSpriteNode {
    let card: Card
    var isSelected = false

    init(card: Card, size: CGSize) {
        self.card = card
        super.init(texture: nil, color: .white, size: size)

        self.name = card.id
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false

        setupCardAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCardAppearance() {
        color = .white
        strokeColor = .black
        lineWidth = 2

        let label = SKLabelNode(fontNamed: "Arial")
        label.text = card.displayName
        label.fontSize = 24
        label.fontColor = .black
        label.position = CGPoint(x: 0, y: 0)
        label.zPosition = 1

        addChild(label)
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

    func moveToPosition(_ position: CGPoint, duration: TimeInterval = 0.3) {
        let moveAction = SKAction.move(to: position, duration: duration)
        moveAction.timingMode = .easeInEaseOut
        run(moveAction)
    }

    func animateCollection() {
        let scaleAction = SKAction.scale(to: 0.5, duration: 0.2)
        let fadeAction = SKAction.fadeOut(withDuration: 0.2)
        let group = SKAction.group([scaleAction, fadeAction])
        run(group) {
            self.removeFromParent()
        }
    }
}
