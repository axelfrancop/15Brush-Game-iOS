import Foundation

enum AIDifficulty {
    case easy
    case medium
    case hard
}

class AIManager {
    static let shared = AIManager()

    private let gameLogicManager = GameLogicManager.shared

    func getAIMove(for aiPlayer: Player, tableCards: [Card], difficulty: AIDifficulty) -> (handCard: Card, tableCards: [Card])? {
        let validMoves = gameLogicManager.getAllValidMoves(for: aiPlayer, tableCards: tableCards)

        guard !validMoves.isEmpty else { return nil }

        switch difficulty {
        case .easy:
            return getRandomMove(from: validMoves)
        case .medium:
            return getMediumMove(from: validMoves, aiPlayer: aiPlayer)
        case .hard:
            return getHardMove(from: validMoves, aiPlayer: aiPlayer)
        }
    }

    private func getRandomMove(from moves: [(handCard: Card, tableCards: [Card])]) -> (handCard: Card, tableCards: [Card])? {
        return moves.randomElement()
    }

    private func getMediumMove(from moves: [(handCard: Card, tableCards: [Card])], aiPlayer: Player) -> (handCard: Card, tableCards: [Card])? {
        // Prefer moves that take more cards (more points)
        let sortedMoves = moves.sorted { $0.tableCards.count > $1.tableCards.count }
        return sortedMoves.first ?? moves.randomElement()
    }

    private func getHardMove(from moves: [(handCard: Card, tableCards: [Card])], aiPlayer: Player) -> (handCard: Card, tableCards: [Card])? {
        // Prefer moves that maximize card collection
        let sortedMoves = moves.sorted { move1, move2 in
            let count1 = move1.tableCards.count
            let count2 = move2.tableCards.count
            if count1 != count2 {
                return count1 > count2
            }
            // Tiebreaker: prefer using high-value cards
            return move1.handCard.value > move2.handCard.value
        }
        return sortedMoves.first
    }

    func shouldPass(difficulty: AIDifficulty) -> Bool {
        switch difficulty {
        case .easy:
            return Bool.random()
        case .medium:
            return Bool.random(probability: 0.3)
        case .hard:
            return false
        }
    }
}

extension Bool {
    static func random(probability: Double) -> Bool {
        return Double.random(in: 0...1) < probability
    }
}
