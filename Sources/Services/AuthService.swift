import Foundation
import AuthenticationServices

class AuthService: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?

    static let shared = AuthService()

    override init() {
        super.init()
    }

    // MARK: - Apple Sign In
    func signInWithApple(_ credential: ASAuthorizationAppleIDCredential) {
        let userID = credential.user
        let firstName = credential.fullName?.givenName ?? ""
        let lastName = credential.fullName?.familyName ?? ""
        let email = credential.email ?? ""

        let user = User(
            id: userID,
            name: "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces),
            email: email,
            authProvider: "apple"
        )

        self.currentUser = user
        self.isAuthenticated = true
        self.saveUserToFirebase(user)
    }

    // MARK: - Google Sign In (placeholder)
    func signInWithGoogle(token: String) {
        // TODO: Implement Google Sign In
        // This will be configured with Firebase
    }

    // MARK: - Game Center
    func authenticateWithGameCenter() {
        // TODO: Implement Game Center authentication
    }

    // MARK: - Sign Out
    func signOut() {
        self.currentUser = nil
        self.isAuthenticated = false
        self.removeUserFromFirebase()
    }

    // MARK: - Firebase Integration (Placeholders)
    private func saveUserToFirebase(_ user: User) {
        // TODO: Save user to Firebase
        print("Saving user to Firebase: \(user.name)")
    }

    private func removeUserFromFirebase() {
        // TODO: Remove user from Firebase
        print("Removing user from Firebase")
    }
}

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let authProvider: String
    var friendsList: [String] = []
    var gamesPlayed: Int = 0
    var wins: Int = 0
    var createdAt: Date = Date()
}
