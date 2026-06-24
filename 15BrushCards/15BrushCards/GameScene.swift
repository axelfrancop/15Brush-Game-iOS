import SpriteKit
import Foundation

class GameScene: SKScene {
    var cardNodes: [CardNode] = []
    private var selectedCards: [CardNode] = []
    private var selectedHandCard: CardNode?
    var onGameOver: (() -> Void)?

    private var tableCardValues: [String] = ["4", "2", "9", "6"]
    private var playerHandValues: [String] = ["7", "8", "9"]
    private var aiHandValues: [String] = ["5", "6", "10"]

    private var playerScore = 0
    private var aiScore = 0

    private var isPlayerTurn = true
    private var isAnimating = false
    private var messageLabel: SKLabelNode?
    private var turnLabel: SKLabelNode?
    private var gameOverLabel: SKLabelNode?
    private var playButton: SKShapeNode?
    private var cancelButton: SKShapeNode?

    private let cardSize = CGSize(width: 60, height: 90)
    private let spacing: CGFloat = 20
    private var deckCards: [String] = Array(repeating: "card", count: 40)
    private var isGameOver = false
    private var lastMoveSum = 0

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
        drawAICards()
        drawGameStatus()
        updateTurnDisplay()

        if !isPlayerTurn && !isAnimating {
            scheduleAITurn()
        }
    }

    private func drawTableCards() {
        let startX = frame.midX - CGFloat(tableCardValues.count - 1) * (cardSize.width + spacing) / 2
        let startY = frame.midY

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
        let startX = frame.midX - CGFloat(playerHandValues.count - 1) * (cardSize.width + spacing) / 2
        let startY = frame.minY + 80

        for (index, value) in playerHandValues.enumerated() {
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

    private func drawAICards() {
        let startX = frame.midX - CGFloat(aiHandValues.count - 1) * (cardSize.width + spacing) / 2
        let startY = frame.maxY - 100

        for (index, _) in aiHandValues.enumerated() {
            let position = CGPoint(
                x: startX + CGFloat(index) * (cardSize.width + spacing),
                y: startY
            )

            let cardNode = CardNode(cardId: "ai_\(index)", display: "?", size: cardSize)
            cardNode.position = position
            cardNode.zPosition = 5
            cardNode.color = .blue
            addChild(cardNode)
        }

        let aiLabel = SKLabelNode(fontNamed: "Arial")
        aiLabel.text = "Cartas da IA"
        aiLabel.fontSize = 10
        aiLabel.fontColor = .blue
        aiLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 130)
        addChild(aiLabel)
    }

    private func drawGameStatus() {
        let status = SKLabelNode(fontNamed: "Arial")
        status.fontSize = 12
        status.fontColor = .white
        status.text = "Você: \(playerScore) | IA: \(aiScore) | Baralho: \(deckCards.count)"
        status.position = CGPoint(x: frame.midX, y: frame.midY - 150)
        status.zPosition = 1
        addChild(status)
    }

    private func drawActionButtons() {
        guard isPlayerTurn && selectedHandCard != nil else { return }

        playButton?.removeFromParent()
        cancelButton?.removeFromParent()

        let buttonWidth: CGFloat = 80
        let buttonHeight: CGFloat = 40

        playButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 8)
        playButton?.fillColor = .green
        playButton?.strokeColor = .white
        playButton?.lineWidth = 2
        playButton?.position = CGPoint(x: frame.midX - 60, y: frame.minY + 30)
        playButton?.zPosition = 50
        playButton?.name = "play_button"

        let playLabel = SKLabelNode(fontNamed: "Arial")
        playLabel.text = "JOGAR"
        playLabel.fontSize = 12
        playLabel.fontColor = .white
        playLabel.position = CGPoint(x: 0, y: -5)
        playLabel.zPosition = 51
        playButton?.addChild(playLabel)

        if let btn = playButton { addChild(btn) }

        cancelButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 8)
        cancelButton?.fillColor = .red
        cancelButton?.strokeColor = .darkGray
        cancelButton?.lineWidth = 2
        cancelButton?.position = CGPoint(x: frame.midX + 60, y: frame.minY + 30)
        cancelButton?.zPosition = 50
        cancelButton?.name = "cancel_button"

        let cancelLabel = SKLabelNode(fontNamed: "Arial")
        cancelLabel.text = "CANCELAR"
        cancelLabel.fontSize = 10
        cancelLabel.fontColor = .white
        cancelLabel.position = CGPoint(x: 0, y: -5)
        cancelLabel.zPosition = 51
        cancelButton?.addChild(cancelLabel)

        if let btn = cancelButton { addChild(btn) }
    }

    private func updateTurnDisplay() {
        turnLabel?.removeFromParent()

        turnLabel = SKLabelNode(fontNamed: "Arial")
        turnLabel?.fontSize = 14
        turnLabel?.fontColor = isPlayerTurn ? .green : .red
        turnLabel?.text = isPlayerTurn ? "SEU TURNO" : "TURNO DA IA"
        turnLabel?.position = CGPoint(x: frame.midX, y: frame.maxY - 70)
        turnLabel?.zPosition = 1

        if let label = turnLabel { addChild(label) }

        messageLabel?.removeFromParent()
        messageLabel = SKLabelNode(fontNamed: "Arial")
        messageLabel?.fontSize = 12
        messageLabel?.fontColor = .yellow
        messageLabel?.text = isPlayerTurn ? "Clique em uma carta" : "IA jogando..."
        messageLabel?.position = CGPoint(x: frame.midX, y: frame.maxY - 95)
        messageLabel?.zPosition = 1

        if let label = messageLabel { addChild(label) }
    }

    private func scheduleAITurn() {
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.executeAITurn()
        }
    }

    private func executeAITurn() {
        let validMoves = findValidMoves(for: aiHandValues, from: tableCardValues)

        if let move = validMoves.randomElement() {
            performAIMove(handCard: move.0, tableCards: move.1)
        } else {
            skipAITurn()
        }
    }

    private func findValidMoves(for hand: [String], from table: [String]) -> [(String, [String])] {
        var moves: [(String, [String])] = []

        for handCard in hand {
            guard let handVal = Int(handCard) else { continue }

            for tableCombo in getAllCombinations(from: table) {
                let tableSum = tableCombo.reduce(0) { $0 + (Int($1) ?? 0) }
                if handVal + tableSum == 15 {
                    moves.append((handCard, tableCombo))
                }
            }
        }

        return moves
    }

    private func getAllCombinations(from array: [String]) -> [[String]] {
        var result: [[String]] = [[]]
        for item in array {
            result.append(contentsOf: result.map { $0 + [item] })
        }
        return result.filter { !$0.isEmpty }
    }

    private func performAIMove(handCard: String, tableCards: [String]) {
        if let handIndex = aiHandValues.firstIndex(of: handCard) {
            aiHandValues.remove(at: handIndex)
        }

        for card in tableCards {
            if let index = tableCardValues.firstIndex(of: card) {
                tableCardValues.remove(at: index)
            }
        }

        aiScore += tableCards.count + 1
        replenishTable()

        isAnimating = false
        isPlayerTurn = true
        drawGame()
    }

    private func skipAITurn() {
        replenishTable()
        isAnimating = false
        isPlayerTurn = true
        drawGame()
    }

    private func replenishTable() {
        let newCards = ["3", "5", "7", "2", "4", "8", "6", "1"]
        while tableCardValues.count < 4 && !deckCards.isEmpty {
            if let randomCard = newCards.randomElement() {
                tableCardValues.append(randomCard)
                deckCards.removeFirst()
            }
        }

        checkGameOver()
    }

    private func checkGameOver() {
        let playerHandEmpty = playerHandValues.isEmpty
        let aiHandEmpty = aiHandValues.isEmpty
        let deckEmpty = deckCards.isEmpty

        if deckEmpty && (playerHandEmpty || aiHandEmpty) {
            endGame()
        }
    }

    private func endGame() {
        isGameOver = true
        isAnimating = true

        let winner = playerScore > aiScore ? "VOCÊ VENCEU! 🎉" : "IA VENCEU! 🤖"
        let winnerColor: SKColor = playerScore > aiScore ? .green : .red

        gameOverLabel?.removeFromParent()
        gameOverLabel = SKLabelNode(fontNamed: "Arial")
        gameOverLabel?.text = winner
        gameOverLabel?.fontSize = 32
        gameOverLabel?.fontColor = winnerColor
        gameOverLabel?.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        gameOverLabel?.zPosition = 100

        if let label = gameOverLabel { addChild(label) }

        let scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = "Você: \(playerScore) | IA: \(aiScore)"
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)

        let restartLabel = SKLabelNode(fontNamed: "Arial")
        restartLabel.text = "Toque para voltar ao menu"
        restartLabel.fontSize = 14
        restartLabel.fontColor = .yellow
        restartLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        restartLabel.zPosition = 100
        addChild(restartLabel)
    }


    func handleCardTap(_ cardNode: CardNode) {
        guard isPlayerTurn, !isAnimating else { return }

        let isHandCard = cardNode.name?.starts(with: "hand_") ?? false

        if isHandCard {
            if selectedHandCard != nil {
                selectedHandCard?.deselect()
            }
            selectedHandCard = cardNode
            cardNode.select()
            updateMessage("Clique nas cartas da mesa que somem 15")
        } else if cardNode.name?.starts(with: "table_") ?? false {
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
        lastMoveSum = totalSum

        if totalSum == 15 {
            updateMessage("✅ Soma = 15! Clique JOGAR para confirmar")
            drawActionButtons()
        } else {
            updateMessage("❌ Soma = \(totalSum) (precisa 15)")
        }
    }

    private func executePlayerMove(handCard: CardNode, tableCards: [CardNode]) {
        isAnimating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            handCard.animateCollection()
            for card in tableCards {
                card.animateCollection()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.applyPlayerMove(handCard: handCard, tableCards: tableCards)
            }
        }
    }

    private func applyPlayerMove(handCard: CardNode, tableCards: [CardNode]) {
        guard let handIndex = playerHandValues.firstIndex(of: handCard.cardDisplay) else { return }

        playerHandValues.remove(at: handIndex)

        for tableCard in tableCards {
            if let index = tableCardValues.firstIndex(of: tableCard.cardDisplay) {
                tableCardValues.remove(at: index)
            }
        }

        playerScore += tableCards.count + 1
        replenishTable()

        selectedHandCard = nil
        selectedCards.removeAll()
        isAnimating = false
        isPlayerTurn = false
        drawGame()
    }

    private func updateMessage(_ text: String) {
        messageLabel?.text = text
    }

    func handleGameOverTap() {
        if isGameOver {
            onGameOver?()
        }
    }

    func handleButtonTap(at position: CGPoint) {
        if let playBtn = playButton, playBtn.contains(position) {
            if lastMoveSum == 15 && selectedHandCard != nil && !selectedCards.isEmpty {
                executePlayerMove(handCard: selectedHandCard!, tableCards: selectedCards)
            }
        } else if let cancelBtn = cancelButton, cancelBtn.contains(position) {
            cancelSelection()
        }
    }

    private func cancelSelection() {
        selectedHandCard?.deselect()
        selectedHandCard = nil
        for card in selectedCards {
            card.deselect()
        }
        selectedCards.removeAll()
        playButton?.removeFromParent()
        cancelButton?.removeFromParent()
        updateMessage("Clique em uma carta")
    }
}
