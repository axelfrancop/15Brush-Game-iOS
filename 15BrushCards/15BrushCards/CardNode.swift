import SpriteKit

class CardNode: SKShapeNode {
    let cardId: String
    let cardDisplay: String
    var isSelected = false

    init(cardId: String, display: String, size: CGSize) {
        self.cardId = cardId
        self.cardDisplay = display

        super.init()

        let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        path = UIBezierPath(roundedRect: rect, cornerRadius: 8).cgPath
        fillColor = .white
        strokeColor = .black
        lineWidth = 2
        name = cardId

        let label = SKLabelNode(fontNamed: "Arial")
        label.text = display
        label.fontSize = 20
        label.fontColor = .black
        label.position = CGPoint(x: 0, y: 0)
        label.zPosition = 1
        addChild(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
