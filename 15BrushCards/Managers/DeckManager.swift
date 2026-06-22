import Foundation

class DeckManager {
    static let shared = DeckManager()

    func createStandardDeck() -> [Card] {
        var deck: [Card] = []
        let suits: [CardSuit] = [.hearts, .diamonds, .clubs, .spades]
        let ranks: [CardRank] = [.ace, .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten]

        for suit in suits {
            for rank in ranks {
                deck.append(Card(suit: suit, rank: rank))
            }
        }

        return deck.shuffled()
    }

    func dealCards(from deck: inout [Card], count: Int) -> [Card] {
        var dealt: [Card] = []
        for _ in 0..<count {
            if !deck.isEmpty {
                dealt.append(deck.removeFirst())
            }
        }
        return dealt
    }

    func shuffleDeck(_ deck: inout [Card]) {
        deck.shuffle()
    }
}
