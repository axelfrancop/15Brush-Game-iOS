import SpriteKit
import Foundation

class GameScene: SKScene {
    var cardNodes: [CardNode] = []
    private var selectedTableCards: [CardNode] = []
    private var selectedHandCards: [CardNode] = []
    var onGameOver: (() -> Void)?

    private var hasValidMoves: Bool {
        guard isPlayerTurn else { return false }
        let moves = findValidMoves(for: playerHandValues, from: tableCardValues)
        return !moves.isEmpty
    }

    private var tableCardValues: [String] = []
    private var playerHandValues: [String] = []
    private var aiHandValues: [String] = []

    private var playerCollectedCards: [String] = []
    private var aiCollectedCards: [String] = []

    private var playerScore = 0
    private var aiScore = 0
    private var lastPlayerToCollect: String = "player"

    private var playerBrushCount = 0
    private var aiBrushCount = 0

    private var isPlayerTurn = true
    private var isAnimating = false
    private var messageLabel: SKLabelNode?
    private var turnLabel: SKLabelNode?
    private var gameOverLabel: SKLabelNode?
    private var playButton: SKShapeNode?
    private var cancelButton: SKShapeNode?

    private var aiName: String = "IA"

    private let cardSize = CGSize(width: 60, height: 90)
    private let scientistNames = [
        "Albert Einstein",
        "Isaac Newton",
        "Marie Curie",
        "Galileo Galilei",
        "Charles Darwin",
        "Nikola Tesla",
        "Carl Sagan",
        "Stephen Hawking",
        "Niels Bohr",
        "Emmy Noether"
    ]
    private let spacing: CGFloat = 20
    private var deckCards: [String] = Array(repeating: "card", count: 40)
    private var isGameOver = false
    private var lastMoveSum = 0

