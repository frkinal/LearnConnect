import Foundation

protocol ReviewServiceProtocol {
    func addReview(courseId: String, rating: Int, comment: String) async throws
    func getReviews(for courseId: String) async throws -> [Review]
    func deleteReview(courseId: String, reviewId: String) async throws
    func updateReview(courseId: String, reviewId: String, rating: Int, comment: String) async throws
}

class ReviewService: ReviewServiceProtocol {
    static let shared = ReviewService()
    private let defaults = UserDefaults.standard
    private let courseService: CourseService
    private let authService: AuthService
    
    private init(courseService: CourseService = .shared, authService: AuthService = .shared) {
        self.courseService = courseService
        self.authService = authService
    }
    
    // MARK: - Review Management
    
    func addReview(courseId: String, rating: Int, comment: String) async throws {
        guard let currentUser = authService.currentUser else {
            throw ReviewError.userNotAuthenticated
        }
        
        let review = Review(
            userId: currentUser.id,
            userName: currentUser.name,
            courseId: courseId,
            rating: rating,
            comment: comment
        )
        
        // Get existing reviews
        var reviews = try await getReviews(for: courseId)
        
        // Check if user already reviewed
        if let existingIndex = reviews.firstIndex(where: { $0.userId == currentUser.id }) {
            reviews[existingIndex] = review
        } else {
            reviews.append(review)
        }
        
        // Save reviews
        saveReviews(reviews, for: courseId)
        
        // Update course average rating
        updateCourseRating(courseId: courseId, reviews: reviews)
        
        // Post notification for UI update
        NotificationCenter.default.post(name: NSNotification.Name("CourseReviewsChanged"), object: nil)
    }
    
    func getReviews(for courseId: String) async throws -> [Review] {
        let key = "reviews_\(courseId)"
        guard let data = defaults.data(forKey: key),
              let reviews = try? JSONDecoder().decode([Review].self, from: data) else {
            return []
        }
        return reviews
    }
    
    func deleteReview(courseId: String, reviewId: String) async throws {
        var reviews = try await getReviews(for: courseId)
        reviews.removeAll { $0.id == reviewId }
        
        saveReviews(reviews, for: courseId)
        updateCourseRating(courseId: courseId, reviews: reviews)
        
        NotificationCenter.default.post(name: NSNotification.Name("CourseReviewsChanged"), object: nil)
    }
    
    func updateReview(courseId: String, reviewId: String, rating: Int, comment: String) async throws {
        var reviews = try await getReviews(for: courseId)
        guard let index = reviews.firstIndex(where: { $0.id == reviewId }) else {
            throw ReviewError.reviewNotFound
        }
        
        let updatedReview = Review(
            id: reviewId,
            userId: reviews[index].userId,
            userName: reviews[index].userName,
            courseId: courseId,
            rating: rating,
            comment: comment
        )
        
        reviews[index] = updatedReview
        saveReviews(reviews, for: courseId)
        updateCourseRating(courseId: courseId, reviews: reviews)
        
        NotificationCenter.default.post(name: NSNotification.Name("CourseReviewsChanged"), object: nil)
    }
    
    // MARK: - Private Helpers
    
    private func saveReviews(_ reviews: [Review], for courseId: String) {
        let key = "reviews_\(courseId)"
        if let encoded = try? JSONEncoder().encode(reviews) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    private func updateCourseRating(courseId: String, reviews: [Review]) {
        let averageRating = calculateAverageRating(reviews)
        // Update course average rating in CourseService
        // This would typically update the backend in a real app
    }
    
    private func calculateAverageRating(_ reviews: [Review]) -> Double {
        guard !reviews.isEmpty else { return 0.0 }
        let sum = reviews.reduce(0) { $0 + Double($1.rating) }
        return sum / Double(reviews.count)
    }
}

enum ReviewError: LocalizedError {
    case userNotAuthenticated
    case reviewNotFound
    case invalidRating
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "You must be logged in to leave a review"
        case .reviewNotFound:
            return "Review not found"
        case .invalidRating:
            return "Invalid rating value"
        }
    }
}
