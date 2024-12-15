import UIKit

enum Theme: Int {
    case light
    case dark
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}

final class ThemeManager {
    static let shared = ThemeManager()
    private init() {}
    
    private let themeKey = "app_theme"
    
    var currentTheme: Theme {
        get {
            Theme(rawValue: UserDefaults.standard.integer(forKey: themeKey)) ?? .light
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: themeKey)
            applyTheme(newValue)
            NotificationCenter.default.post(name: .themeChanged, object: nil)
        }
    }
    
    func toggleTheme() {
        currentTheme = currentTheme == .light ? .dark : .light
    }
    
    func applyTheme(_ theme: Theme) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = theme.userInterfaceStyle
            }
        }
    }
    
    func applyStoredTheme() {
        applyTheme(currentTheme)
    }
}

extension NSNotification.Name {
    static let themeChanged = NSNotification.Name("ThemeChanged")
}
