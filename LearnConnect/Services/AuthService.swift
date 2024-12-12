import Foundation

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, username: String) async throws -> User
    func signOut() throws
    func getCurrentUser() -> User?
}

class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    private var currentUser: User?
    
    private init() {}
    
    func signIn(email: String, password: String) async throws -> User {
        // TODO: Implement actual authentication
        let user = User(
            id: UUID().uuidString,
            email: email,
            profileImageURL: nil,
            username: email.components(separatedBy: "@").first ?? "",
            favorites: []
        )
        currentUser = user
        return user
    }
    
    func signUp(email: String, password: String, username: String) async throws -> User {
        // TODO: Implement actual registration
        let user = User(
            id: UUID().uuidString,
            email: email,
            profileImageURL: nil,
            username: username,
            favorites: []
        )
        currentUser = user
        return user
    }
    
    func signOut() throws {
        currentUser = nil
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
}
