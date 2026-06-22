# 15 Brush Cards - Setup & Development Guide

## Step 1: Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Choose **iOS App**
4. Configure:
   - Product Name: `15BrushCards`
   - Team: Select your team
   - Organization Identifier: `com.yourname.brushcards`
   - Bundle Identifier: `com.yourname.brushcards`
   - Interface: SwiftUI (we'll use for main app structure)
   - Language: Swift

## Step 2: Clone Repository & Integrate Code

```bash
# Clone the repo
git clone https://github.com/axelfrancop/15Brush-Game-iOS.git
cd 15Brush-Game-iOS

# The Swift source files are in Sources/ folder
```

## Step 3: Add Swift Files to Xcode

1. In Xcode, right-click on project → Add Files to project
2. Navigate to cloned repo's `Sources/` folder
3. Select all folders (Models, Managers, Services, AI, Scenes, UI, Network)
4. ✅ Check "Copy items if needed"
5. ✅ Check "Create groups"
6. Select your target and add files

## Step 4: Install Firebase via CocoaPods

```bash
# Navigate to project directory
cd path/to/15Brush-Game-iOS

# Create Podfile
pod init

# Add to Podfile
target '15BrushCards' do
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'Firebase/Analytics'
end

# Install pods
pod install

# From now on, open .xcworkspace file instead of .xcodeproj
open 15BrushCards.xcworkspace
```

## Step 5: Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new iOS project
3. Download `GoogleService-Info.plist`
4. Add to Xcode (drag and drop to project)
5. ✅ Uncheck "Copy items if needed" (keep reference)

## Step 6: Setup Authentication

### Apple Sign In
1. Firebase Console → Authentication → Sign-in method
2. Enable **Apple**
3. Xcode → Signing & Capabilities
4. Add capability: **Sign in with Apple**

### Google Sign In
1. Firebase Console → Authentication → Sign-in method
2. Enable **Google**
3. Add Google OAuth credentials (Web Client ID)

### Game Center
1. Xcode → Signing & Capabilities
2. Add capability: **Game Center**
3. Firebase Console → Authentication → Enable Game Center

## Step 7: Create AppDelegate & Initialize Firebase

Create `AppDelegate.swift`:

```swift
import UIKit
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
```

Update `15BrushCardsApp.swift`:

```swift
import SwiftUI

@main
struct BrushCardsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Step 8: Add Required Frameworks

Target → Build Phases → Link Binary With Libraries:
- ✅ SpriteKit
- ✅ GameKit (for Game Center)
- ✅ AuthenticationServices
- ✅ FirebaseCore
- ✅ FirebaseDatabase
- ✅ FirebaseAuth

## Next Steps

1. ✅ Project structure ready
2. ⬜ Create GameScene with SpriteKit (next iteration)
3. ⬜ Implement UI/Menu screens
4. ⬜ Complete Firebase integration
5. ⬜ Test multiplayer sync

## Testing Game Logic

To test the card game logic without UI:

```bash
# Create a test file to verify game mechanics
open Tests/GameLogicTests.swift
```

Example test:
```swift
let player = Player(id: "1", name: "Test")
let cards = [Card(suit: .hearts, rank: .seven)]
let tableCards = [Card(suit: .diamonds, rank: .eight)]

let isValid = GameLogicManager.shared.isValidMove(
    playerCard: cards[0],
    tableCards: tableCards,
    selectedTableCards: tableCards
) // Should return true (7 + 8 = 15)
```

## Troubleshooting

**Issue**: "Module not found" errors
- Solution: Close Xcode, run `pod install`, reopen `.xcworkspace`

**Issue**: Firebase not initialized
- Solution: Ensure `AppDelegate` is set and `GoogleService-Info.plist` is added

**Issue**: SpriteKit scenes not rendering
- Solution: Verify `GameScene` inherits from `SKScene`

## File Organization

```
15BrushCards/
├── Sources/
│   ├── Models/          ← Card, Player, GameState
│   ├── Managers/        ← GameLogic, Deck, Game orchestration
│   ├── Services/        ← Firebase, Auth
│   ├── AI/              ← AI opponent logic
│   ├── Scenes/          ← SpriteKit scenes (WIP)
│   └── UI/              ← Custom UI components (WIP)
├── Tests/               ← Unit tests
├── Assets.xcassets/     ← Images, cards, sounds
└── GoogleService-Info.plist
```

## Next Session Tasks

- [ ] Implement `GameScene.swift` with SpriteKit
- [ ] Create card sprite nodes and animations
- [ ] Build menu/navigation UI
- [ ] Test game flow (deal cards, validate moves, update score)
- [ ] Complete Firebase sync for multiplayer
- [ ] Test matchmaking system

---

Ready to build! 🎮
