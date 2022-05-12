# CameraViewController

```swift
import UIKit
import AVFoundation

/// Privacy - Microphone Usage Description
/// Privacy - Camera Usage Description
class CameraViewController: UIViewController {
    
    private lazy var camPreview: UIView = {
        let imageView: UIImageView = UIImageView()
        imageView.backgroundColor = .black
        return imageView
    }()
    
    private lazy var thumbnailButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(thumbnailButtonDidTouch(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var captureButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("", for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(captureButtonDidTouch(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - CAMERA SESSION
    private let captureSession: AVCaptureSession = AVCaptureSession()
    private var activeInput: AVCaptureDeviceInput!
    private let movieOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var isSessionSetup: Bool = false
    private var recordedVideoURL: URL?
    private var outputURL: URL!
    
    override func loadView() {
        super.loadView()
        camPreview.translatesAutoresizingMaskIntoConstraints = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        thumbnailButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(camPreview)
        view.addSubview(captureButton)
        view.addSubview(thumbnailButton)
        NSLayoutConstraint.activate([
            camPreview.topAnchor.constraint(equalTo: view.topAnchor),
            camPreview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            camPreview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            camPreview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            captureButton.widthAnchor.constraint(equalToConstant: 80),
            captureButton.heightAnchor.constraint(equalToConstant: 80),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thumbnailButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            thumbnailButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            thumbnailButton.widthAnchor.constraint(equalToConstant: 40),
            thumbnailButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureButton.layer.cornerRadius = captureButton.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isSessionSetup {
            if setupSession() {
                setupPreview()
                startSession()
            }
        } else {
            if !captureSession.isRunning {
                startSession()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            stopSession()
        }
    }
    

}

// MARK: - RECORDINGS
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    private func tempURL() -> URL? {
        let directory: NSString = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path: String = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    private func startRecording() {
        if !movieOutput.isRecording {
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            captureButton.backgroundColor = UIColor.blue
        } else {
            stopRecording()
        }
    }
    
    private func stopRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            captureButton.backgroundColor = UIColor.red
        }
    }
    
    @objc
    private func captureButtonDidTouch(_ sender: UIButton) {
        startRecording()
    }
    
    @objc
    private func thumbnailButtonDidTouch(_ sender: UIButton) {
        guard recordedVideoURL != nil else { return }
        let vc: VideoViewController = VideoViewController()
        vc.videoURL = recordedVideoURL
        present(vc, animated: true)
    }
    
    // AVCaptureFileOutputRecordingDelegate
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error: Error = error {
            #if DEBUG
            print("Error recoding video: \(error.localizedDescription)")
            #endif
            return
        }
        let videoRecorded: URL = outputFileURL
        if let thumbnail: UIImage = videoRecorded.makeThumbnail() {
            thumbnailButton.setBackgroundImage(thumbnail, for: .normal)
        }
        self.recordedVideoURL = videoRecorded
    }
    
    
}

extension URL {
    
    func makeThumbnail() -> UIImage? {
        do {
            let asset: AVURLAsset = AVURLAsset(url: self, options: nil)
            let imgGenerator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage: CGImage = try imgGenerator.copyCGImage(at: CMTime(value: 0, timescale: 1), actualTime: nil)
            let uiImage: UIImage = UIImage(cgImage: cgImage)
            return uiImage
        } catch {
            print("Error generating thumbnail: \(error)")
        }
        return nil
    }
    
}



// MARK: - all functions related with session
extension CameraViewController {
    
    private func startSession() {
        DispatchQueue.main.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func stopSession() {
        DispatchQueue.main.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    private func setupSession() -> Bool {
        
        captureSession.beginConfiguration()
        
        guard let camera: AVCaptureDevice = AVCaptureDevice.default(for: .video) else {
            #if DEBUG
            print("camera for video is not available")
            #endif
            return false
        }
        
        guard let microphone: AVCaptureDevice = AVCaptureDevice.default(for: .audio) else {
            #if DEBUG
            print("microphone is not available")
            #endif
            return false
        }
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Check if camera is available
        do {
            let input: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            } else {
                #if DEBUG
                print("was not able to add input")
                #endif
                captureSession.commitConfiguration()
                return false
            }
        } catch {
            #if DEBUG
            print("Could not get camera device input")
            #endif
            captureSession.commitConfiguration()
            return false
        }
        
        // Check if mic is available
        do {
            let micInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            } else {
                #if DEBUG
                print("was not able to add mic input")
                #endif
                captureSession.commitConfiguration()
                return false
            }
        } catch {
            captureSession.commitConfiguration()
            return false
        }
         
        // Check if movie is available (files)
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        } else {
            #if DEBUG
            print("was not able to add movie output")
            #endif
            captureSession.commitConfiguration()
            return false
        }

        captureSession.commitConfiguration()
        isSessionSetup = true
        
        return true
    }
    
    private func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.connection?.videoOrientation = .portrait
        camPreview.layer.insertSublayer(previewLayer, at: 0)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewLayer.frame = self.camPreview.bounds
        }
    }
    
}

```

# VideoViewController
```swift
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

```
