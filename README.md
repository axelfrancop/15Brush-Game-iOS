# 15 Brush Cards - iOS Game

A strategic card game for iPhone featuring single-player AI matches and online multiplayer gameplay using SpriteKit and Firebase.

## Game Overview

**15 Brush Cards** is a turn-based card game where players aim to collect cards by combining cards from their hand with cards on the table to sum exactly 15 points.

### Game Rules

- **Deck**: Standard deck without face cards (A=1, 2-10)
- **Setup**: Each player starts with 3 cards in hand, 4 cards face-up on the table
- **Objective**: Collect the most cards by making valid combinations
- **Turn Flow**: 
  - Combine 1 card from hand + any number of table cards that sum to 15
  - Collected cards are kept separate (not returned to hand)
  - If table falls below 4 cards, replenish from deck
  - Continue until deck is empty
- **Scoring**: Number of cards collected (details TBD)

## Project Structure

```
Sources/
├── Models/          # Game entities (Card, Player, GameState)
├── Managers/        # Game logic and orchestration
│   ├── GameManager.swift
│   ├── DeckManager.swift
│   ├── GameLogicManager.swift
│   └── MatchmakingManager.swift
├── Services/        # Firebase, Authentication, Network
│   ├── AuthService.swift
│   ├── FirebaseService.swift
│   └── SyncManager.swift
├── Scenes/          # SpriteKit scenes (GameScene, MenuScene)
├── UI/              # Custom UI components
├── Network/         # Network models and protocols
└── AI/              # AI strategies (Easy, Medium, Hard)
```

## Features

### Current Implementation
- ✅ Core game logic (sum-to-15 validation)
- ✅ Card and Player models
- ✅ Deck management and shuffling
- ✅ AI opponent with difficulty levels
- ✅ Game state management

### In Development
- 🔄 Firebase Real-time Database integration
- 🔄 Social authentication (Apple ID, Google, Game Center)
- 🔄 Matchmaking system (queue + friends list)
- 🔄 SpriteKit scenes and UI
- 🔄 Turn-based synchronization
- 🔄 Online multiplayer

## Setup Instructions

### Prerequisites
- Xcode 13+
- iOS 14+
- CocoaPods (for Firebase dependencies)

### Firebase Configuration
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Download `GoogleService-Info.plist` and add to Xcode project
3. Configure Authentication (Apple, Google, Game Center)
4. Enable Realtime Database

### Installation
1. Clone repository
2. Install CocoaPods dependencies: `pod install`
3. Open `15BrushCards.xcworkspace`
4. Configure Firebase in AppDelegate
5. Build and run on iOS 14+ device or simulator

## Game Modes

- **Single Player**: Play against AI (Easy/Medium/Hard)
- **Online Multiplayer**: Real-time turn-based matches via Firebase
- **Friends**: Invite and play against friends
- **Matchmaking Queue**: Automatic opponent finding

## Development Roadmap

- [ ] Implement SpriteKit scenes
- [ ] Add card animations and visual effects
- [ ] Complete Firebase integration
- [ ] Implement social authentication
- [ ] Build matchmaking system
- [ ] Add sound effects and music
- [ ] Implement leaderboards
- [ ] Add push notifications

## Technical Stack

- **Language**: Swift
- **Framework**: SpriteKit (2D graphics)
- **Backend**: Firebase (Realtime Database, Authentication)
- **Authentication**: Apple Sign In, Google Sign In, Game Center
- **Architecture**: MVVM with Manager pattern

## License

MIT License

## Contact

For questions or suggestions: afrancopedroso@gmail.com
