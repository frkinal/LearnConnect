import Foundation

protocol CourseServiceProtocol {
    func fetchCourses() async throws -> [Course]
    func fetchCourse(by id: String) async throws -> Course
    func registerForCourse(_ courseId: String) async throws -> CourseRegistration
    func unregisterFromCourse(_ courseId: String) async throws
    func isRegisteredForCourse(_ courseId: String) -> Bool
    func searchCourses(query: String, selectedCategory: String?) async throws -> [Course]
    func getRegisteredCourses() async throws -> [Course]
    func getAvailableCategories() -> [String]
    func toggleFavorite(for courseId: String) async throws
    func getFavoriteCourses() async throws -> [Course]
    func isFavorite(_ courseId: String) -> Bool
    func submitReview(_ review: Review) async throws
    func getReviews(for courseId: String) async throws -> [Review]
}

class CourseService: CourseServiceProtocol {
    static let shared = CourseService()
    private let defaults = UserDefaults.standard
    private let authService = AuthService.shared
    
    private var registeredCourses: Set<String> {
        get {
            guard let userId = authService.getCurrentUser()?.id else { return [] }
            let key = "registeredCourses_\(userId)"
            let array = defaults.array(forKey: key) as? [String] ?? []
            return Set(array)
        }
        set {
            guard let userId = authService.getCurrentUser()?.id else { return }
            let key = "registeredCourses_\(userId)"
            defaults.set(Array(newValue), forKey: key)
        }
    }
    
    private let favoritesKey = "favoriteCourses"
    private let reviewsKey = "courseReviews"
    
    private func getFavoriteKey(for userId: String) -> String {
        return "\(favoritesKey)_\(userId)"
    }
    
    private func getReviewsKey(for courseId: String) -> String {
        return "\(reviewsKey)_\(courseId)"
    }
    
