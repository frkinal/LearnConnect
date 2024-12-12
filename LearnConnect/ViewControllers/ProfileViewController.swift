import UIKit

class ProfileViewController: UIViewController {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var darkModeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(darkModeSwitchChanged), for: .valueChanged)
        return toggle
    }()
    
    private let darkModeLabel: UILabel = {
        let label = UILabel()
        label.text = "Dark Mode"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUserInfo()
        setupDarkModeState()
    }
    
    private func setupUI() {
        title = "Profile"
        view.backgroundColor = .systemBackground
        
        // Add settings button to navigation bar
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(settingsTapped))
        navigationItem.rightBarButtonItem = settingsButton
        
        view.addSubview(profileImageView)
        view.addSubview(usernameLabel)
        view.addSubview(emailLabel)
        view.addSubview(darkModeLabel)
        view.addSubview(darkModeSwitch)
        view.addSubview(signOutButton)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            darkModeLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 40),
            darkModeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            darkModeSwitch.centerYAnchor.constraint(equalTo: darkModeLabel.centerYAnchor),
            darkModeSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            signOutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Make profile image view circular
        profileImageView.layer.cornerRadius = 60
    }
    
    private func updateUserInfo() {
        if let user = AuthService.shared.getCurrentUser() {
            usernameLabel.text = user.username
            emailLabel.text = user.email
            
            // Load profile image if available
            if let profileImageURL = user.profileImageURL,
               let url = URL(string: profileImageURL) {
                // TODO: Load image using proper image loading library
            }
        }
    }
    
    private func setupDarkModeState() {
        // Set initial state based on current theme
        darkModeSwitch.isOn = ThemeManager.shared.currentTheme == .dark
    }
    
    @objc private func darkModeSwitchChanged() {
        // Update app theme
        ThemeManager.shared.currentTheme = darkModeSwitch.isOn ? .dark : .light
    }
    
    @objc private func settingsTapped() {
        // TODO: Present settings view controller
    }
    
    @objc private func signOutTapped() {
        let alert = UIAlertController(title: "Sign Out",
                                    message: "Are you sure you want to sign out?",
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            do {
                try AuthService.shared.signOut()
                // Present login screen
                let loginVC = LoginViewController()
                loginVC.modalPresentationStyle = .fullScreen
                self?.present(loginVC, animated: true)
            } catch {
                // Show error alert
                print("Sign out error: \(error)")
            }
        })
        
        present(alert, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Update switch state if system appearance changes
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            darkModeSwitch.isOn = ThemeManager.shared.currentTheme == .dark
        }
    }
}
