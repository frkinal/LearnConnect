import Foundation

protocol AuthServiceProtocol {
    var isLoggedIn: Bool { get }
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, name: String) async throws -> User
    func signOut() throws
    func getCurrentUser() -> User?
    func updateUser(_ user: User)
}

class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    private let defaults = UserDefaults.standard
    
    var isLoggedIn: Bool {
        return currentUser != nil
    }
    
    private(set) var currentUser: User? {
        get {
            guard let data = defaults.data(forKey: "currentUser"),
                  let user = try? JSONDecoder().decode(User.self, from: data) else {
                return nil
            }
            return user
        }
        set {
            if let user = newValue,
               let data = try? JSONEncoder().encode(user) {
                defaults.set(data, forKey: "currentUser")
            } else {
                defaults.removeObject(forKey: "currentUser")
            }
        }
    }
    
    private init() {}
    
    func signUp(email: String, password: String, name: String) async throws -> User {
        // Check if email is already in use
        if let existingUserData = defaults.dictionary(forKey: "users") as? [String: Data],
           let _ = existingUserData.values.first(where: { userData in
               if let user = try? JSONDecoder().decode(User.self, from: userData),
                  user.email == email {
                   return true
               }
               return false
           }) {
            throw AuthError.emailAlreadyInUse
        }
        
        // Create new user
        let newUser = User(
            id: UUID().uuidString,
            email: email,
            name: name,
            enrolledCourses: [],
            favorites: []
        )
        
        // Save user to "database"
        var users = getAllUsers()
        if let userData = try? JSONEncoder().encode(newUser) {
            users[newUser.id] = userData
            defaults.set(users, forKey: "users")
        }
        
        // Save password (in a real app, this would be handled by the backend)
        var passwords = defaults.dictionary(forKey: "passwords") as? [String: String] ?? [:]
        passwords[email] = password
        defaults.set(passwords, forKey: "passwords")
        
        // Set as current user
        currentUser = newUser
        
        NotificationCenter.default.post(name: NSNotification.Name("UserDidSignIn"), object: nil)
        
        return newUser
    }
    
    func signIn(email: String, password: String) async throws -> User {
        // Get stored password
        guard let passwords = defaults.dictionary(forKey: "passwords") as? [String: String],
              let storedPassword = passwords[email],
              storedPassword == password else {
            throw AuthError.invalidCredentials
        }
        
        // Find user with matching email
        guard let user = getAllUsers().values
            .compactMap({ try? JSONDecoder().decode(User.self, from: $0) })
            .first(where: { $0.email == email }) else {
            throw AuthError.userNotFound
        }
        
        currentUser = user
        NotificationCenter.default.post(name: NSNotification.Name("UserDidSignIn"), object: nil)
        
        return user
    }
    
    func signOut() throws {
        currentUser = nil
        NotificationCenter.default.post(name: NSNotification.Name("UserDidSignOut"), object: nil)
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func updateUser(_ user: User) {
        // Save updated user
        var users = getAllUsers()
        if let userData = try? JSONEncoder().encode(user) {
            users[user.id] = userData
            defaults.set(users, forKey: "users")
        }
        
        currentUser = user
        NotificationCenter.default.post(name: NSNotification.Name("UserDidUpdate"), object: nil)
    }
    
    private func getAllUsers() -> [String: Data] {
        return defaults.dictionary(forKey: "users") as? [String: Data] ?? [:]
    }
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyInUse
    case userNotFound
    case notSignedIn
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .emailAlreadyInUse:
            return "Email is already in use"
        case .userNotFound:
            return "User not found"
        case .notSignedIn:
            return "Not signed in"
        }
    }
}
