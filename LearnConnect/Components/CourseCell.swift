import UIKit

class CourseCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.backgroundColor = .systemBlue
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(instructorLabel)
        contentView.addSubview(durationLabel)
        contentView.addSubview(levelLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            instructorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            instructorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            instructorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            durationLabel.topAnchor.constraint(equalTo: instructorLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            levelLabel.centerYAnchor.constraint(equalTo: durationLabel.centerYAnchor),
            levelLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            levelLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            levelLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with course: Course) {
        titleLabel.text = course.title
        instructorLabel.text = course.instructor
        durationLabel.text = course.duration
        levelLabel.text = course.level.rawValue
        
        // Load image from URL (you might want to use a proper image loading library like SDWebImage or Kingfisher)
        if let url = URL(string: course.thumbnailURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }.resume()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
        instructorLabel.text = nil
        durationLabel.text = nil
        levelLabel.text = nil
    }
}
