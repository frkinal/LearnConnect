import UIKit
import AVKit

// MARK: - CourseDetailViewController
final class CourseDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ReviewViewControllerDelegate {
    // MARK: - Properties
    
    private var course: Course {
        didSet {
            configureUI()
        }
    }
    private let courseService: CourseService
    private let reviewService: ReviewService
    private let authService = AuthService.shared
    
    private var reviews: [Review] = [] {
        didSet {
            reviewsTableView.reloadData()
            updateReviewsHeader()
        }
    }
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var reviewsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: "ReviewCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private lazy var registerBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Register",
            style: .done,
            target: self,
            action: #selector(registerButtonTapped)
        )
        button.tintColor = .systemBlue
        return button
    }()
    
    private lazy var favoriteButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(favoriteButtonTapped)
        )
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let instructorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let enrollmentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let reviewsHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "Reviews"
        return label
    }()
    
    private let videosHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.text = "Course Content"
        return label
    }()
    
    private lazy var addReviewButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Write a Review", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.addTarget(self, action: #selector(addReviewTapped), for: .touchUpInside)
        return button
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var videosTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(VideoCell.self, forCellReuseIdentifier: "VideoCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false // Since it's inside a scroll view
        return tableView
    }()
    
    // MARK: - Initialization
    
    init(course: Course, courseService: CourseService = CourseService.shared) {
        self.course = course
        self.courseService = courseService
        self.reviewService = ReviewService.shared
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadReviews()
        updateFavoriteButtonState()
        updateRegisterButtonState()
        
        reviewsTableView.dataSource = self
        reviewsTableView.delegate = self
        
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Video Playback
    
    private func playVideo(video: CourseVideo) {
        guard let url = URL(string: video.videoURL) else {
            showAlert(title: "Error", message: "Invalid video URL")
            return
        }
        
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    // MARK: - Review Management
    
    private func loadReviews() {
        Task {
            do {
                reviews = try await reviewService.getReviews(for: course.id)
                updateReviewsHeader()
            } catch {
                showAlert(title: "Error", message: "Failed to load reviews: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateReviewsHeader() {
        let averageRating = course.averageRating
        let reviewCount = reviews.count
        let ratingText = String(format: "%.1f", averageRating)
        reviewsHeaderLabel.text = "\(reviewCount) Reviews (\(ratingText)★)"
    }
    
    @objc private func addReviewTapped() {
        guard let user = authService.getCurrentUser() else {
            showAlert(title: "Authentication Required", message: "Please log in to submit a review")
            return
        }
        
        let reviewVC = ReviewViewController(courseId: course.id, courseService: courseService, authService: authService)
        reviewVC.delegate = self
        let navController = UINavigationController(rootViewController: reviewVC)
        present(navController, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView == reviewsTableView ? 1 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == reviewsTableView {
            return reviews.count
        } else {
            return course.videos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == reviewsTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewCell else {
                return UITableViewCell()
            }
            let review = reviews[indexPath.row]
            cell.configure(with: review)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as? VideoCell else {
                return UITableViewCell()
            }
            let video = course.videos[indexPath.row]
            cell.configure(with: video)
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == videosTableView {
            let video = course.videos[indexPath.row]
            playVideo(video: video)
        }
    }
    
    // MARK: - ReviewViewControllerDelegate
    
    func didSubmitReview(_ review: Review) {
        reviews.append(review)
        course.reviews.append(review)
        reviewsTableView.reloadData()
        updateReviewsHeader()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(instructorLabel)
        contentView.addSubview(levelLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(enrollmentLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(videosHeaderLabel)
        contentView.addSubview(videosTableView)
        contentView.addSubview(reviewsHeaderLabel)
        contentView.addSubview(addReviewButton)
        contentView.addSubview(reviewsTableView)
        contentView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 9/16),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            instructorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            instructorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            instructorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            levelLabel.topAnchor.constraint(equalTo: instructorLabel.bottomAnchor, constant: 8),
            levelLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            durationLabel.topAnchor.constraint(equalTo: levelLabel.topAnchor),
            durationLabel.leadingAnchor.constraint(equalTo: levelLabel.trailingAnchor, constant: 16),
            
            categoryLabel.topAnchor.constraint(equalTo: levelLabel.topAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: durationLabel.trailingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            enrollmentLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 8),
            enrollmentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            enrollmentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: enrollmentLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            videosHeaderLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            videosHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            videosHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            videosTableView.topAnchor.constraint(equalTo: videosHeaderLabel.bottomAnchor, constant: 8),
            videosTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videosTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            videosTableView.heightAnchor.constraint(equalToConstant: CGFloat(course.videos.count * 70)),
            
            reviewsHeaderLabel.topAnchor.constraint(equalTo: videosTableView.bottomAnchor, constant: 24),
            reviewsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewsHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            addReviewButton.topAnchor.constraint(equalTo: reviewsHeaderLabel.bottomAnchor, constant: 16),
            addReviewButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            reviewsTableView.topAnchor.constraint(equalTo: addReviewButton.bottomAnchor, constant: 16),
            reviewsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            reviewsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            reviewsTableView.heightAnchor.constraint(equalToConstant: 400),
            reviewsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        configureUI()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [registerBarButton, favoriteButton]
        title = course.title
    }
    
    private func configureUI() {
        // Configure course details
        titleLabel.text = course.title
        descriptionLabel.text = course.description
        instructorLabel.text = "Instructor: \(course.instructor)"
        durationLabel.text = "Duration: \(course.duration)"
        levelLabel.text = "Level: \(course.level.rawValue)"
        categoryLabel.text = "Category: \(course.category)"
        enrollmentLabel.text = "\(course.enrollmentCount) students enrolled"
        
        // Configure buttons state
        updateRegisterButtonState()
        updateFavoriteButtonState()
        
        // Configure tables
        reviewsTableView.reloadData()
        videosTableView.reloadData()
        updateReviewsHeader()
        
        // Load thumbnail with loading indicator
        loadingIndicator.startAnimating()
        thumbnailImageView.image = nil // Clear previous image
        
        if let url = URL(string: course.thumbnailURL) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    
                    if let error = error {
                        print("Failed to load image: \(error.localizedDescription)")
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        self.thumbnailImageView.image = image
                    } else {
                        print("Could not load image data")
                    }
                }
            }
            task.resume()
        }
    }
    
    private func updateRegisterButtonState() {
        registerBarButton.title = courseService.isRegisteredForCourse(course.id) ? "Unregister" : "Register"
    }
    
    private func updateFavoriteButtonState() {
        let isFavorite = courseService.isFavorite(course.id)
        let imageName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.image = UIImage(systemName: imageName)
    }
    
    @objc private func registerButtonTapped() {
        Task {
            do {
                if courseService.isRegisteredForCourse(course.id) {
                    try await courseService.unregisterFromCourse(course.id)
                } else {
                    _ = try await courseService.registerForCourse(course.id)
                }
                updateRegisterButtonState()
            } catch {
                showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func favoriteButtonTapped() {
        Task {
            do {
                try await courseService.toggleFavorite(for: course.id)
                updateFavoriteButtonState()
            } catch {
                showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
