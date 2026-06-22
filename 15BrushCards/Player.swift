import Foundation

struct Player: Identifiable, Codable {
    let id: String
    var name: String
    var hand: [Card] = []
    var collectedCards: [Card] = []
    var score: Int = 0
    var isAI: Bool = false
    var isCurrentPlayer: Bool = false

    init(id: String, name: String, isAI: Bool = false) {
        self.id = id
        self.name = name
        self.isAI = isAI
    }

    mutating func addCardToHand(_ card: Card) {
        hand.append(card)
    }

    mutating func removeCardFromHand(_ card: Card) {
        hand.removeAll { $0.id == card.id }
    }

    mutating func collectCards(_ cards: [Card]) {
        collectedCards.append(contentsOf: cards)
    }

    func canMake15WithCard(_ cardInHand: Card, and cardsOnTable: [Card]) -> [[Card]] {
        var validCombinations: [[Card]] = []
        let targetSum = 15

        for i in 0..<cardsOnTable.count {
            let subsets = getSubsets(Array(cardsOnTable), start: i)
            for subset in subsets {
                let sum = subset.reduce(0) { $0 + $1.value } + cardInHand.value
                if sum == targetSum {
                    validCombinations.append(subset + [cardInHand])
                }
            }
        }

        return validCombinations
    }

    private func getSubsets(_ array: [Card], start: Int = 0) -> [[Card]] {
        var result: [[Card]] = [[]]

        for i in start..<array.count {
            let newSubsets = result.map { $0 + [array[i]] }
            result.append(contentsOf: newSubsets)
        }

        return result
    }

    mutating func calculateScore() {
        score = collectedCards.count
    }
}
