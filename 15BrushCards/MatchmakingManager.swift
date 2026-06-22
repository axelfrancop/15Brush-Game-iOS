import Foundation

enum MatchmakingStatus {
    case idle
    case searching
    case found
    case timeout
}

class MatchmakingManager: ObservableObject {
    @Published var status: MatchmakingStatus = .idle
    @Published var searchProgress: Double = 0
    @Published var foundOpponent: User?
    @Published var errorMessage: String?

    static let shared = MatchmakingManager()

    private let firebaseService = FirebaseService.shared
    private var searchTimer: Timer?
    private let searchTimeoutInterval: TimeInterval = 30

    func startSearching(for user: User, gameMode: GameMode) {
        status = .searching
        searchProgress = 0
        firebaseService.addToMatchmakingQueue(userID: user.id, gameMode: gameMode)

        startSearchTimer()
        pollForMatch(userID: user.id)
    }

    func cancelSearch(for userID: String) {
        status = .idle
        searchProgress = 0
        searchTimer?.invalidate()
        firebaseService.removeFromMatchmakingQueue(userID: userID)
    }

    private func startSearchTimer() {
        var elapsedTime: TimeInterval = 0

        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            elapsedTime += 0.1
            self?.searchProgress = min(elapsedTime / 30, 1.0)

            if elapsedTime >= 30 {
                self?.searchTimer?.invalidate()
                self?.status = .timeout
                self?.errorMessage = "Search timed out. Please try again."
            }
        }
    }

    private func pollForMatch(userID: String) {
        firebaseService.findMatch(userID: userID) { [weak self] opponentID in
            guard let self = self else { return }

            if let opponentID = opponentID {
                self.searchTimer?.invalidate()
                self.status = .found

                // Fetch opponent details
                FirebaseService.shared.fetchPlayer(playerID: opponentID) { opponent in
                    if let opponent = opponent {
                        DispatchQueue.main.async {
                            self.foundOpponent = User(
                                id: opponent.id,
                                name: opponent.name,
                                email: "",
                                authProvider: ""
                            )
                        }
                    }
                }
            } else if self.status == .searching {
                // Continue polling
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.pollForMatch(userID: userID)
                }
            }
        }
    }

    func createGameWithOpponent() -> GameState? {
        guard let opponent = foundOpponent else { return nil }

        let currentUser = AuthService.shared.currentUser ?? User(id: "", name: "Player 1", email: "", authProvider: "")
        var gameState = GameState(
            gameID: UUID().uuidString,
            players: [
                Player(id: currentUser.id, name: currentUser.name),
                Player(id: opponent.id, name: opponent.name)
            ],
            deck: DeckManager.shared.createStandardDeck(),
            gameMode: .multiplayerOnline
        )

        // Deal initial cards
        var deck = gameState.deck
        for index in gameState.players.indices {
            gameState.players[index].hand = DeckManager.shared.dealCards(from: &deck, count: 3)
        }
        gameState.tableCards = DeckManager.shared.dealCards(from: &deck, count: 4)
        gameState.deck = deck

        return gameState
    }

    func inviteFriend(_ friend: User, gameMode: GameMode) {
        guard let currentUser = AuthService.shared.currentUser else { return }
        firebaseService.inviteFriend(fromUserID: currentUser.id, toUserID: friend.id)
    }

    func acceptFriendInvitation(gameID: String) {
        guard let currentUser = AuthService.shared.currentUser else { return }
        firebaseService.acceptGameInvitation(gameID: gameID, userID: currentUser.id)
    }
}
