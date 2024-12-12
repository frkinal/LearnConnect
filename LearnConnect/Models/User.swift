import Foundation

struct User: Codable {
    let id: String
    let email: String
    var profileImageURL: String?
    var username: String
    var favorites: [String] 
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case profileImageURL = "profile_image_url"
        case username
        case favorites
    }
}
