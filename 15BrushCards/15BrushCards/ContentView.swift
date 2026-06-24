//
//  ContentView.swift
//  15BrushCards
//
//  Created by Axel Franco Pedroso on 22/06/26.
//

import SwiftUI

struct ContentView: View {
    @State private var gameStarted = false
    @State private var showSpriteKit = false
    @State private var gameMode: String = "singlePlayer"
    @State private var gameStatus = "Pronto para jogar"

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if showSpriteKit {
                GameView()
            } else if !gameStarted {
                menuView
            } else {
                gameView
            }
        }
    }

    private var menuView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("15 Brush Cards")
                    .font(.system(size: 40, weight: .bold))
                Text("Jogo de Cartas")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 60)

            Spacer()

            VStack(spacing: 16) {
                Button(action: {
                    gameMode = "singlePlayer"
                    startGame()
                }) {
                    Label("Jogar vs IA", systemImage: "robot.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Button(action: {
                    gameMode = "multiplayerOnline"
                    startGame()
                }) {
                    Label("Multiplayer Online", systemImage: "network")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            Text("Versão 1.0")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 40)
        }
    }

    private var gameView: some View {
        VStack {
            HStack {
                Text("15 Brush Cards")
                    .font(.headline)
                Spacer()
                Button(action: { gameStarted = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Status do Jogo")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Modo: \(gameMode == "singlePlayer" ? "vs IA" : "Multiplayer")")
                        Text("Jogadores: 2")
                        Text("Cartas na mesa: 4")
                        Text("Cartas no baralho: 32")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)

                    Text("✅ Lógica do jogo está compilando e pronta!")
                        .foregroundColor(.green)
                        .padding(.top, 20)
                        .padding(.horizontal)
                }
                .padding()
            }

            Spacer()

            HStack(spacing: 12) {
                Button(action: {
                    gameStarted = false
                }) {
                    Text("Voltar")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    showSpriteKit = true
                }) {
                    Text("Começar Jogo")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }

    private func startGame() {
        gameMode = gameMode == "singlePlayer" ? "singlePlayer" : "multiplayerOnline"
        gameStarted = true
    }
}

#Preview {
    ContentView()
}
