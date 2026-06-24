import SpriteKit

class GameScene: SKScene {
    private var cardNodes: [CardNode] = []
    private var selectedCards: [CardNode] = []
    private var selectedHandCard: CardNode?

    private let cardSize = CGSize(width: 60, height: 90)
    private let spacing: CGFloat = 20

    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        drawGame()
    }

    private func drawGame() {
        removeAllChildren()
        cardNodes.removeAll()
        selectedCards.removeAll()

        let title = SKLabelNode(fontNamed: "Arial")
        title.text = "15 Brush Cards"
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: frame.midX, y: frame.maxY - 40)
        addChild(title)

        drawTableCards()
        drawPlayerHand()
        drawGameStatus()
    }

    private func drawTableCards() {
        let tableCardValues = ["4", "2", "9", "6"]
        let startX = frame.midX - CGFloat(tableCardValues.count - 1) * (cardSize.width + spacing) / 2
        let startY = frame.midY + 80

        for (index, value) in tableCardValues.enumerated() {
            let position = CGPoint(
                x: startX + CGFloat(index) * (cardSize.width + spacing),
                y: startY
            )

            let cardNode = CardNode(cardId: "table_\(index)", display: value, size: cardSize)
            cardNode.position = position
            cardNode.zPosition = 10
            addChild(cardNode)
            cardNodes.append(cardNode)
        }
    }

    private func drawPlayerHand() {
        let handValues = ["7", "8", "9"]
        let startX = frame.midX - CGFloat(handValues.count - 1) * (cardSize.width + spacing) / 2
        let startY = frame.minY + 60

        for (index, value) in handValues.enumerated() {
            let position = CGPoint(
                x: startX + CGFloat(index) * (cardSize.width + spacing),
                y: startY
            )

            let cardNode = CardNode(cardId: "hand_\(index)", display: value, size: cardSize)
            cardNode.position = position
            cardNode.zPosition = 5
            cardNode.name = "hand_\(index)"
            addChild(cardNode)
            cardNodes.append(cardNode)
        }
    }

    private func drawGameStatus() {
        let status = SKLabelNode(fontNamed: "Arial")
        status.fontSize = 14
        status.fontColor = .white
        status.text = "Mesa: 4 cartas | Baralho: 32 cartas"
        status.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
        addChild(status)

        let hint = SKLabelNode(fontNamed: "Arial")
        hint.fontSize = 12
        hint.fontColor = .yellow
        hint.text = "Toque em uma carta da mão, depois na mesa (soma = 15)"
        hint.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        addChild(hint)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for cardNode in cardNodes {
            if cardNode.contains(location) {
                handleCardTap(cardNode)
                break
            }
        }
    }

    private func handleCardTap(_ cardNode: CardNode) {
        let isHandCard = cardNode.name?.starts(with: "hand_") ?? false

        if isHandCard {
            if selectedHandCard != nil {
                selectedHandCard?.deselect()
            }
            selectedHandCard = cardNode
            cardNode.select()
        } else {
            if selectedCards.contains(cardNode) {
                selectedCards.removeAll { $0 == cardNode }
                cardNode.deselect()
            } else {
                selectedCards.append(cardNode)
                cardNode.select()
            }
        }
    }
}
