import Foundation

enum CardSuit: String, Codable {
    case hearts = "♥️"
    case diamonds = "♦️"
    case clubs = "♣️"
    case spades = "♠️"
}

enum CardRank: String, Codable {
    case ace = "A"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"

    var value: Int {
        switch self {
        case .ace: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        case .seven: return 7
        case .eight: return 8
        case .nine: return 9
        case .ten: return 10
        }
    }
}

struct Card: Identifiable, Codable, Equatable {
    let id: String
    let suit: CardSuit
    let rank: CardRank

    var value: Int {
        rank.value
    }

    var displayName: String {
        "\(rank.rawValue)\(suit.rawValue)"
    }

    init(suit: CardSuit, rank: CardRank) {
        self.suit = suit
        self.rank = rank
        self.id = UUID().uuidString
    }

    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }
}
