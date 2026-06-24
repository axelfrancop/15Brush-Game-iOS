//
//  ContentView.swift
//  15BrushCards
//
//  Created by Axel Franco Pedroso on 22/06/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showGame = false

    var body: some View {
        if showGame {
            GameView()
                .transition(.move(edge: .trailing))
        } else {
            menuView
                .transition(.move(edge: .leading))
        }
    }

    private var menuView: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

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
                        showGame = true
                    }) {
                        Label("Jogar vs IA", systemImage: "robot.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        showGame = true
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
    }
}

#Preview {
    ContentView()
}
