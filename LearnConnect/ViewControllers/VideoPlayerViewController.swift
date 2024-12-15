import UIKit
import AVKit

class VideoPlayerViewController: UIViewController {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let video: CourseVideo
    private let progressService = VideoProgressService.shared
    private var timeObserverToken: Any?
    
    private lazy var controlsView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var speedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("1x", for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var playerItemObserver: NSKeyValueObservation?
    private var playerObserver: NSKeyValueObservation?
    
    init(video: CourseVideo) {
        self.video = video
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        setupUI()
        setupGestures()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }
    
    private func setupPlayer() {
        guard let url = URL(string: video.videoURL) else { return }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        if let playerLayer = playerLayer {
            view.layer.addSublayer(playerLayer)
        }
        
        // Show loading indicator initially
        loadingIndicator.startAnimating()
        
        // Observe player item status
        playerItemObserver = playerItem.observe(\.status, options: [.new]) { [weak self] playerItem, _ in
            DispatchQueue.main.async {
                switch playerItem.status {
                case .readyToPlay:
                    self?.loadingIndicator.stopAnimating()
                case .failed:
                    self?.loadingIndicator.stopAnimating()
                    self?.showError(message: "Failed to load video")
                default:
                    break
                }
            }
        }
        
        // Observe player timeControlStatus for buffering
        playerObserver = player?.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            DispatchQueue.main.async {
                switch player.timeControlStatus {
                case .waitingToPlayAtSpecifiedRate:
                    self?.loadingIndicator.startAnimating()
                case .playing:
                    self?.loadingIndicator.stopAnimating()
                case .paused:
                    self?.loadingIndicator.stopAnimating()
                @unknown default:
                    break
                }
            }
        }
        
        // Add time observer
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = self.player?.currentItem?.duration.seconds,
                  !duration.isNaN else { return }
            
            let currentTime = time.seconds
            self.progressSlider.value = Float(currentTime / duration)
            self.progressService.saveProgress(for: self.video.id, timestamp: currentTime, duration: duration)
        }
        
        // Restore previous progress
        if let progress = progressService.getProgress(for: video.id) {
            let time = CMTime(seconds: progress.timestamp, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            player?.seek(to: time)
        }
        
        // Start playing
        player?.play()
    }
    
    private func setupGestures() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func handleTap() {
        controlsView.isHidden.toggle()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(closeButton)
        view.addSubview(loadingIndicator)
        view.addSubview(controlsView)
        controlsView.addSubview(playPauseButton)
        controlsView.addSubview(speedButton)
        controlsView.addSubview(progressSlider)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            controlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            controlsView.heightAnchor.constraint(equalToConstant: 100),
            
            playPauseButton.leadingAnchor.constraint(equalTo: controlsView.leadingAnchor, constant: 20),
            playPauseButton.centerYAnchor.constraint(equalTo: controlsView.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 44),
            playPauseButton.heightAnchor.constraint(equalToConstant: 44),
            
            speedButton.trailingAnchor.constraint(equalTo: controlsView.trailingAnchor, constant: -20),
            speedButton.centerYAnchor.constraint(equalTo: controlsView.centerYAnchor),
            speedButton.widthAnchor.constraint(equalToConstant: 44),
            speedButton.heightAnchor.constraint(equalToConstant: 44),
            
            progressSlider.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 20),
            progressSlider.trailingAnchor.constraint(equalTo: speedButton.leadingAnchor, constant: -20),
            progressSlider.centerYAnchor.constraint(equalTo: controlsView.centerYAnchor)
        ])
        
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        speedButton.addTarget(self, action: #selector(speedButtonTapped), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    @objc private func playPauseButtonTapped() {
        if player?.rate == 0 {
            player?.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            player?.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @objc private func speedButtonTapped() {
        let speeds: [Float] = [1.0, 1.5, 2.0]
        let currentSpeed = player?.rate ?? 1.0
        let currentIndex = speeds.firstIndex(of: currentSpeed) ?? 0
        let nextIndex = (currentIndex + 1) % speeds.count
        let newSpeed = speeds[nextIndex]
        
        player?.rate = newSpeed
        speedButton.setTitle("\(newSpeed)x", for: .normal)
    }
    
    @objc private func sliderValueChanged() {
        let time = CMTime(seconds: Double(progressSlider.value), preferredTimescale: 600)
        player?.seek(to: time)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    deinit {
        playerItemObserver?.invalidate()
        playerObserver?.invalidate()
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
