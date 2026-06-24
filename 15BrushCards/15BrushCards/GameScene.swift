import SpriteKit

class GameScene: SKScene {
    private var cardNodes: [CardNode] = []
    private var selectedCards: [CardNode] = []
    private var selectedHandCard: CardNode?

    private var tableCardValues: [String] = ["4", "2", "9", "6"]
    private var handCardValues: [String] = ["7", "8", "9"]
    private var messageLabel: SKLabelNode?

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
        selectedHandCard = nil

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
        let startX = frame.midX - CGFloat(handCardValues.count - 1) * (cardSize.width + spacing) / 2
        let startY = frame.minY + 100

        for (index, value) in handCardValues.enumerated() {
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
        status.text = "Mesa: \(tableCardValues.count) cartas | Baralho: 32 cartas"
        status.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
        status.zPosition = 1
        addChild(status)

        messageLabel = SKLabelNode(fontNamed: "Arial")
        messageLabel?.fontSize = 12
        messageLabel?.fontColor = .yellow
        messageLabel?.text = "Selecione uma carta da mão"
        messageLabel?.position = CGPoint(x: frame.midX, y: frame.maxY - 105)
        messageLabel?.zPosition = 1
        if let label = messageLabel { addChild(label) }
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
            updateMessage("Agora clique nas cartas da mesa")
        } else {
            if selectedCards.contains(cardNode) {
                selectedCards.removeAll { $0 == cardNode }
                cardNode.deselect()
            } else {
                selectedCards.append(cardNode)
                cardNode.select()
            }

            if let handCard = selectedHandCard {
                checkMove(handCard: handCard, tableCards: selectedCards)
            }
        }
    }

    private func checkMove(handCard: CardNode, tableCards: [CardNode]) {
        guard let handValue = Int(handCard.cardDisplay),
              !tableCards.isEmpty else { return }

        let tableSum = tableCards.reduce(0) { sum, card in
            sum + (Int(card.cardDisplay) ?? 0)
        }

        let totalSum = handValue + tableSum

        if totalSum == 15 {
            updateMessage("✅ 15 Pontos! Excelente!")
            executeMove(handCard: handCard, tableCards: tableCards)
        } else {
            updateMessage("❌ Soma = \(totalSum). Tente novamente!")
        }
    }

    private func executeMove(handCard: CardNode, tableCards: [CardNode]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            handCard.animateCollection()
            for card in tableCards {
                card.animateCollection()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.applyMove(handCard: handCard, tableCards: tableCards)
            }
        }
    }

    private func applyMove(handCard: CardNode, tableCards: [CardNode]) {
        guard let handIndex = handCardValues.firstIndex(of: handCard.cardDisplay) else { return }

        handCardValues.remove(at: handIndex)

        for tableCard in tableCards {
            if let index = tableCardValues.firstIndex(of: tableCard.cardDisplay) {
                tableCardValues.remove(at: index)
            }
        }

        tableCardValues.append("3")
        if tableCardValues.count < 4, !handCardValues.isEmpty {
            tableCardValues.append("5")
        }

        selectedHandCard = nil
        selectedCards.removeAll()
        updateMessage("Sua vez! Selecione uma carta")
        drawGame()
    }

    private func updateMessage(_ text: String) {
        messageLabel?.text = text
    }
}
