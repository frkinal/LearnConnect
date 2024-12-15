import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupAppearance()
    }
    
    private func setupViewControllers() {
        let coursesVC = UINavigationController(rootViewController: CoursesViewController())
        coursesVC.tabBarItem = UITabBarItem(title: "Courses", image: UIImage(systemName: "book"), tag: 0)
        
        let myCoursesVC = UINavigationController(rootViewController: MyCoursesViewController())
        myCoursesVC.tabBarItem = UITabBarItem(title: "My Courses", image: UIImage(systemName: "books.vertical"), tag: 1)
        
        let favoritesVC = UINavigationController(rootViewController: FavoritesViewController())
        favoritesVC.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart"), tag: 2)
        
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
        
        viewControllers = [coursesVC, myCoursesVC, favoritesVC, profileVC]
    }
    
    private func setupAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .systemBackground
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
