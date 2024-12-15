import Foundation

struct Review: Codable, Identifiable {
    let id: String
    let userId: String
    let userName: String
    let courseId: String
    let rating: Int
    let comment: String
    let date: Date
    
    init(id: String = UUID().uuidString,
         userId: String,
         userName: String,
         courseId: String,
         rating: Int,
         comment: String,
         date: Date = Date()) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.courseId = courseId
        self.rating = rating
        self.comment = comment
        self.date = date
    }
}
