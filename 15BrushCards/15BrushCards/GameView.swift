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
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
    }
}

#Preview {
    GameView()
}
