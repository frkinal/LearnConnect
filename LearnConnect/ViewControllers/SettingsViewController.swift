import UIKit

class SettingsViewController: UIViewController {
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let sections: [(String, [SettingsItem])] = [
        ("Appearance", [.darkMode]),
        ("Account", [.signOut])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].1.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        let item = sections[indexPath.section].1[indexPath.row]
        
        switch item {
        case .darkMode:
            cell.textLabel?.text = "Dark Mode"
            let switchView = UISwitch()
            switchView.isOn = traitCollection.userInterfaceStyle == .dark
            switchView.addTarget(self, action: #selector(darkModeSwitchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            
        case .signOut:
            cell.textLabel?.text = "Sign Out"
            cell.textLabel?.textColor = .systemRed
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].1[indexPath.row]
        if item == .signOut {
            handleSignOut()
        }
    }
    
    @objc private func darkModeSwitchChanged(_ sender: UISwitch) {
        ThemeManager.shared.toggleTheme()
    }
    
    private func handleSignOut() {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            do {
                try AuthService.shared.signOut()
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self?.present(navController, animated: true)
            } catch {
                print("Error signing out: \(error)")
            }
        })
        
        present(alert, animated: true)
    }
}

enum SettingsItem {
    case darkMode
    case signOut
}
