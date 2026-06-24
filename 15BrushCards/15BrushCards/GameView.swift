import SwiftUI
import SpriteKit

struct GameView: View {
    let scene: GameScene

    init() {
        let gameScene = GameScene()
        gameScene.scaleMode = .resizeFill
        self.scene = gameScene
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    GameView()
}
