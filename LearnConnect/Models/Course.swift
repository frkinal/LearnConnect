import Foundation

struct Course: Codable {
    let id: String
    let title: String
    let description: String
    let thumbnailURL: String
    let videos: [Video]
    let category: String
    let keywords: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case thumbnailURL = "thumbnail_url"
        case videos
        case category
        case keywords
    }
}


