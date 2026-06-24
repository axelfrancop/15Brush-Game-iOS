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
        let scaleAction = SKAction.scale(to: 1.15, duration: 0.15)
        scaleAction.timingMode = .easeOut
        run(scaleAction)

        let fadeAction = SKAction.fadeAlpha(to: 0.75, duration: 0.15)
        fadeAction.timingMode = .easeOut
        run(fadeAction)
    }

    func deselect() {
        isSelected = false
        let scaleAction = SKAction.scale(to: 1.0, duration: 0.15)
        scaleAction.timingMode = .easeOut
        run(scaleAction)

        let fadeAction = SKAction.fadeAlpha(to: 1.0, duration: 0.15)
        fadeAction.timingMode = .easeOut
        run(fadeAction)
    }

    func animateCollection() {
        let scaleAction = SKAction.scale(to: 0.3, duration: 0.3)
        scaleAction.timingMode = .easeIn

        let fadeAction = SKAction.fadeOut(withDuration: 0.3)
        fadeAction.timingMode = .easeIn

        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.3)
        moveUp.timingMode = .easeOut

        let group = SKAction.group([scaleAction, fadeAction, moveUp])
        run(group) { [weak self] in
            self?.removeFromParent()
        }
    }

    func animateFlip(duration: TimeInterval = 0.4) {
        let scaleX1 = SKAction.scaleX(to: 0.1, duration: duration / 2)
        scaleX1.timingMode = .easeInEaseOut

        let scaleX2 = SKAction.scaleX(to: 1.0, duration: duration / 2)
        scaleX2.timingMode = .easeInEaseOut

        let sequence = SKAction.sequence([scaleX1, scaleX2])
        run(sequence)
    }

    func animateMoveTo(_ position: CGPoint, duration: TimeInterval = 0.3) {
        let moveAction = SKAction.move(to: position, duration: duration)
        moveAction.timingMode = .easeInEaseOut
        run(moveAction)
    }

    func animateDeal(from startPosition: CGPoint, duration: TimeInterval = 0.4) {
        position = startPosition
        alpha = 0
        setScale(0.5)

        let moveAction = SKAction.move(to: position, duration: duration)
        moveAction.timingMode = .easeOut

        let fadeAction = SKAction.fadeIn(withDuration: duration)
        fadeAction.timingMode = .easeOut

        let scaleAction = SKAction.scale(to: 1.0, duration: duration)
        scaleAction.timingMode = .easeOut

        let group = SKAction.group([moveAction, fadeAction, scaleAction])
        run(group)
    }

    func animateBounce() {
        let bounceUp = SKAction.moveBy(x: 0, y: 10, duration: 0.1)
        bounceUp.timingMode = .easeOut

        let bounceDown = SKAction.moveBy(x: 0, y: -10, duration: 0.1)
        bounceDown.timingMode = .easeIn

        let sequence = SKAction.sequence([bounceUp, bounceDown])
        run(sequence)
    }
}