    private var favoriteCourseIds: Set<String> {
        get {
            guard let userId = authService.getCurrentUser()?.id else { return [] }
            let key = getFavoriteKey(for: userId)
            let array = UserDefaults.standard.stringArray(forKey: key) ?? []
            return Set(array)
        }
        set {
            guard let userId = authService.getCurrentUser()?.id else { return }
            let key = getFavoriteKey(for: userId)
            UserDefaults.standard.set(Array(newValue), forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    private var allCourses: [Course] = [
        // 1. iOS Development Course
        Course(
            id: "1",
            title: "Complete iOS Development Bootcamp",
            description: "Master iOS development from scratch. Learn Swift, UIKit, and SwiftUI to build professional iOS applications.",
            instructor: "Sarah Johnson",
            thumbnailURL: "https://images.unsplash.com/photo-1621839673705-6617adf9e890?w=800",
            duration: "25 hours",
            level: .beginner,
            category: "iOS Development",
            videos: [
                CourseVideo(id: "1_1", title: "Introduction to iOS Development", duration: "45 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", thumbnailURL: "https://images.unsplash.com/photo-1621839673705-6617adf9e890?w=400"),
                CourseVideo(id: "1_2", title: "Swift Programming Basics", duration: "60 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", thumbnailURL: "https://images.unsplash.com/photo-1544197150-b99a580bb7a8?w=400"),
                CourseVideo(id: "1_3", title: "UIKit Fundamentals", duration: "55 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", thumbnailURL: "https://images.unsplash.com/photo-1556761175-b413da4baf72?w=400"),
                CourseVideo(id: "1_4", title: "SwiftUI Essentials", duration: "50 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4", thumbnailURL: "https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=400"),
                CourseVideo(id: "1_5", title: "Building Your First App", duration: "65 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", thumbnailURL: "https://images.unsplash.com/photo-1556761175-129418cb2dfe?w=400")
            ],
            enrollmentCount: 2500,
            isRegistered: false,
            isFavorite: false,
            averageRating: 4.8,
            reviews: []
        ),
        
        // 2. Web Development Course
        Course(
            id: "2",
            title: "Modern Web Development",
            description: "Learn modern web development with HTML5, CSS3, JavaScript, and popular frameworks.",
            instructor: "Michael Chen",
            thumbnailURL: "https://images.unsplash.com/photo-1627398242454-45a1465c2479?w=800",
            duration: "30 hours",
            level: .intermediate,
            category: "Web Development",
            videos: [
                CourseVideo(id: "2_1", title: "HTML5 and CSS3 Basics", duration: "55 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4", thumbnailURL: "https://images.unsplash.com/photo-1621839673705-6617adf9e890?w=400"),
                CourseVideo(id: "2_2", title: "JavaScript Fundamentals", duration: "65 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4", thumbnailURL: "https://images.unsplash.com/photo-1627398242454-45a1465c2479?w=400"),
                CourseVideo(id: "2_3", title: "Responsive Design", duration: "45 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4", thumbnailURL: "https://images.unsplash.com/photo-1581276879432-15e50529f34b?w=400"),
                CourseVideo(id: "2_4", title: "Modern JavaScript Frameworks", duration: "70 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4", thumbnailURL: "https://images.unsplash.com/photo-1633356122102-3fe601e05bd2?w=400"),
                CourseVideo(id: "2_5", title: "Building Web Applications", duration: "60 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4", thumbnailURL: "https://images.unsplash.com/photo-1547658719-da2b51169166?w=400")
            ],
            enrollmentCount: 3200,
            isRegistered: false,
            isFavorite: false,
            averageRating: 4.7,
            reviews: []
        ),
        
        // 3. UI/UX Design Course
        Course(
            id: "3",
            title: "UI/UX Design Masterclass",
            description: "Master the art of user interface and user experience design. Learn design principles and industry-standard tools.",
            instructor: "Emily Wong",
            thumbnailURL: "https://images.unsplash.com/photo-1586717791821-3f44a563fa4c?w=800",
            duration: "20 hours",
            level: .beginner,
            category: "Design",
            videos: [
                CourseVideo(id: "3_1", title: "Introduction to UI/UX", duration: "50 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4", thumbnailURL: "https://images.unsplash.com/photo-1586717791821-3f44a563fa4c?w=400"),
                CourseVideo(id: "3_2", title: "Design Principles", duration: "55 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4", thumbnailURL: "https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400"),
                CourseVideo(id: "3_3", title: "Figma Essentials", duration: "65 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4", thumbnailURL: "https://images.unsplash.com/photo-1581291518633-83b4ebd1d83e?w=400"),
                CourseVideo(id: "3_4", title: "User Research", duration: "45 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", thumbnailURL: "https://images.unsplash.com/photo-1553028826-f4804a6dba3b?w=400"),
                CourseVideo(id: "3_5", title: "Prototyping", duration: "60 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", thumbnailURL: "https://images.unsplash.com/photo-1554200876-56c2f25224fa?w=400")
            ],
            enrollmentCount: 1800,
            isRegistered: false,
            isFavorite: false,
            averageRating: 4.9,
            reviews: []
        ),
        
        // 4. Data Science Course
        Course(
            id: "4",
            title: "Data Science and Analytics",
            description: "Learn data analysis, visualization, and machine learning using Python and popular data science libraries.",
            instructor: "David Smith",
            thumbnailURL: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800",
            duration: "35 hours",
            level: .intermediate,
            category: "Data Science",
            videos: [
                CourseVideo(id: "4_1", title: "Python for Data Science", duration: "70 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", thumbnailURL: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400"),
                CourseVideo(id: "4_2", title: "Data Analysis with Pandas", duration: "65 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4", thumbnailURL: "https://images.unsplash.com/photo-1518186285589-2f7649de83e0?w=400"),
                CourseVideo(id: "4_3", title: "Data Visualization", duration: "55 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", thumbnailURL: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400"),
                CourseVideo(id: "4_4", title: "Machine Learning Basics", duration: "75 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4", thumbnailURL: "https://images.unsplash.com/photo-1527474305487-b87b222841cc?w=400"),
                CourseVideo(id: "4_5", title: "Predictive Analytics", duration: "60 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4", thumbnailURL: "https://images.unsplash.com/photo-1516321497487-e288fb19713f?w=400")
            ],
            enrollmentCount: 2100,
            isRegistered: false,
            isFavorite: false,
            averageRating: 4.6,
            reviews: []
        ),
        
        // 5. Digital Marketing Course
        Course(
            id: "5",
            title: "Digital Marketing Strategy",
            description: "Master digital marketing strategies including SEO, social media marketing, and content marketing.",
            instructor: "Lisa Anderson",
            thumbnailURL: "https://images.unsplash.com/photo-1432888622747-4eb9a8efeb07?w=800",
            duration: "15 hours",
            level: .beginner,
            category: "Marketing",
            videos: [
                CourseVideo(id: "5_1", title: "Digital Marketing Fundamentals", duration: "45 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4", thumbnailURL: "https://images.unsplash.com/photo-1432888622747-4eb9a8efeb07?w=400"),
                CourseVideo(id: "5_2", title: "SEO Strategies", duration: "55 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4", thumbnailURL: "https://images.unsplash.com/photo-1571677246347-5040e090b16d?w=400"),
                CourseVideo(id: "5_3", title: "Social Media Marketing", duration: "50 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4", thumbnailURL: "https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=400"),
                CourseVideo(id: "5_4", title: "Content Marketing", duration: "60 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4", thumbnailURL: "https://images.unsplash.com/photo-1542744094-24638eff58bb?w=400"),
                CourseVideo(id: "5_5", title: "Analytics and Reporting", duration: "45 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4", thumbnailURL: "https://images.unsplash.com/photo-1460925895917-bafdab827c52f?w=400")
            ],
            enrollmentCount: 2800,
            isRegistered: false,
            isFavorite: false,
            averageRating: 4.5,
            reviews: []
        ),
        
        // 6. Mobile App Design Course
        Course(
            id: "6",
            title: "Mobile App Design",
            description: "Learn to design beautiful and functional mobile applications for iOS and Android platforms.",
            instructor: "Alex Turner",
            thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/design/design.png",
            duration: "22 hours",
            level: .intermediate,
            category: "Design",
            videos: [
                CourseVideo(id: "6_1", title: "Mobile Design Principles", duration: "55 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/design/design.png"),
                CourseVideo(id: "6_2", title: "iOS Design Guidelines", duration: "60 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/ios/ios.png"),
                CourseVideo(id: "6_3", title: "Android Material Design", duration: "65 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/android/android.png"),
                CourseVideo(id: "6_4", title: "App Wireframing", duration: "50 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/wireframing/wireframing.png"),
                CourseVideo(id: "6_5", title: "Design Systems", duration: "55 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/design-systems/design-systems.png")
            ],
            enrollmentCount: 1600,
            isRegistered: false,
            isFavorite: false,
            averageRating: 4.8,
            reviews: []
        ),
        
        // 7. Business Analytics Course
        Course(
            id: "7",
            title: "Business Analytics",
            description: "Master business analytics tools and techniques to make data-driven business decisions.",
            instructor: "Robert Wilson",
            thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/business/business.png",
            duration: "28 hours",
            level: .advanced,
            category: "Business",
            videos: [
                CourseVideo(id: "7_1", title: "Introduction to Business Analytics", duration: "65 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/business/business.png"),
                CourseVideo(id: "7_2", title: "Data Analysis Tools", duration: "70 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/data-analysis/data-analysis.png"),
                CourseVideo(id: "7_3", title: "Statistical Methods", duration: "75 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/statistics/statistics.png"),
                CourseVideo(id: "7_4", title: "Business Intelligence", duration: "60 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/business-intelligence/business-intelligence.png"),
                CourseVideo(id: "7_5", title: "Decision Making", duration: "55 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/decision-making/decision-making.png")
            ],
            enrollmentCount: 1400,
            isRegistered: false,
            isFavorite: false,
            averageRating: 4.6,
            reviews: []
        ),
        
        // 8. Cloud Computing Course
        Course(
            id: "8",
            title: "Cloud Computing Fundamentals",
            description: "Learn cloud computing concepts and practices using AWS, Azure, and Google Cloud Platform.",
            instructor: "James Miller",
            thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/cloud-computing/cloud-computing.png",
            duration: "32 hours",
            level: .intermediate,
            category: "Cloud Computing",
            videos: [
                CourseVideo(id: "8_1", title: "Cloud Computing Basics", duration: "55 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/aws/aws.png"),
                CourseVideo(id: "8_2", title: "AWS Services", duration: "65 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/aws/aws.png"),
                CourseVideo(id: "8_3", title: "Azure Fundamentals", duration: "60 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/azure/azure.png"),
                CourseVideo(id: "8_4", title: "Google Cloud Platform", duration: "70 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/gcp/gcp.png"),
                CourseVideo(id: "8_5", title: "Cloud Security", duration: "55 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/cloud-security/cloud-security.png")
            ],
            enrollmentCount: 1900,
            isRegistered: false,
            isFavorite: false,
            averageRating: 4.7,
            reviews: []
        ),
        
        // 9. Artificial Intelligence Course
        Course(
            id: "9",
            title: "Artificial Intelligence and Machine Learning",
            description: "Explore artificial intelligence concepts and machine learning algorithms with practical applications.",
            instructor: "Maria Garcia",
            thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/ai/ai.png",
            duration: "40 hours",
            level: .advanced,
            category: "Artificial Intelligence",
            videos: [
                CourseVideo(id: "9_1", title: "AI Fundamentals", duration: "75 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/ai/ai.png"),
                CourseVideo(id: "9_2", title: "Machine Learning Algorithms", duration: "80 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/machine-learning/machine-learning.png"),
                CourseVideo(id: "9_3", title: "Neural Networks", duration: "70 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/neural-networks/neural-networks.png"),
                CourseVideo(id: "9_4", title: "Deep Learning", duration: "85 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/deep-learning/deep-learning.png"),
                CourseVideo(id: "9_5", title: "AI Applications", duration: "65 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/ai-applications/ai-applications.png")
            ],
            enrollmentCount: 1700,
            isRegistered: false,
            isFavorite: false,
            averageRating: 4.9,
            reviews: []
        ),
        
        // 10. Cybersecurity Course
        Course(
            id: "10",
            title: "Cybersecurity Essentials",
            description: "Learn fundamental concepts of cybersecurity, including network security, encryption, and ethical hacking.",
            instructor: "Thomas Brown",
            thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/cybersecurity/cybersecurity.png",
            duration: "35 hours",
            level: .intermediate,
            category: "Cybersecurity",
            videos: [
                CourseVideo(id: "10_1", title: "Security Fundamentals", duration: "60 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/cybersecurity/cybersecurity.png"),
                CourseVideo(id: "10_2", title: "Network Security", duration: "70 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/network-security/network-security.png"),
                CourseVideo(id: "10_3", title: "Encryption Methods", duration: "65 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/encryption/encryption.png"),
                CourseVideo(id: "10_4", title: "Ethical Hacking", duration: "75 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/ethical-hacking/ethical-hacking.png"),
                CourseVideo(id: "10_5", title: "Security Best Practices", duration: "55 min", videoURL: "https://storage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4", thumbnailURL: "https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/security-best-practices/security-best-practices.png")
            ],
            enrollmentCount: 2200,
            isRegistered: false,
            isFavorite: false,
            averageRating: 4.8,
            reviews: []
        )
    ]
    
    private init() {}
    
    private func getAllCourses() async throws -> [Course] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return allCourses
    }

    func fetchCourses() async throws -> [Course] {
        // Get current user's enrolled courses
        let enrolledCourseIds = authService.getCurrentUser()?.enrolledCourses ?? []
        
        // Return only non-enrolled courses
        let allCourses = try await getAllCourses()
        return allCourses.filter { !enrolledCourseIds.contains($0.id) }
    }
    
    func fetchCourse(by id: String) async throws -> Course {
        guard let course = allCourses.first(where: { $0.id == id }) else {
            throw CourseError.courseNotFound
        }
        var updatedCourse = course
        updatedCourse.isRegistered = registeredCourses.contains(course.id)
        updatedCourse.isFavorite = favoriteCourseIds.contains(course.id)
        return updatedCourse
    }
    
    func registerForCourse(_ courseId: String) async throws -> CourseRegistration {
        guard let user = authService.getCurrentUser() else {
            throw CourseError.userNotLoggedIn
        }
        
        // Verify course exists
        let course = try await fetchCourse(by: courseId)
        
        // Create registration
        let registration = CourseRegistration(
            userId: user.id,
            courseId: courseId
        )
        
        // Update local storage
        var courses = registeredCourses
        courses.insert(courseId)
        self.registeredCourses = courses
        
        // Update user's enrolled courses
        var updatedUser = user
        if !updatedUser.enrolledCourses.contains(courseId) {
            updatedUser.enrolledCourses.append(courseId)
            authService.updateUser(updatedUser)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("CourseRegistrationChanged"), object: nil)
        return registration
    }
    
    func unregisterFromCourse(_ courseId: String) async throws {
        guard let user = authService.getCurrentUser() else {
            throw CourseError.userNotLoggedIn
        }
        
        // Verify course exists
        try await fetchCourse(by: courseId)
        
        // Update local storage
        var courses = registeredCourses
        courses.remove(courseId)
        self.registeredCourses = courses
        
        // Update user's enrolled courses
        var updatedUser = user
        updatedUser.enrolledCourses.removeAll { $0 == courseId }
        authService.updateUser(updatedUser)
        
        NotificationCenter.default.post(name: NSNotification.Name("CourseRegistrationChanged"), object: nil)
    }
    
    func isRegisteredForCourse(_ courseId: String) -> Bool {
        if let user = authService.getCurrentUser() {
            return user.enrolledCourses.contains(courseId)
        }
        return false
    }
    
    func getRegisteredCourses() async throws -> [Course] {
        guard let user = authService.getCurrentUser() else {
            throw CourseError.userNotLoggedIn
        }
        
        let allCourses = try await getAllCourses()
        return allCourses.filter { user.enrolledCourses.contains($0.id) }
    }
    
    func searchCourses(query: String, selectedCategory: String? = nil) async throws -> [Course] {
        let allCourses = try await fetchCourses()
        let lowercasedQuery = query.lowercased()
        
        return allCourses.filter { course in
            // If category is selected and doesn't match, filter out
            if let selectedCategory = selectedCategory, course.category != selectedCategory {
                return false
            }
            
            // If there's no search query and we passed the category filter, include the course
            if query.isEmpty {
                return true
            }
            
            // Search in all relevant fields
            return course.title.lowercased().contains(lowercasedQuery) ||
                   course.description.lowercased().contains(lowercasedQuery) ||
                   course.instructor.lowercased().contains(lowercasedQuery) ||
                   course.category.lowercased().contains(lowercasedQuery) ||
                   course.level.rawValue.lowercased().contains(lowercasedQuery)
        }
    }
    
    func getAvailableCategories() -> [String] {
        let categories = Set(allCourses.map { $0.category })
        return Array(categories).sorted()
    }
    
    func toggleFavorite(for courseId: String) async throws {
        guard let user = authService.getCurrentUser() else {
            throw CourseError.userNotAuthenticated
        }
        
        // First verify the course exists
        _ = try await fetchCourse(by: courseId)
        
        var favorites = favoriteCourseIds
        if favorites.contains(courseId) {
            favorites.remove(courseId)
        } else {
            favorites.insert(courseId)
        }
        
        self.favoriteCourseIds = favorites
        NotificationCenter.default.post(name: NSNotification.Name("CourseFavoriteChanged"), object: nil)
    }
    
    func getFavoriteCourses() async throws -> [Course] {
        guard let user = authService.getCurrentUser() else {
            throw CourseError.userNotAuthenticated
        }
        
        let allCourses = try await getAllCourses()
        return allCourses.filter { isFavorite($0.id) }
    }
    
    func isFavorite(_ courseId: String) -> Bool {
        return favoriteCourseIds.contains(courseId)
    }
    
    func submitReview(_ review: Review) async throws {
        guard authService.getCurrentUser() != nil else {
            throw CourseError.userNotAuthenticated
        }
        
        // Get existing reviews
        var reviews = try await getReviews(for: review.courseId)
        
        // Check if user already reviewed
        if let existingReviewIndex = reviews.firstIndex(where: { $0.userId == review.userId }) {
            reviews[existingReviewIndex] = review
        } else {
            reviews.append(review)
        }
        
        // Save reviews
        let key = getReviewsKey(for: review.courseId)
        if let encodedData = try? JSONEncoder().encode(reviews) {
            UserDefaults.standard.set(encodedData, forKey: key)
            UserDefaults.standard.synchronize()
        }
        
        // Update course average rating
        let averageRating = Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)
        try await updateCourseRating(courseId: review.courseId, rating: averageRating)
        
        NotificationCenter.default.post(name: NSNotification.Name("CourseReviewsChanged"), object: nil)
    }
    
    func getReviews(for courseId: String) async throws -> [Review] {
        let key = getReviewsKey(for: courseId)
        guard let data = UserDefaults.standard.data(forKey: key),
              let reviews = try? JSONDecoder().decode([Review].self, from: data) else {
            return []
        }
        return reviews.sorted { $0.date > $1.date }
    }
    
    private func updateCourseRating(courseId: String, rating: Double) async throws {
        var course = try await fetchCourse(by: courseId)
        course.averageRating = rating
        try await updateCourse(course)
    }
    
    private func updateCourse(_ course: Course) async throws {
        if let index = allCourses.firstIndex(where: { $0.id == course.id }) {
            allCourses[index] = course
        }
    }
}

enum CourseError: LocalizedError {
    case userNotLoggedIn
    case courseNotFound
    case invalidLocalURL
    case invalidVideoURL
    case registrationFailed
    case userNotAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .userNotLoggedIn:
            return "Please log in to register for courses"
        case .courseNotFound:
            return "Course not found"
        case .invalidLocalURL:
            return "Invalid local URL for video"
        case .invalidVideoURL:
            return "Invalid video URL"
        case .registrationFailed:
            return "Failed to register for the course"
        case .userNotAuthenticated:
            return "Please authenticate to toggle favorite"
        }
    }
}
