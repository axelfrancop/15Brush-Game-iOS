//
//  ContentView.swift
//  15BrushCards
//
//  Created by Axel Franco Pedroso on 22/06/26.
//

import SwiftUI

struct ContentView: View {
    @State private var gameStarted = false
    @State private var gameMode: GameMode = .singlePlayer
    @StateObject private var gameManager = GameManager()

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if !gameStarted {
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
                    gameMode = .singlePlayer
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
                    gameMode = .multiplayerOnline
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

                    if let gameState = gameManager.gameState {
                        Text("Modo: \(gameState.gameMode.rawValue)")
                        Text("Jogadores: \(gameState.players.count)")
                        Text("Cartas na mesa: \(gameState.tableCards.count)")
                        Text("Cartas no baralho: \(gameState.deck.count)")
                    } else {
                        Text("Inicializando jogo...")
                    }

                    Text("Lógica do jogo está funcionando!")
                        .foregroundColor(.green)
                        .padding(.top, 20)
                }
                .padding()
            }

            Spacer()

            Button(action: {
                gameStarted = false
                gameManager.resetGame()
            }) {
                Text("Voltar ao Menu")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }

    private func startGame() {
        let players = [
            Player(id: "human", name: "Você"),
            Player(id: "ai", name: "IA", isAI: true)
        ]
        gameManager.initializeNewGame(mode: gameMode, players: players)
        gameStarted = true
    }
}

#Preview {
    ContentView()
}
