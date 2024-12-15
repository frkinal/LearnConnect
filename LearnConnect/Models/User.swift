import Foundation

struct User: Codable {
    let id: String
    let email: String
    let name: String
    var enrolledCourses: [String] // Array of course IDs
    var favorites: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case enrolledCourses
        case favorites
    }
    
    init(id: String = UUID().uuidString,
         email: String,
         name: String,
         enrolledCourses: [String] = [],
         favorites: [String] = []) {
        self.id = id
        self.email = email
        self.name = name
        self.enrolledCourses = enrolledCourses
        self.favorites = favorites
    }
}
