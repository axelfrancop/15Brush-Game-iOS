import Foundation

enum GameStatus: String, Codable {
    case waiting = "waiting"
    case playing = "playing"
    case finished = "finished"
    case paused = "paused"
}

struct GameState: Codable {
    var gameID: String
    var players: [Player]
    var deck: [Card]
    var tableCards: [Card] = []
    var currentPlayerIndex: Int = 0
    var status: GameStatus = .playing
    var round: Int = 1
    var gameMode: GameMode
    var lastUpdated: Date = Date()

    var currentPlayer: Player {
        players[currentPlayerIndex]
    }

    mutating func nextPlayer() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }

    mutating func addCardToTable(_ card: Card) {
        tableCards.append(card)
    }

    mutating func removeCardsFromTable(_ cards: [Card]) {
        tableCards.removeAll { card in
            cards.contains { $0.id == card.id }
        }
    }

    mutating func replenishTableCards(from deck: inout [Card]) {
        let cardsNeeded = 4 - tableCards.count
        for _ in 0..<cardsNeeded {
            if !deck.isEmpty {
                tableCards.append(deck.removeFirst())
            }
        }
    }

    var isGameOver: Bool {
        deck.isEmpty && players.allSatisfy { $0.hand.isEmpty }
    }
}

enum GameMode: String, Codable {
    case singlePlayer = "singlePlayer"
    case multiplayerLocal = "multiplayerLocal"
    case multiplayerOnline = "multiplayerOnline"
}
