import Foundation

class GameManager: ObservableObject {
    @Published var gameState: GameState?
    @Published var isLoading = false
    @Published var errorMessage: String?

    static let shared = GameManager()

    private let deckManager = DeckManager.shared
    private let gameLogicManager = GameLogicManager.shared

    func initializeNewGame(mode: GameMode, players: [Player]) {
        isLoading = true

        var deck = deckManager.createStandardDeck()
        var playersWithCards = players

        // Deal 3 cards to each player
        for (index, _) in playersWithCards.enumerated() {
            let cards = deckManager.dealCards(from: &deck, count: 3)
            playersWithCards[index].hand = cards
        }

        // Deal 4 cards to table
        let tableCards = deckManager.dealCards(from: &deck, count: 4)

        var newGameState = GameState(
            gameID: UUID().uuidString,
            players: playersWithCards,
            deck: deck,
            tableCards: tableCards,
            gameMode: mode
        )

        newGameState.players[0].isCurrentPlayer = true
        self.gameState = newGameState
        isLoading = false
    }

    func executePlayerMove(handCard: Card, tableCards: [Card]) {
        guard var gameState = gameState else { return }

        if gameLogicManager.isValidMove(playerCard: handCard, tableCards: tableCards, selectedTableCards: tableCards) {
            gameLogicManager.executeMove(gameState: &gameState, handCard: handCard, tableCards: tableCards)
            gameLogicManager.endTurn(gameState: &gameState)
            self.gameState = gameState
        } else {
            errorMessage = "Invalid move. Cards don't sum to 15."
        }
    }

    func skipTurn() {
        guard var gameState = gameState else { return }

        gameLogicManager.replenishTableIfNeeded(gameState: &gameState)
        gameState.nextPlayer()
        self.gameState = gameState
    }

    func drawCardIfNeeded() {
        guard var gameState = gameState else { return }

        if gameState.tableCards.count < 4 && !gameState.deck.isEmpty {
            gameLogicManager.replenishTableIfNeeded(gameState: &gameState)
            self.gameState = gameState
        }
    }

    func checkGameOver() -> Bool {
        guard let gameState = gameState else { return false }
        return gameState.isGameOver
    }

    func endGame() {
        guard var gameState = gameState else { return }

        gameLogicManager.calculateFinalScores(gameState: &gameState)
        gameState.status = .finished
        self.gameState = gameState
    }

    func getValidMoves(for player: Player) -> [(handCard: Card, tableCards: [Card])] {
        guard let gameState = gameState else { return [] }
        return gameLogicManager.getAllValidMoves(for: player, tableCards: gameState.tableCards)
    }

    func resetGame() {
        gameState = nil
        errorMessage = nil
    }
}
