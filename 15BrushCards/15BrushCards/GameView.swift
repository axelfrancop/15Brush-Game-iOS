import SwiftUI
import SpriteKit

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    let scene = GameScene()

    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding()

                Spacer()
            }
        }
    }
}

#Preview {
    GameView()
}
