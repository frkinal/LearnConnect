import UIKit

class CoursesViewController: UIViewController {
    
    private var courses: [Course] = []
    private let courseService = CourseService.shared
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchCourses()
    }
    
    private func setupUI() {
        title = "Courses"
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchCourses() {
        Task {
            do {
                courses = try await courseService.fetchCourses()
                collectionView.reloadData()
            } catch {
                // Show error alert
                print("Error fetching courses: \(error)")
            }
        }
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
