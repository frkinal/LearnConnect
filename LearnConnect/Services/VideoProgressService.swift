import Foundation

class VideoProgressService {
    static let shared = VideoProgressService()
    private let defaults = UserDefaults.standard
    private let progressKey = "video_progress"
    
    private init() {}
    
    struct VideoProgress: Codable {
        let videoId: String
        let timestamp: Double
        let duration: Double
        let lastUpdated: Date
        
        var progress: Double {
            return timestamp / duration
        }
    }
    
    private var progressDict: [String: VideoProgress] {
        get {
            guard let data = defaults.data(forKey: progressKey),
                  let dict = try? JSONDecoder().decode([String: VideoProgress].self, from: data) else {
                return [:]
            }
            return dict
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: progressKey)
            }
        }
    }
    
    func saveProgress(for videoId: String, timestamp: Double, duration: Double) {
        let progress = VideoProgress(
            videoId: videoId,
            timestamp: timestamp,
            duration: duration,
            lastUpdated: Date()
        )
        var dict = progressDict
        dict[videoId] = progress
        progressDict = dict
    }
    
    func getProgress(for videoId: String) -> VideoProgress? {
        return progressDict[videoId]
    }
    
    func clearProgress(for videoId: String) {
        var dict = progressDict
        dict.removeValue(forKey: videoId)
        progressDict = dict
    }
    
    func getFormattedProgress(for videoId: String) -> String {
        guard let progress = getProgress(for: videoId) else {
            return "Not started"
        }
        
        let percentage = Int(progress.progress * 100)
        if percentage == 100 {
            return "Completed"
        } else {
            return "\(percentage)% completed"
        }
    }
}