    private let cardNaipes: [String: String] = [
        "1": "O", "2": "O", "3": "O", "4": "O", "5": "O", "6": "O", "7": "O", "8": "O", "9": "O", "10": "O",
        "11": "C", "12": "C", "13": "C", "14": "C", "15": "C", "16": "C", "17": "C", "18": "C", "19": "C", "20": "C",
        "21": "E", "22": "E", "23": "E", "24": "E", "25": "E", "26": "E", "27": "E", "28": "E", "29": "E", "30": "E",
        "31": "P", "32": "P", "33": "P", "34": "P", "35": "P", "36": "P", "37": "P", "38": "P", "39": "P", "40": "P"
    ]

    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        aiName = scientistNames.randomElement() ?? "IA"
        initializeDeck()
        drawGame()
    }

    private func initializeDeck() {
        var deck: [String] = []

        for value in 1...10 {
            for _ in 0..<4 {
                deck.append(String(value))
            }
        }

        deck.shuffle()

        tableCardValues = Array(deck[0..<4])
        playerHandValues = Array(deck[4..<7])
        aiHandValues = Array(deck[7..<10])
        deckCards = Array(deck[10...])

        print("DECK INITIALIZED: Table=\(tableCardValues), Player=\(playerHandValues), AI=\(aiHandValues), Remaining=\(deckCards.count)")
    }

    private func drawGame() {
        removeAllChildren()
        cardNodes.removeAll()
        selectedTableCards.removeAll()
        selectedHandCards.removeAll()

        drawGameBoard()

        let title = SKLabelNode(fontNamed: "Arial")
        title.text = "15 Brush Game"
        title.fontSize = 28
        title.fontColor = .white
        title.alpha = 0.5
        title.position = CGPoint(x: frame.midX, y: frame.maxY - 250)
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

    private func drawGameBoard() {
        let boardBackground = SKShapeNode(rectOf: CGSize(width: frame.width * 2, height: frame.height * 2))
        boardBackground.fillColor = SKColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1.0)
        boardBackground.strokeColor = .clear
        boardBackground.zPosition = -1
        boardBackground.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(boardBackground)

        let borderColor = SKColor(red: 0.05, green: 0.3, blue: 0.05, alpha: 1.0)
        let border = SKShapeNode(rectOf: CGSize(width: frame.width - 40, height: frame.height - 40), cornerRadius: 25)
        border.fillColor = .clear
        border.strokeColor = borderColor
        border.lineWidth = 8
        border.zPosition = -1
        border.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(border)

        let innerBorder = SKShapeNode(rectOf: CGSize(width: frame.width - 60, height: frame.height - 60), cornerRadius: 25)
        innerBorder.fillColor = .clear
        innerBorder.strokeColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 0.6)
        innerBorder.lineWidth = 2
        innerBorder.zPosition = -1
        innerBorder.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(innerBorder)

        for x in stride(from: frame.minX + 80, through: frame.maxX - 80, by: 100) {
            let dot = SKShapeNode(circleOfRadius: 3)
            dot.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 0.4)
            dot.strokeColor = .clear
            dot.zPosition = -1
            dot.position = CGPoint(x: x, y: frame.maxY - 50)
            addChild(dot)

            let dotBottom = SKShapeNode(circleOfRadius: 3)
            dotBottom.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 0.4)
            dotBottom.strokeColor = .clear
            dotBottom.zPosition = -1
            dotBottom.position = CGPoint(x: x, y: frame.minY + 50)
            addChild(dotBottom)
        }
    }

    private func drawTableCards() {
        let tableLabel = SKLabelNode(fontNamed: "Arial")
        tableLabel.text = "MESA"
        tableLabel.fontSize = 12
        tableLabel.fontColor = .white
        tableLabel.position = CGPoint(x: frame.midX, y: frame.midY + 60)
        tableLabel.zPosition = 1
        addChild(tableLabel)

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
        let handLabel = SKLabelNode(fontNamed: "Arial")
        handLabel.text = "SUA MÃO"
        handLabel.fontSize = 12
        handLabel.fontColor = .white
        handLabel.position = CGPoint(x: frame.midX, y: frame.minY + 140)
        handLabel.zPosition = 1
        addChild(handLabel)

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
        aiLabel.text = "Cartas de \(aiName)"
        aiLabel.fontSize = 14
        aiLabel.fontColor = .blue
        aiLabel.position = CGPoint(x: frame.midX, y: frame.midY + 60)
        aiLabel.zPosition = 1
        addChild(aiLabel)
    }

    private func drawGameStatus() {
        let status = SKLabelNode(fontNamed: "Arial")
        status.fontSize = 11
        status.fontColor = .white
        status.text = "Cartas Player: \(playerCollectedCards.count) | Cartas IA: \(aiCollectedCards.count) | Baralho: \(deckCards.count)"
        status.position = CGPoint(x: frame.midX, y: frame.midY - 80)
        status.zPosition = 1
        addChild(status)
    }

    private func drawActionButtons() {
        guard isPlayerTurn && !selectedHandCards.isEmpty else { return }

        playButton?.removeFromParent()
        cancelButton?.removeFromParent()

        let buttonWidth: CGFloat = 80
        let buttonHeight: CGFloat = 40

        playButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 8)
        playButton?.fillColor = .green
        playButton?.strokeColor = .white
        playButton?.lineWidth = 2
        playButton?.position = CGPoint(x: frame.midX - 60, y: frame.minY + 220)
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
        cancelButton?.position = CGPoint(x: frame.midX + 60, y: frame.minY + 220)
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
        turnLabel?.text = isPlayerTurn ? "SEU TURNO" : "TURNO DE \(aiName.uppercased())"
        turnLabel?.position = CGPoint(x: frame.midX, y: frame.maxY - 40)
        turnLabel?.zPosition = 1

        if let label = turnLabel { addChild(label) }

        messageLabel?.removeFromParent()
        messageLabel = SKLabelNode(fontNamed: "Arial")
        messageLabel?.fontSize = 12
        messageLabel?.fontColor = .yellow

        if isPlayerTurn {
            if hasValidMoves {
                messageLabel?.text = "Clique em uma carta"
            } else {
                messageLabel?.text = "Sem jogadas válidas - Pule o turno"
                drawSkipButton()
            }
        } else {
            messageLabel?.text = "\(aiName) jogando..."
        }

        messageLabel?.position = CGPoint(x: frame.midX, y: frame.maxY - 30)
        messageLabel?.zPosition = 1

        if let label = messageLabel { addChild(label) }
    }

    private func drawSkipButton() {
        playButton?.removeFromParent()

        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40

        playButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 8)
        playButton?.fillColor = .orange
        playButton?.strokeColor = .white
        playButton?.lineWidth = 2
        playButton?.position = CGPoint(x: frame.midX, y: frame.minY + 220)
        playButton?.zPosition = 50
        playButton?.name = "skip_button"

        let skipLabel = SKLabelNode(fontNamed: "Arial")
        skipLabel.text = "PULAR"
        skipLabel.fontSize = 14
        skipLabel.fontColor = .white
        skipLabel.position = CGPoint(x: 0, y: -5)
        skipLabel.zPosition = 51
        playButton?.addChild(skipLabel)

        if let btn = playButton { addChild(btn) }
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

        var collectedCardIds: [String] = [handCard]
        for card in tableCards {
            if let index = tableCardValues.firstIndex(of: card) {
                collectedCardIds.append(card)
                tableCardValues.remove(at: index)
            }
        }

        aiCollectedCards.append(contentsOf: collectedCardIds)
        lastPlayerToCollect = "ai"

        if tableCardValues.isEmpty {
            aiBrushCount += 1
            showBrushAlert(for: aiName)
        }

        replenishTable()

        isAnimating = false
        isPlayerTurn = true
        drawGame()
    }

    private func skipAITurn() {
        let playerHasValidMoves = !findValidMoves(for: playerHandValues, from: tableCardValues).isEmpty

        if !playerHasValidMoves {
            forceTableReplenishment()
        } else {
            replenishTable()
        }

        isAnimating = false
        isPlayerTurn = true
        drawGame()
    }

    private func replenishTable() {
        let newCards = ["3", "5", "7", "2", "4", "8", "6", "1"]

        // Só repõe a mesa quando ficar VAZIA (0 cartas)
        if tableCardValues.isEmpty && !deckCards.isEmpty {
            for _ in 0..<4 {
                if let randomCard = newCards.randomElement() {
                    tableCardValues.append(randomCard)
                    deckCards.removeFirst()
                }
            }
        }

        replenishHands()
        checkGameOver()
    }

    private func forceTableReplenishment() {
        let newCards = ["3", "5", "7", "2", "4", "8", "6", "1"]

        // Força reabastecimento mesmo se mesa não estiver vazia
        // Usado quando ambos jogadores não têm jogadas válidas
        tableCardValues.removeAll()

        for _ in 0..<4 {
            if !deckCards.isEmpty {
                if let randomCard = newCards.randomElement() {
                    tableCardValues.append(randomCard)
                    deckCards.removeFirst()
                }
            }
        }

        replenishHands()
        checkGameOver()
    }

    private func replenishHands() {
        let newCards = ["3", "5", "7", "2", "4", "8", "6", "1", "9", "10"]

        // Só reabastece mão quando ficar VAZIA (0 cartas)
        if playerHandValues.isEmpty && !deckCards.isEmpty {
            for _ in 0..<3 {
                if let randomCard = newCards.randomElement() {
                    playerHandValues.append(randomCard)
                    deckCards.removeFirst()
                }
            }
        }

        if aiHandValues.isEmpty && !deckCards.isEmpty {
            for _ in 0..<3 {
                if let randomCard = newCards.randomElement() {
                    aiHandValues.append(randomCard)
                    deckCards.removeFirst()
                }
            }
        }
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

        calculateFinalScores()

        let winner = playerScore > aiScore ? "VOCÊ VENCEU! 🎉" : "\(aiName.uppercased()) VENCEU! 🤖"
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
            if selectedHandCards.contains(cardNode) {
                selectedHandCards.removeAll { $0 == cardNode }
                cardNode.deselect()
            } else {
                selectedHandCards.append(cardNode)
                cardNode.select()
            }

            if !selectedHandCards.isEmpty {
                updateMessage("Clique nas cartas da mesa que somem 15")
            } else {
                updateMessage("Selecione cartas da mão")
            }
        } else if cardNode.name?.starts(with: "table_") ?? false {
            guard !selectedHandCards.isEmpty else {
                updateMessage("Selecione cartas da mão primeiro!")
                return
            }

            if selectedTableCards.contains(cardNode) {
                selectedTableCards.removeAll { $0 == cardNode }
                cardNode.deselect()
            } else {
                selectedTableCards.append(cardNode)
                cardNode.select()
            }

            checkMove(handCards: selectedHandCards, tableCards: selectedTableCards)
        }
    }

    private func checkMove(handCards: [CardNode], tableCards: [CardNode]) {
        guard !handCards.isEmpty else { return }

        let handSum = handCards.reduce(0) { sum, card in
            sum + (Int(card.cardDisplay) ?? 0)
        }

        let tableSum = tableCards.reduce(0) { sum, card in
            sum + (Int(card.cardDisplay) ?? 0)
        }

        let totalSum = handSum + tableSum
        lastMoveSum = totalSum

        if totalSum == 15 {
            updateMessage("✅ Soma = 15! Clique JOGAR para confirmar")
            drawActionButtons()
        } else {
            updateMessage("❌ Soma = \(totalSum) (precisa 15)")
        }
    }

    private func executePlayerMove(handCards: [CardNode], tableCards: [CardNode]) {
        isAnimating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            for card in handCards {
                card.animateCollection()
            }
            for card in tableCards {
                card.animateCollection()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.applyPlayerMove(handCards: handCards, tableCards: tableCards)
            }
        }
    }

    private func applyPlayerMove(handCards: [CardNode], tableCards: [CardNode]) {
        var collectedCardIds: [String] = []

        for handCard in handCards {
            if let index = playerHandValues.firstIndex(of: handCard.cardDisplay) {
                collectedCardIds.append(handCard.cardDisplay)
                playerHandValues.remove(at: index)
            }
        }

        for tableCard in tableCards {
            if let index = tableCardValues.firstIndex(of: tableCard.cardDisplay) {
                collectedCardIds.append(tableCard.cardDisplay)
                tableCardValues.remove(at: index)
            }
        }

        playerCollectedCards.append(contentsOf: collectedCardIds)
        lastPlayerToCollect = "player"

        if tableCardValues.isEmpty {
            playerBrushCount += 1
            showBrushAlert(for: "Você")
        }

        replenishTable()

        selectedHandCards.removeAll()
        selectedTableCards.removeAll()
        isAnimating = false
        isPlayerTurn = false
        drawGame()
    }

    private func updateMessage(_ text: String) {
        messageLabel?.text = text
    }


    func handleSceneTap(at position: CGPoint) {
        guard !isAnimating else { return }

        if isGameOver {
            onGameOver?()
            return
        }

        if let playBtn = playButton {
            let buttonSize = CGSize(width: 80, height: 40)
            let buttonRect = CGRect(
                x: playBtn.position.x - buttonSize.width / 2,
                y: playBtn.position.y - buttonSize.height / 2,
                width: buttonSize.width,
                height: buttonSize.height
            )

            if buttonRect.contains(position) {
                if playBtn.name == "skip_button" {
                    skipPlayerTurn()
                } else if lastMoveSum == 15 && !selectedHandCards.isEmpty {
                    executePlayerMove(handCards: selectedHandCards, tableCards: selectedTableCards)
                }
                return
            }
        }

        if let cancelBtn = cancelButton {
            let buttonSize = CGSize(width: 100, height: 40)
            let buttonRect = CGRect(
                x: cancelBtn.position.x - buttonSize.width / 2,
                y: cancelBtn.position.y - buttonSize.height / 2,
                width: buttonSize.width,
                height: buttonSize.height
            )

            if buttonRect.contains(position) {
                cancelSelection()
                return
            }
        }

        for cardNode in cardNodes {
            if cardNode.contains(position) {
                handleCardTap(cardNode)
                return
            }
        }
    }

    private func skipPlayerTurn() {
        let aiHasValidMoves = !findValidMoves(for: aiHandValues, from: tableCardValues).isEmpty

        if !aiHasValidMoves {
            forceTableReplenishment()
        } else {
            replenishTable()
        }

        isAnimating = false
        isPlayerTurn = false
        drawGame()
    }

    private func cancelSelection() {
        for card in selectedHandCards {
            card.deselect()
        }
        for card in selectedTableCards {
            card.deselect()
        }
        selectedHandCards.removeAll()
        selectedTableCards.removeAll()
        playButton?.removeFromParent()
        cancelButton?.removeFromParent()
        updateMessage("Selecione cartas da mão")
    }

    private func countRedCards(_ cards: [String]) -> Int {
        var count = 0
        for card in cards {
            if let naipe = cardNaipes[card] {
                if naipe == "O" || naipe == "C" {
                    count += 1
                }
            }
        }
        return count
    }

    private func showBrushAlert(for player: String) {
        let brushLabel = SKLabelNode(fontNamed: "Arial")
        brushLabel.text = "🎉 BRUSH! 🎉"
        brushLabel.fontSize = 48
        brushLabel.fontColor = .yellow
        brushLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        brushLabel.zPosition = 150
        brushLabel.name = "brush_alert"
        addChild(brushLabel)

        let playerLabel = SKLabelNode(fontNamed: "Arial")
        playerLabel.text = "\(player) levantou a mesa!"
        playerLabel.fontSize = 20
        playerLabel.fontColor = .white
        playerLabel.position = CGPoint(x: frame.midX, y: frame.midY + 40)
        playerLabel.zPosition = 150
        addChild(playerLabel)

        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.3)
        let fade = SKAction.fadeOut(withDuration: 1.0)
        let sequence = SKAction.sequence([scaleUp, scaleDown, fade])

        brushLabel.run(sequence) { brushLabel.removeFromParent() }
    }

    private func calculateFinalScores() {
        // Distribuir cartas restantes na mão para quem fez a última coleta
        if lastPlayerToCollect == "player" {
            playerCollectedCards.append(contentsOf: playerHandValues)
            playerCollectedCards.append(contentsOf: aiHandValues)
        } else {
            aiCollectedCards.append(contentsOf: playerHandValues)
            aiCollectedCards.append(contentsOf: aiHandValues)
        }

        playerScore = 0
        aiScore = 0

        // Regra 1: Carta 7 de Ouro = 1 ponto
        if playerCollectedCards.contains("7") { playerScore += 1 }
        if aiCollectedCards.contains("7") { aiScore += 1 }

        // Regra 2: Mais cartas vermelhas = 1 ponto
        let playerRedCards = countRedCards(playerCollectedCards)
        let aiRedCards = countRedCards(aiCollectedCards)
        if playerRedCards > aiRedCards { playerScore += 1 }
        else if aiRedCards > playerRedCards { aiScore += 1 }

        // Regra 3: Mais cartas coletadas = 1 ponto
        if playerCollectedCards.count > aiCollectedCards.count { playerScore += 1 }
        else if aiCollectedCards.count > playerCollectedCards.count { aiScore += 1 }

        // Regra 4: Última carta coletada = 1 ponto
        if lastPlayerToCollect == "player" { playerScore += 1 }
        else if lastPlayerToCollect == "ai" { aiScore += 1 }

        // Regra 5: BRUSH (Escova) = 1 ponto cada
        playerScore += playerBrushCount
        aiScore += aiBrushCount

        print("SCORE: Player=\(playerScore), AI=\(aiScore)")
        print("DETAILS: Player Red=\(countRedCards(playerCollectedCards)), AI Red=\(countRedCards(aiCollectedCards))")
        print("DETAILS: Player Cards=\(playerCollectedCards.count), AI Cards=\(aiCollectedCards.count)")
        print("DETAILS: Last Player=\(lastPlayerToCollect)")
        print("DETAILS: Player Brushes=\(playerBrushCount), AI Brushes=\(aiBrushCount)")
    }
}
