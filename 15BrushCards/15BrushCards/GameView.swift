import SwiftUI
import SpriteKit

struct GameView: View {
    @State private var scene: GameScene
    @Environment(\.dismiss) var dismiss

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
        .onAppear {
            scene.onGameOver = {
                dismiss()
            }
        }
    }
}

struct InteractiveCardOverlay: View {
    let scene: GameScene

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        let sceneSize = geometry.size
                        let sceneLoc = CGPoint(x: location.x, y: sceneSize.height - location.y)

                        scene.handleButtonTap(at: sceneLoc)
                        scene.handleGameOverTap()
                    }

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
