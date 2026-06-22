# 15 Brush Cards - Game Example & Testing

## Example Game Flow

Let's walk through a 2-player game with actual card values:

### Initial Setup
```
Deck: 40 cards (A-10, 4 suits)
Players: Alice (Human) vs Bob (AI - Medium difficulty)

AFTER DEALING:
───────────────────────────────────────────

Alice's Hand:        Bob's Hand:
┌───┐              ┌───┐
│ 7 │              │ 3 │
│ 8 │              │ 6 │
│ 9 │              │ 10│
└───┘              └───┘

Table (Face Up):
┌───┬───┬───┬───┐
│ 4 │ 2 │ 9 │ 6 │
└───┴───┴───┴───┘

Remaining Deck: 34 cards
```

### Turn 1: Alice's Move

**Alice analyzes her options:**

1. **Play 7 + table [8]** = 15 ✅
   - Take 2 cards from table, keeps 7 in hand

2. **Play 9 + table [6]** = 15 ✅
   - Take 2 cards from table, keeps 7,8 in hand

3. **Play 8 + table [4,3]** = 15 ✅
   - Take 3 cards from table, keep 7,9 in hand

**Alice chooses:** Play 7 + table [8]

```
AFTER Alice's Turn:
───────────────────────────────────────────

Alice's Collected: [7, 8]    (2 cards)
Alice's Hand: [9]

Table (needs replenishing):
┌───┬───┬───┐
│ 4 │ 2 │ 6 │
└───┴───┴───┘

System draws 1 card from deck to replenish to 4:
Table is now: [4, 2, 6, 5] (example new card is 5)

Remaining Deck: 33 cards

→ Next Turn: Bob's Move
```

### Turn 2: Bob's Move

**Bob (AI Medium) analyzes valid moves:**

1. **Play 3 + table [2,10]** = 15 ✅ (3 cards collected)
2. **Play 10 + table [5]** = 15 ✅ (2 cards collected)
3. **Play 6 + table [9]** = 15? No, 6+9=15 ✅ (2 cards collected)

**AI Medium Strategy:** Prefers moves with MORE cards
- Best move: **Play 3 + table [2,10]** = 15 (3 cards!)

```
AFTER Bob's Turn:
───────────────────────────────────────────

Bob's Collected: [3, 2, 10]    (3 cards)
Bob's Hand: [6]

Table (before replenish): [4, 6, 5]
Table (after drawing 1): [4, 6, 5, A] (new card is Ace=1)

Remaining Deck: 32 cards

Score Update:
- Alice: 2 cards
- Bob: 3 cards

→ Next Turn: Alice's Move
```

## Code Example: Testing Game Logic

### Test 1: Validate a Move

```swift
import Foundation

// Create test cards
let handCard = Card(suit: .hearts, rank: .seven)
let tableCard1 = Card(suit: .diamonds, rank: .eight)
let tableCard2 = Card(suit: .clubs, rank: .four)

// Test if 7 + 8 = 15
let isValid = GameLogicManager.shared.isValidMove(
    playerCard: handCard,
    tableCards: [tableCard1, tableCard2],
    selectedTableCards: [tableCard1]
)
print("Is 7+8=15 valid? \(isValid)") // Output: true

// Test if 7 + 4 = 15
let isInvalid = GameLogicManager.shared.isValidMove(
    playerCard: handCard,
    tableCards: [tableCard1, tableCard2],
    selectedTableCards: [tableCard2]
)
print("Is 7+4=15 valid? \(isInvalid)") // Output: false
```

### Test 2: Find All Valid Combos

```swift
// Create a player
var player = Player(id: "1", name: "Alice")
player.hand = [
    Card(suit: .hearts, rank: .seven),
    Card(suit: .diamonds, rank: .nine),
    Card(suit: .clubs, rank: .two)
]

// Create table cards
let tableCards = [
    Card(suit: .spades, rank: .eight),      // 8
    Card(suit: .hearts, rank: .three),      // 3
    Card(suit: .diamonds, rank: .four),     // 4
    Card(suit: .clubs, rank: .six)          // 6
]

// Find all valid moves
let validCombos = GameLogicManager.shared.getTableCardCombinations(
    for: Card(suit: .hearts, rank: .seven),
    from: tableCards
)

print("Valid combos for 7:")
for combo in validCombos {
    let sum = combo.reduce(0) { $0 + $1.value } + 7
    let comboStr = combo.map { $0.rank.rawValue }.joined(separator: "+")
    print("  7 + [\(comboStr)] = \(sum)")
}

/* Output:
Valid combos for 7:
  7 + [8] = 15
  7 + [3,4,8] = 22 (invalid)
  7 + [4,4] = 15 (if duplicate exists)
*/
```

### Test 3: AI Decision Making

