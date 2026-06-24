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

            GeometryReader { geometry in
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        let sceneHeight = scene.size.height
                        let sceneWidth = scene.size.width
                        let viewHeight = geometry.size.height
                        let viewWidth = geometry.size.width

                        let scaleX = sceneWidth / viewWidth
                        let scaleY = sceneHeight / viewHeight

                        let sceneX = location.x * scaleX
                        let sceneY = (viewHeight - location.y) * scaleY

                        scene.handleSceneTap(at: CGPoint(x: sceneX, y: sceneY))
                    }
            }
        }
        .onAppear {
            scene.onGameOver = {
                dismiss()
            }
        }
    }
}

#Preview {
    GameView()
}
