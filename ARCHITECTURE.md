# 15 Brush Cards - Architecture Overview

## High-Level Architecture

```
┌─────────────────────────────────────────────────────┐
│              SwiftUI App / SpriteKit Scenes          │
│            (Views, Game Rendering, Input)           │
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│                   Game Managers                      │
│  GameManager | GameLogicManager | DeckManager       │
│   MatchmakingManager | AIManager                     │
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│                   Data Models                        │
│   Card | Player | GameState | User | GameMessage    │
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│                  Services Layer                      │
│  Firebase | Auth | Matchmaking | Game Sync          │
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│          External Services & APIs                    │
│     Firebase Realtime DB | Game Center | Auth0       │
└─────────────────────────────────────────────────────┘
```

## Component Details

### Models Layer (Sources/Models)

**Card.swift**
- Represents a single playing card
- Properties: suit, rank, value, id
- Card values: A=1, 2-10=face value

**Player.swift**
- Represents a game participant
- Properties: id, name, hand, collectedCards, score, isAI
- Methods: addCardToHand(), collectCards(), calculateScore()
- Can validate possible 15-point combinations

**GameState.swift**
- Immutable representation of game state at any moment
- Properties: players, deck, tableCards, currentPlayerIndex, status
- Contains game logic state: round, gameMode, lastUpdated
- Used for Firebase sync and turn-based updates

### Managers Layer (Sources/Managers)

**GameManager** (ObservableObject)
- Orchestrates entire game flow
- Publishes state changes to SwiftUI views
- Methods:
  - `initializeNewGame()` - Setup initial state
  - `executePlayerMove()` - Process player action
  - `skipTurn()` - Pass without playing
  - `checkGameOver()` - Determine if game ended
  - `endGame()` - Finalize scores

**GameLogicManager** (Singleton)
- Core game rules engine
- Validates moves (sum must equal 15)
- Methods:
  - `isValidMove()` - Check if combination = 15
  - `getTableCardCombinations()` - Find all valid combos
  - `executeMove()` - Update game state
  - `getAllValidMoves()` - Get possible moves for player

**DeckManager** (Singleton)
- Manages card operations
- Methods:
  - `createStandardDeck()` - Create 52 cards (A-10, 4 suits)
  - `dealCards()` - Remove and return cards from deck
  - `shuffleDeck()` - Randomize card order

**MatchmakingManager** (ObservableObject)
- Handles online opponent finding
- Publishes search status to UI
- Methods:
  - `startSearching()` - Join matchmaking queue
  - `cancelSearch()` - Leave queue
  - `inviteFriend()` - Direct game invite
  - `createGameWithOpponent()` - Generate game state

### Services Layer (Sources/Services)

**AuthService** (ObservableObject)
- Manages user authentication
- Supports: Apple ID, Google Sign In, Game Center
- Published properties: isAuthenticated, currentUser
- Methods:
  - `signInWithApple()`
  - `signInWithGoogle()`
  - `authenticateWithGameCenter()`
  - `signOut()`

**FirebaseService** (Singleton)
- Interfaces with Firebase backend
- No real-time listening (yet - upgrade next phase)
- Key methods:
  - `createGame()` - Save new game
  - `updateGameState()` - Sync game progress
  - `fetchGameState()` - Load game
  - `savePlayer()` / `fetchPlayer()`
  - `updateLeaderboard()`

### AI Layer (Sources/AI)

**AIManager** (Singleton)
- Provides opponent moves for single-player
- Three difficulty levels:
  - **Easy**: Random valid move
  - **Medium**: Prefers moves with more cards (max points)
  - **Hard**: Maximizes card collection + high-value cards
- Method: `getAIMove()` returns best move for difficulty

## Data Flow

### Turn-Based Flow
```
Player Turn:
1. GameScene presents valid moves
2. Player taps card + table cards
3. GameManager.executePlayerMove()
4. GameLogicManager validates (sum = 15?)
5. If valid:
   - Add to collectedCards
   - Remove from hand & table
   - Call endTurn()
6. Replenish table (if needed)
7. Switch to next player
8. Check if game over
9. If online: sync with Firebase
```

### Matchmaking Flow
```
1. User clicks "Play Online"
2. MatchmakingManager.startSearching()
3. Add to Firebase queue
4. Poll for matches every 1 second
5. When match found:
   - Fetch opponent details
   - createGameWithOpponent()
   - Publish to SwiftUI
6. GameScene renders game
```

## State Management

### Single Player
- GameManager holds all state
- Changes update published `@Published var gameState`
- UI re-renders automatically
- No network sync needed

### Multiplayer (Turn-Based)
- GameManager owns local state
- Each turn posts to Firebase
- Opponent's changes pull from Firebase
- Sync happens between turns

## Codability & Serialization

All models conform to `Codable`:
- Enables JSON serialization for Firebase
- Can be stored in Realtime Database
- Easy to sync between devices

Example Firebase structure:
```
games/
  {gameID}/
    gameState: {...}
    players: [...]
    messages: [...]
```

## Testing Strategy

### Unit Tests (GameLogic)
```swift
// Test sum validation
assert(GameLogicManager.isValidMove(7, [8]) == true)
assert(GameLogicManager.isValidMove(5, [5,6]) == false)

// Test combo finding
let combos = GameLogicManager.getTableCardCombinations(7, [2,3,4,5])
assert(combos.count == 2) // [8] and [3,5]
```

### Integration Tests (Game Flow)
```swift
// Test complete turn
initGame()
executeMove(player1Card, tableCards)
assert(currentPlayer == player2)
assert(tableCards.count == 4)
```

### UI Tests (SpriteKit)
- Visual validation of cards
- Touch input handling
- Animation smoothness

## Performance Considerations

1. **Card Combinations**: Exponential growth (2^n where n=table cards)
   - Max 4 table cards = 16 combinations (acceptable)
   - Optimization: Cache valid combos per turn

2. **Firebase Sync**: 
   - Implement batching for multiple moves
   - Use transactions for concurrent updates

3. **AI Decision Time**:
   - Hard difficulty evaluates all valid moves (~5-10ms)
   - Acceptable for turn-based game

## Security Considerations

1. **Authentication**: OAuth 2.0 via Apple/Google
2. **Database Rules**: 
   - Players can only modify their own gameState
   - Read-only access to opponent data during game
3. **Input Validation**: 
   - Server-side validation of moves on Firebase
   - Prevent invalid state mutations

## Future Enhancements

1. **Real-time Multiplayer**: Replace polling with Firebase listeners
2. **Replay System**: Store move history for playback
3. **Statistics**: Track win rate, average score per player
4. **Achievements**: Badges for milestones (50 wins, perfect games, etc.)
5. **Spectator Mode**: Watch friend's games in real-time
6. **Tournaments**: Multi-round competitions

---

Ready to implement SpriteKit scenes! 🎨
