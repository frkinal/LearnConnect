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
    
    private let nameLabel: UILabel = {
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
    
    private let coursesContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let coursesCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let coursesLabel: UILabel = {
        let label = UILabel()
        label.text = "Enrolled Courses"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        updateUserInfo()
    }
    
    private func setupNavigationBar() {
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(settingsTapped))
        navigationItem.rightBarButtonItem = settingsButton
    }
    
    private func setupUI() {
        title = "Profile"
        view.backgroundColor = .systemBackground
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(coursesContainer)
        
        coursesContainer.addSubview(coursesCountLabel)
        coursesContainer.addSubview(coursesLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            coursesContainer.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 32),
            coursesContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            coursesCountLabel.topAnchor.constraint(equalTo: coursesContainer.topAnchor),
            coursesCountLabel.centerXAnchor.constraint(equalTo: coursesContainer.centerXAnchor),
            
            coursesLabel.topAnchor.constraint(equalTo: coursesCountLabel.bottomAnchor, constant: 4),
            coursesLabel.centerXAnchor.constraint(equalTo: coursesContainer.centerXAnchor),
            coursesLabel.bottomAnchor.constraint(equalTo: coursesContainer.bottomAnchor)
        ])
        
        profileImageView.layer.cornerRadius = 60
    }
    
    private func updateUserInfo() {
        if let user = AuthService.shared.getCurrentUser() {
            nameLabel.text = user.name
            emailLabel.text = user.email
            coursesCountLabel.text = String(user.enrolledCourses.count)
        }
    }
    
    @objc private func settingsTapped() {
        let settingsVC = SettingsViewController()
        settingsVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(settingsVC, animated: true)
    }
}
