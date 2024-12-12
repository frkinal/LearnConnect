import UIKit
import AVKit

class VideoPlayerViewController: UIViewController {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let video: Video
    
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
    
    init(video: Video) {
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
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        if let playerLayer = playerLayer {
            view.layer.addSublayer(playerLayer)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(controlsView)
        controlsView.addSubview(playPauseButton)
        controlsView.addSubview(speedButton)
        controlsView.addSubview(progressSlider)
        
        NSLayoutConstraint.activate([
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
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        controlsView.isHidden.toggle()
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
    }
}
