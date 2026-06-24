import SwiftUI
import SpriteKit

struct GameView: View {
    @State private var scene: GameScene

    init() {
        let gameScene = GameScene()
        gameScene.scaleMode = .resizeFill
        _scene = State(initialValue: gameScene)
    }

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            InteractiveCardOverlay(scene: scene)
        }
    }
}

struct InteractiveCardOverlay: View {
    let scene: GameScene
    @State private var tappedCardId: String?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(scene.cardNodes, id: \.cardId) { cardNode in
                    Color.clear
                        .frame(width: 60, height: 90)
                        .position(x: cardNode.position.x, y: cardNode.position.y)
                        .onTapGesture {
                            scene.handleCardTap(cardNode)
                        }
                }
            }
        }
    }
}

#Preview {
    GameView()
}
