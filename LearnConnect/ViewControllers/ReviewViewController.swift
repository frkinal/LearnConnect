import UIKit

protocol ReviewViewControllerDelegate: AnyObject {
    func didSubmitReview(_ review: Review)
}

class ReviewViewController: UIViewController {
    weak var delegate: ReviewViewControllerDelegate?
    private let courseId: String
    private let courseService: CourseService
    private let authService: AuthService
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "Rating"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ratingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 1...5 {
            let button = UIButton()
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.tintColor = .systemGray
            button.tag = i
            button.addTarget(self, action: #selector(ratingButtonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }()
    
    private let commentTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private var selectedRating: Int = 0
    
    init(courseId: String, courseService: CourseService, authService: AuthService) {
        self.courseId = courseId
        self.courseService = courseService
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Write a Review"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Submit",
            style: .done,
            target: self,
            action: #selector(submitReview)
        )
        
        view.addSubview(ratingLabel)
        view.addSubview(ratingStackView)
        view.addSubview(commentTextView)
        
        NSLayoutConstraint.activate([
            ratingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            ratingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            ratingStackView.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 12),
            ratingStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ratingStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ratingStackView.heightAnchor.constraint(equalToConstant: 44),
            
            commentTextView.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 20),
            commentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            commentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            commentTextView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    @objc private func ratingButtonTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateRatingButtons()
    }
    
    private func updateRatingButtons() {
        for case let button as UIButton in ratingStackView.arrangedSubviews {
            let imageName = button.tag <= selectedRating ? "star.fill" : "star"
            button.setImage(UIImage(systemName: imageName), for: .normal)
            button.tintColor = button.tag <= selectedRating ? .systemYellow : .systemGray
        }
    }
    
    @objc private func submitReview() {
        guard let user = authService.getCurrentUser() else {
            showError(message: "Please log in to submit a review")
            return
        }
        
        guard selectedRating > 0 else {
            showError(message: "Please select a rating")
            return
        }
        
        let comment = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !comment.isEmpty else {
            showError(message: "Please write a comment")
            return
        }
        
        let review = Review(
            userId: user.id,
            userName: user.name,
            courseId: courseId,
            rating: selectedRating,
            comment: comment
        )
        
        Task {
            do {
                try await courseService.submitReview(review)
                delegate?.didSubmitReview(review)
                dismiss(animated: true)
            } catch {
                showError(error)
            }
        }
    }
    
    private func showError(_ error: Error) {
        showError(message: error.localizedDescription)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
