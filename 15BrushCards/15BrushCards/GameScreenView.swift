import SwiftUI
import SpriteKit

struct GameScreenView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let skView = SKView()
        let scene = GameScene(size: CGSize(width: 400, height: 896))
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)

        let viewController = UIViewController()
        viewController.view = skView
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct GamePlayView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            GameScreenView()
                .ignoresSafeArea()

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
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                    }
                }
                .padding()

                Spacer()
            }
        }
    }
}

#Preview {
    GamePlayView()
}
