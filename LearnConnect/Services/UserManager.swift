import Foundation

class UserManager {
    static let shared = UserManager()
    private let defaults = UserDefaults.standard
    
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
    
    func setCurrentUser(_ user: User) {
        currentUser = user
    }
    
    func clearCurrentUser() {
        currentUser = nil
    }
    
    func isUserLoggedIn() -> Bool {
        return currentUser != nil
    }
}
