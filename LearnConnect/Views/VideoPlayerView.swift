import UIKit
import WebKit

class VideoPlayerView: UIViewController {
    private let videoId: String
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .black
        return webView
    }()
    
    init(videoId: String) {
        self.videoId = videoId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadVideo()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalTo: webView.widthAnchor, multiplier: 9.0/16.0)
        ])
    }
    
    private func loadVideo() {
        guard let videoURL = URL(string: "https://www.youtube.com/embed/\(videoId)?playsinline=1") else { return }
        let request = URLRequest(url: videoURL)
        webView.load(request)
    }
}
