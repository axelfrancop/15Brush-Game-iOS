import SpriteKit
import SwiftUI

class GameScene: SKScene {
    private var gameManager: GameManager?
    private var cardNodes: [String: CardNode] = [:]
    private var selectedCards: [CardNode] = []
    private var selectedHandCard: CardNode?

    private let cardSize = CGSize(width: 60, height: 90)
    private let spacing: CGFloat = 20

    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        setupGame()
        drawGame()
    }

    private func setupGame() {
        gameManager = GameManager.shared

        let players = [
            Player(id: "human", name: "Você"),
            Player(id: "ai", name: "IA", isAI: true)
        ]

        gameManager?.initializeNewGame(mode: .singlePlayer, players: players)
    }

    private func drawGame() {
        guard let gameState = gameManager?.gameState else { return }

        // Limpar nós antigos
        removeAllChildren()
        cardNodes.removeAll()
        selectedCards.removeAll()

        // Desenhar título
        let title = SKLabelNode(fontNamed: "Arial")
        title.text = "15 Brush Cards"
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: frame.midX, y: frame.maxY - 40)
        addChild(title)

        // Desenhar cartas na mesa (table cards)
        drawTableCards(gameState.tableCards)

        // Desenhar cartas na mão do jogador
        if !gameState.players.isEmpty {
            drawPlayerHand(gameState.players[0].hand)
        }

        // Desenhar status
        drawGameStatus(gameState)
    }

    private func drawTableCards(_ cards: [Card]) {
        let startX = frame.midX - CGFloat(cards.count - 1) * (cardSize.width + spacing) / 2
        let startY = frame.midY + 80

        for (index, card) in cards.enumerated() {
            let position = CGPoint(
                x: startX + CGFloat(index) * (cardSize.width + spacing),
                y: startY
            )

            let cardNode = CardNode(card: card, size: cardSize)
            cardNode.position = position
            cardNode.zPosition = 10
            addChild(cardNode)
            cardNodes[card.id] = cardNode
        }
    }

    private func drawPlayerHand(_ cards: [Card]) {
        let startX = frame.midX - CGFloat(cards.count - 1) * (cardSize.width + spacing) / 2
        let startY = frame.minY + 60

        for (index, card) in cards.enumerated() {
            let position = CGPoint(
                x: startX + CGFloat(index) * (cardSize.width + spacing),
                y: startY
            )

            let cardNode = CardNode(card: card, size: cardSize)
            cardNode.position = position
            cardNode.zPosition = 5
            cardNode.name = "hand_\(card.id)"
            addChild(cardNode)
            cardNodes[card.id] = cardNode
        }
    }

    private func drawGameStatus(_ gameState: GameState) {
        let status = SKLabelNode(fontNamed: "Arial")
        status.fontSize = 16
        status.fontColor = .white
        status.text = "Cartas: Mesa(\(gameState.tableCards.count)) Baralho(\(gameState.deck.count))"
        status.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
        addChild(status)

        let playerLabel = SKLabelNode(fontNamed: "Arial")
        playerLabel.fontSize = 14
        playerLabel.fontColor = .yellow
        playerLabel.text = "Seu turno - Clique em uma carta da mão"
        playerLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        addChild(playerLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if let cardNode = node as? CardNode {
                handleCardTap(cardNode)
            }
        }
    }

    private func handleCardTap(_ cardNode: CardNode) {
        let isHandCard = cardNode.name?.starts(with: "hand_") ?? false

        if isHandCard {
            // Selecionou carta da mão
            if selectedHandCard != nil {
                selectedHandCard?.deselect()
            }
            selectedHandCard = cardNode
            cardNode.select()
        } else {
            // Selecionou carta da mesa
            if selectedCards.contains(cardNode) {
                selectedCards.removeAll { $0 == cardNode }
                cardNode.deselect()
            } else {
                selectedCards.append(cardNode)
                cardNode.select()
            }

            // Validar se soma 15
            if let handCard = selectedHandCard {
                checkMove(handCard: handCard.card, tableCards: selectedCards.map { $0.card })
            }
        }
    }

    private func checkMove(handCard: Card, tableCards: [Card]) {
        let isValid = GameLogicManager.shared.isValidMove(
            playerCard: handCard,
            tableCards: tableCards,
            selectedTableCards: tableCards
        )

        if isValid {
            executeMove(handCard: handCard, tableCards: tableCards)
        }
    }

    private func executeMove(handCard: Card, tableCards: [Card]) {
        // Animar coleta de cartas
        for card in (tableCards + [handCard]) {
            if let cardNode = cardNodes[card.id] {
                cardNode.animateCollection()
            }
        }

        // Aguardar animação
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.gameManager?.executePlayerMove(handCard: handCard, tableCards: tableCards)
            self?.gameManager?.skipTurn()

            // Redesenhar após delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.drawGame()
            }
        }
    }
}

struct GameSceneView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let view = SKView()
        let scene = GameScene(size: CGSize(width: 400, height: 800))
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
