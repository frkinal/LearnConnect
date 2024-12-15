import UIKit

class VideoCell: UITableViewCell {
    // MARK: - Properties
    
    private var video: CourseVideo?
    private let courseService = CourseService.shared
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(with video: CourseVideo) {
        self.video = video
        
        titleLabel.text = video.title
        durationLabel.text = video.duration
        
        accessoryType = .disclosureIndicator
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(durationLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
