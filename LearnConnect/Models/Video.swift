import Foundation

struct Video: Codable {
    let id: String
    let title: String
    let description: String
    let duration: TimeInterval
    let videoURL: String
    let thumbnailURL: String
    var isDownloaded: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case duration
        case videoURL = "video_url"
        case thumbnailURL = "thumbnail_url"
        case isDownloaded = "is_downloaded"
    }
}
