import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    // Replace with your YouTube API key
    private let apiKey = "AIzaSyAW_grnnKHoU6ELvLeuMvT-DOSEoaYbvKQ"
    private let baseURL = "https://www.googleapis.com/youtube/v3"
    
    func searchVideos(query: String, completion: @escaping (Result<[Video], Error>) -> Void) {
        let searchURL = "\(baseURL)/search?part=snippet&q=\(query)&type=video&key=\(apiKey)"
        
        guard let url = URL(string: searchURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(YouTubeSearchResponse.self, from: data)
                let videos = result.items.map { item in
                    Video(
                        id: item.id.videoId,
                        title: item.snippet.title,
                        description: item.snippet.description,
                        duration: 60,
                        videoURL: "videoURL",
                        thumbnailURL: item.snippet.thumbnails.medium.url,
                        isDownloaded: false
                      
                    )
                }
                completion(.success(videos))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

// YouTube API Response Models
struct YouTubeSearchResponse: Codable {
    let items: [YouTubeSearchItem]
}

struct YouTubeSearchItem: Codable {
    let id: VideoID
    let snippet: VideoSnippet
}

struct VideoID: Codable {
    let videoId: String
}

struct VideoSnippet: Codable {
    let title: String
    let description: String
    let thumbnails: Thumbnails
}

struct Thumbnails: Codable {
    let medium: Thumbnail
}

struct Thumbnail: Codable {
    let url: String
}
