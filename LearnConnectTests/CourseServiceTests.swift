import XCTest
@testable import LearnConnect

final class CourseServiceTests: XCTestCase {
    var courseService: CourseService!
    var authService: AuthService!
    let testUserId = "test_user_id"
    let testCourseId = "1" // Using the first course from our mock data
    
    override func setUp() {
        super.setUp()
        courseService = CourseService.shared
        authService = AuthService.shared
        
        // Log in a test user
        let testUser = User(id: testUserId, email: "test@example.com", name: "Test User")
        authService.setCurrentUser(testUser)
    }
    
    override func tearDown() {
        // Clean up user defaults after each test
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "registeredCourses_\(testUserId)")
        userDefaults.removeObject(forKey: "favoriteCourses_\(testUserId)")
        userDefaults.synchronize()
        
        authService.logout()
        super.tearDown()
    }
    
    // MARK: - Course Registration Tests
    
    func testRegisterForCourse() async throws {
        // Given
        XCTAssertFalse(courseService.isRegisteredForCourse(testCourseId), "Course should not be registered initially")
        
        // When
        let registration = try await courseService.registerForCourse(testCourseId)
        
        // Then
        XCTAssertTrue(courseService.isRegisteredForCourse(testCourseId), "Course should be registered after registration")
        XCTAssertEqual(registration.userId, testUserId, "Registration should have correct user ID")
        XCTAssertEqual(registration.courseId, testCourseId, "Registration should have correct course ID")
    }
    
    func testUnregisterFromCourse() async throws {
        // Given
        _ = try await courseService.registerForCourse(testCourseId)
        XCTAssertTrue(courseService.isRegisteredForCourse(testCourseId), "Course should be registered initially")
        
        // When
        try await courseService.unregisterFromCourse(testCourseId)
        
        // Then
        XCTAssertFalse(courseService.isRegisteredForCourse(testCourseId), "Course should not be registered after unregistration")
    }
    
    func testRegisterForCourseWithoutAuth() async {
        // Given
        authService.logout()
        
        // When/Then
        do {
            _ = try await courseService.registerForCourse(testCourseId)
            XCTFail("Should throw an error when user is not authenticated")
        } catch {
            XCTAssertEqual(error as? CourseError, CourseError.userNotAuthenticated, "Should throw userNotAuthenticated error")
        }
    }
    
    // MARK: - Favorite Course Tests
    
    func testToggleFavorite() async throws {
        // Given
        XCTAssertFalse(courseService.isFavorite(testCourseId), "Course should not be favorite initially")
        
        // When
        try await courseService.toggleFavorite(for: testCourseId)
        
        // Then
        XCTAssertTrue(courseService.isFavorite(testCourseId), "Course should be favorite after toggling")
        
        // When toggling again
        try await courseService.toggleFavorite(for: testCourseId)
        
        // Then
        XCTAssertFalse(courseService.isFavorite(testCourseId), "Course should not be favorite after toggling again")
    }
    
    func testToggleFavoriteWithoutAuth() async {
        // Given
        authService.logout()
        
        // When/Then
        do {
            try await courseService.toggleFavorite(for: testCourseId)
            XCTFail("Should throw an error when user is not authenticated")
        } catch {
            XCTAssertEqual(error as? CourseError, CourseError.userNotAuthenticated, "Should throw userNotAuthenticated error")
        }
    }
    
    func testGetFavoriteCourses() async throws {
        // Given
        try await courseService.toggleFavorite(for: testCourseId)
        
        // When
        let favoriteCourses = try await courseService.getFavoriteCourses()
        
        // Then
        XCTAssertFalse(favoriteCourses.isEmpty, "Should have favorite courses")
        XCTAssertTrue(favoriteCourses.contains { $0.id == testCourseId }, "Should contain the favorited course")
    }
    
    // MARK: - Helper Methods
    
    private func clearUserDefaults() {
        let userDefaults = UserDefaults.standard
        userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        userDefaults.synchronize()
    }
}
