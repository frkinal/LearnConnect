import UIKit
import AVKit

// MARK: - CoursesViewController
class CoursesViewController: UIViewController {
    private var courses: [Course] = []
    private let courseService = CourseService.shared
    private var selectedCategory: String?
    private var categories: [String] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CourseCell.self, forCellWithReuseIdentifier: "CourseCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Search courses"
        controller.obscuresBackgroundDuringPresentation = false
        return controller
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("All Categories", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
        setupCategories()
        fetchCourses()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCourses() // Refresh courses when view appears
    }
    
    private func setupUI() {
        title = "Courses"
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        
        // Add category button to navigation bar
        let categoryBarButton = UIBarButtonItem(customView: categoryButton)
        navigationItem.rightBarButtonItem = categoryBarButton
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupCategories() {
        categories = ["All Categories"] + courseService.getAvailableCategories()
    }
    
    @objc private func categoryButtonTapped() {
        let pickerVC = UIViewController()
        pickerVC.preferredContentSize = CGSize(width: view.bounds.width, height: 216)
        
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 216))
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Set the picker to current selection
        if let currentCategory = selectedCategory,
           let index = categories.firstIndex(of: currentCategory) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
        } else {
            pickerView.selectRow(0, inComponent: 0, animated: false)
        }
        
        pickerVC.view.addSubview(pickerView)
        
        let alert = UIAlertController(title: "Select Category", message: nil, preferredStyle: .actionSheet)
        alert.setValue(pickerVC, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            self?.categorySelected(at: selectedRow)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = categoryButton
            popover.sourceRect = categoryButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func categorySelected(at index: Int) {
        let category = categories[index]
        selectedCategory = category == "All Categories" ? nil : category
        categoryButton.setTitle(category, for: .normal)
        fetchCourses()
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
        fetchCourses()
    }
    
    private func fetchCourses() {
        Task {
            do {
                let searchQuery = searchController.searchBar.text ?? ""
                courses = try await courseService.searchCourses(
                    query: searchQuery,
                    selectedCategory: selectedCategory
                )
                DispatchQueue.main.async { [weak self] in
                    self?.collectionView.reloadData()
                    self?.updateEmptyState()
                }
            } catch {
                print("Error fetching courses: \(error)")
                self.showError(error)
            }
        }
    }
    
    private func updateEmptyState() {
        if courses.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }
    
    private func showEmptyState() {
        let emptyLabel = UILabel()
        emptyLabel.text = "You've enrolled in all available courses!"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.tag = 100 // Tag for identification
        
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func hideEmptyState() {
        view.viewWithTag(100)?.removeFromSuperview()
    }
    
    private func showError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "Error",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource
extension CoursesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseCell", for: indexPath) as? CourseCell else {
            return UICollectionViewCell()
        }
        let course = courses[indexPath.item]
        cell.configure(with: course)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CoursesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let course = courses[indexPath.item]
        let detailVC = CourseDetailViewController(course: course)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CoursesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 60) / 2
        return CGSize(width: width, height: width * 1.5)
    }
}

// MARK: - UISearchBarDelegate
extension CoursesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Task {
            do {
                if searchText.isEmpty {
                    courses = try await courseService.fetchCourses()
                } else {
                    courses = try await courseService.searchCourses(query: searchText)
                }
                collectionView.reloadData()
            } catch {
                print("Search error: \(error)")
            }
        }
    }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate
extension CoursesViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
}
