import Foundation

struct Course: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let instructor: String
    let thumbnailURL: String
    let duration: String
    let level: CourseLevel
    let category: String
    var videos: [CourseVideo]
    let enrollmentCount: Int
    var isRegistered: Bool
    var isFavorite: Bool
    var averageRating: Double
    var reviews: [Review]
    
    init(id: String,
         title: String,
         description: String,
         instructor: String,
         thumbnailURL: String,
         duration: String,
         level: CourseLevel,
         category: String,
         videos: [CourseVideo],
         enrollmentCount: Int = 0,
         isRegistered: Bool = false,
         isFavorite: Bool = false,
         averageRating: Double = 0.0,
         reviews: [Review] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.instructor = instructor
        self.thumbnailURL = thumbnailURL
        self.duration = duration
        self.level = level
        self.category = category
        self.videos = videos
        self.enrollmentCount = enrollmentCount
        self.isRegistered = isRegistered
        self.isFavorite = isFavorite
        self.averageRating = averageRating
        self.reviews = reviews
    }
    
    enum CourseLevel: String, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
}

struct CourseVideo: Codable {
    let id: String
    let title: String
    let duration: String
    let videoURL: String
    let thumbnailURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case duration
        case videoURL
        case thumbnailURL
    }
}

struct CourseRegistration: Codable {
    let userId: String
    let courseId: String
    let registrationDate: Date
    
    init(userId: String, courseId: String, registrationDate: Date = Date()) {
        self.userId = userId
        self.courseId = courseId
        self.registrationDate = registrationDate
    }
}
