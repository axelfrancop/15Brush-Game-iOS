import Foundation

class GameLogicManager {
    static let shared = GameLogicManager()

    let TARGET_SUM = 15

    func isValidMove(playerCard: Card, tableCards: [Card], selectedTableCards: [Card]) -> Bool {
        let sum = playerCard.value + selectedTableCards.reduce(0) { $0 + $1.value }
        return sum == TARGET_SUM
    }

    func getAllValidMoves(for player: Player, tableCards: [Card]) -> [(handCard: Card, tableCards: [Card])] {
        var validMoves: [(handCard: Card, tableCards: [Card])] = []

        for handCard in player.hand {
            let combinations = getTableCardCombinations(for: handCard, from: tableCards)
            for combo in combinations {
                validMoves.append((handCard: handCard, tableCards: combo))
            }
        }

        return validMoves
    }

    func getTableCardCombinations(for handCard: Card, from tableCards: [Card]) -> [[Card]] {
        var validCombinations: [[Card]] = []
        let targetSum = TARGET_SUM

        let allSubsets = getAllSubsets(of: tableCards)

        for subset in allSubsets {
            let sum = subset.reduce(0) { $0 + $1.value } + handCard.value
            if sum == targetSum {
                validCombinations.append(subset)
            }
        }

        return validCombinations
    }

    private func getAllSubsets(of array: [Card]) -> [[Card]] {
        var result: [[Card]] = [[]]

        for item in array {
            let newSubsets = result.map { $0 + [item] }
            result.append(contentsOf: newSubsets)
        }

        return result.filter { !$0.isEmpty }
    }

    func executeMove(gameState: inout GameState, handCard: Card, tableCards: [Card]) {
        var currentPlayer = gameState.currentPlayer

        let usedCards = tableCards + [handCard]
        currentPlayer.collectCards(usedCards)
        currentPlayer.removeCardFromHand(handCard)
        gameState.removeCardsFromTable(tableCards)

        gameState.players[gameState.currentPlayerIndex] = currentPlayer
    }

    func endTurn(gameState: inout GameState) {
        replenishTableIfNeeded(gameState: &gameState)
        gameState.nextPlayer()
    }

    func replenishTableIfNeeded(gameState: inout GameState) {
        if gameState.tableCards.count < 4 && !gameState.deck.isEmpty {
            gameState.replenishTableCards(from: &gameState.deck)
        }
    }

    func calculateFinalScores(gameState: inout GameState) {
        for index in gameState.players.indices {
            gameState.players[index].calculateScore()
        }
    }

    func getWinner(gameState: GameState) -> Player? {
        return gameState.players.max { $0.score < $1.score }
    }
}
