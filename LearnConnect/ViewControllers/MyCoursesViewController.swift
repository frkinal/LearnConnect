import UIKit

class MyCoursesViewController: UIViewController {
    private let courseService: CourseService
    private var registeredCourses: [Course] = []
    private var coursesByCategory: [String: [Course]] = [:]
    private var categories: [String] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CourseCell")
        return tableView
    }()
    
    init(courseService: CourseService = CourseService.shared) {
        self.courseService = courseService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRegisteredCourses()
    }
    
    private func setupUI() {
        title = "My Courses"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCourseRegistrationChanged),
            name: NSNotification.Name("CourseRegistrationChanged"),
            object: nil
        )
    }
    
    @objc private func handleCourseRegistrationChanged() {
        loadRegisteredCourses()
    }
    
    private func loadRegisteredCourses() {
        Task {
            do {
                registeredCourses = try await courseService.getRegisteredCourses()
                organizeCoursesByCategory()
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                    self?.updateEmptyState()
                }
            } catch {
                showError(error)
            }
        }
    }
    
    private func organizeCoursesByCategory() {
        // Clear existing data
        coursesByCategory.removeAll()
        
        // Group courses by category
        for course in registeredCourses {
            if coursesByCategory[course.category] == nil {
                coursesByCategory[course.category] = []
            }
            coursesByCategory[course.category]?.append(course)
        }
        
        // Sort categories
        categories = coursesByCategory.keys.sorted()
    }
    
    private func updateEmptyState() {
        if registeredCourses.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "You haven't enrolled in any courses yet"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        tableView.backgroundView = emptyLabel
    }
    
    private func hideEmptyState() {
        tableView.backgroundView = nil
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension MyCoursesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = categories[section]
        return coursesByCategory[category]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath)
        
        let category = categories[indexPath.section]
        guard let courses = coursesByCategory[category] else { return cell }
        let course = courses[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = course.title
        content.secondaryText = course.description
        content.secondaryTextProperties.numberOfLines = 2
        content.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
        content.secondaryTextProperties.font = .systemFont(ofSize: 14)
        
        // Load thumbnail image
        if let url = URL(string: course.thumbnailURL) {
            URLSession.shared.dataTask(with: url) { [weak cell] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        content.image = image
                        content.imageProperties.cornerRadius = 8
                        content.imageProperties.maximumSize = CGSize(width: 60, height: 60)
                        cell?.contentConfiguration = content
                    }
                }
            }.resume()
        }
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MyCoursesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let category = categories[indexPath.section]
        guard let courses = coursesByCategory[category] else { return }
        let course = courses[indexPath.row]
        
        let detailVC = CourseDetailViewController(course: course, courseService: courseService)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
