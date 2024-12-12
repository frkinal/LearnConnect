import UIKit
import Foundation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Apply stored theme
        ThemeManager.shared.applyStoredTheme()
        
        // Set initial view controller based on auth state
        if AuthService.shared.getCurrentUser() != nil {
            let mainTabBar = MainTabBarController()
            window?.rootViewController = mainTabBar
        } else {
            let loginVC = LoginViewController()
            let navController = UINavigationController(rootViewController: loginVC)
            window?.rootViewController = navController
        }
        
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
