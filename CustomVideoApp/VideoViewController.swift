//
//  VideoViewController.swift
//  CustomVideoApp
//
//  Created by paige shin on 2022/05/12.
//

import UIKit
import AVFoundation

class VideoViewController: UIViewController {

    private lazy var videoView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var dismissButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(cancelButtonDidTouch(_:)), for: .touchUpInside)
        return button
    }()
    
    // video url from previous screen 
    var videoURL: URL?
    private var avPlayerLayer: AVPlayerLayer?
    private let avPlayer: AVPlayer = AVPlayer()
    
    override func loadView() {
        super.loadView()
        videoView.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoView)
        view.addSubview(dismissButton)
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: view.topAnchor),
            videoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.frame = view.bounds
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer!, at: 0)
        view.layoutIfNeeded()
        guard let videoURL = videoURL else {
            dismiss(animated: true)
            return
        }
        let playerItem: AVPlayerItem = AVPlayerItem(url: videoURL)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.play()
    }
    
    @objc
    private func cancelButtonDidTouch(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