```swift
// Create AI player
var aiPlayer = Player(id: "ai1", name: "Bot", isAI: true)
aiPlayer.hand = [
    Card(suit: .hearts, rank: .three),
    Card(suit: .diamonds, rank: .six),
    Card(suit: .clubs, rank: .ten)
]

let tableCards = [
    Card(suit: .spades, rank: .two),        // 2
    Card(suit: .hearts, rank: .nine),       // 9
    Card(suit: .diamonds, rank: .five),     // 5
    Card(suit: .clubs, rank: .four)         // 4
]

// Get AI move for different difficulties
let easyMove = AIManager.shared.getAIMove(
    for: aiPlayer,
    tableCards: tableCards,
    difficulty: .easy
)

let mediumMove = AIManager.shared.getAIMove(
    for: aiPlayer,
    tableCards: tableCards,
    difficulty: .medium
)

let hardMove = AIManager.shared.getAIMove(
    for: aiPlayer,
    tableCards: tableCards,
    difficulty: .hard
)

print("Easy AI: \(easyMove?.handCard.rank.rawValue ?? "Pass")")
print("Medium AI: \(mediumMove?.handCard.rank.rawValue ?? "Pass")")
print("Hard AI: \(hardMove?.handCard.rank.rawValue ?? "Pass")")

/* Expected:
Easy AI: Random (3, 6, or 10)
Medium AI: 3 (more cards collected: 3+2+10=15)
Hard AI: 3 (collects most cards)
*/
```

### Test 4: Complete Game Turn

```swift
// Initialize game
var gameManager = GameManager()
gameManager.initializeNewGame(mode: .singlePlayer, players: [
    Player(id: "human", name: "Alice"),
    Player(id: "ai", name: "Bob", isAI: true)
])

guard let gameState = gameManager.gameState else { return }

print("=== Game Started ===")
print("Current Player: \(gameState.currentPlayer.name)")
print("Alice's Hand: \(gameState.players[0].hand.map { $0.rank.rawValue }.joined(separator: ","))")
print("Bob's Hand: \(gameState.players[1].hand.map { $0.rank.rawValue }.joined(separator: ","))")
print("Table: \(gameState.tableCards.map { $0.rank.rawValue }.joined(separator: ","))")

// Player makes a move
let handCard = gameState.players[0].hand[0]
let tableSubset = Array(gameState.tableCards.prefix(1))

gameManager.executePlayerMove(handCard: handCard, tableCards: tableSubset)

print("\n=== After Alice's Move ===")
print("Current Player: \(gameManager.gameState?.currentPlayer.name ?? "?")")
print("Alice Collected: \(gameManager.gameState?.players[0].collectedCards.count ?? 0) cards")
print("Table: \(gameManager.gameState?.tableCards.map { $0.rank.rawValue }.joined(separator: ",") ?? "")")
```

### Test 5: Game End & Scoring

```swift
var gameState = gameManager.gameState!

// Simulate game until over
while !gameManager.checkGameOver() {
    // Get current player
    let currentPlayer = gameState.currentPlayer
    
    // Get valid moves
    let validMoves = gameManager.getValidMoves(for: currentPlayer)
    
    if !validMoves.isEmpty {
        // Execute first valid move
        let move = validMoves[0]
        gameManager.executePlayerMove(handCard: move.handCard, tableCards: move.tableCards)
    } else {
        // Skip turn if no valid moves
        gameManager.skipTurn()
    }
}

// Game is over - calculate scores
gameManager.endGame()

guard let finalState = gameManager.gameState else { return }

print("\n=== GAME OVER ===")
for player in finalState.players {
    player.calculateScore()
    print("\(player.name): \(player.score) points (\(player.collectedCards.count) cards)")
}

if let winner = GameLogicManager.shared.getWinner(gameState: finalState) {
    print("\n🏆 Winner: \(winner.name)!")
}
```

## Expected Output Example

```
=== Game Started ===
Current Player: Alice
Alice's Hand: 7,8,9
Bob's Hand: 3,6,10
Table: 4,2,9,6

=== After Alice's Move ===
Current Player: Bob
Alice Collected: 2 cards
Table: 4,2,9,6,5

=== GAME OVER ===
Alice: 15 points (15 cards)
Bob: 12 points (12 cards)

🏆 Winner: Alice!
```

## Debugging Tips

1. **Check valid moves:**
   ```swift
   let moves = GameLogicManager.shared.getAllValidMoves(
       for: player,
       tableCards: tableCards
   )
   print("Available moves: \(moves.count)")
   ```

2. **Verify card values:**
   ```swift
   let card = Card(suit: .hearts, rank: .ace)
   print("Ace value: \(card.value)") // Should be 1
   ```

3. **Track game state:**
   ```swift
   print("Deck remaining: \(gameState.deck.count)")
   print("Current player: \(gameState.currentPlayer.name)")
   print("Table cards: \(gameState.tableCards.count)")
   ```

---

Now ready to implement SpriteKit! 🎮
