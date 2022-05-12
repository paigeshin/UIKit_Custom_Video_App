# UIKit_CustomCameraApp


```swift

import UIKit
import AVFoundation


class ViewController: UIViewController {

    private let captureSession: AVCaptureSession = AVCaptureSession() // coordinates between input device(video footage) and output device(photo)
    private var photoOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    private var isSessionSetUp: Bool = false
    private var activeInput: AVCaptureDeviceInput!
    private var capturedImage: Data?
    
    // preview layer
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    
    private lazy var camPreview: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var captureButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("", for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(captureButtonDidTouch), for: .touchUpInside)
        return button
    }()
    
    private lazy var capturedImageThumbnailButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(capturedImageThumbnailButtonDidTouch), for: .touchUpInside)
        return button
    }()
    
    override func loadView() {
        super.loadView()
        view.addSubview(camPreview)
        view.addSubview(captureButton)
        view.addSubview(capturedImageThumbnailButton)
        camPreview.translatesAutoresizingMaskIntoConstraints = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        capturedImageThumbnailButton.translatesAutoresizingMaskIntoConstraints = false

        
        NSLayoutConstraint.activate([
            camPreview.topAnchor.constraint(equalTo: view.topAnchor),
            camPreview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            camPreview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            camPreview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            captureButton.widthAnchor.constraint(equalToConstant: 80),
            captureButton.heightAnchor.constraint(equalToConstant: 80),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            capturedImageThumbnailButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            capturedImageThumbnailButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  30),
            capturedImageThumbnailButton.widthAnchor.constraint(equalToConstant: 40),
            capturedImageThumbnailButton.heightAnchor.constraint(equalToConstant: 40),
        ])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Start setting up a session!")
        if !isSessionSetUp {
            if setupSession() {
                startSession()
                setupPreview()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureButton.layer.cornerRadius = captureButton.frame.width / 2
    }
    
    // setup session
    // Adding Input
    // Adding Output
    private func setupSession() -> Bool {
        // MARK: INPUT STARTS HERE
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let camera: AVCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)! // default video device
        
        do {
            let input: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            } else {
                // Error
                print("Was not able to add input device")
                captureSession.commitConfiguration()
                return false
            }
        } catch {
            // Error
            print("Was not able to add input device")
            captureSession.commitConfiguration()
            return false
        }
        
        // MARK: OUTPUT STARTS HERE
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        } else {
            print("Failed to create photo output")
            captureSession.commitConfiguration()
            return false
        }
        
        captureSession.commitConfiguration()
        
        // MARK: UPDATE FLAG
        isSessionSetUp = true
        
        return true
    }
    
    // start session
    private func startSession() {
        DispatchQueue.main.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    // stop session
    private func stopSession() {
        DispatchQueue.main.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    private func setupPreview() {
        print("setting up a preview")
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.connection?.videoOrientation = .portrait
        camPreview.layer.insertSublayer(previewLayer, at: 0)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.previewLayer.frame = self.camPreview.bounds
        }
    }
    
    @objc
    private func captureButtonDidTouch(_ sender: UIButton) {
        let photoSettings: AVCapturePhotoSettings = AVCapturePhotoSettings()
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @objc
    private func capturedImageThumbnailButtonDidTouch(_ sender: UIButton) {
        print("thumnail button is clicked!")
        guard let capturedImage = capturedImage else {
            print("no captured image..")
            return
        }
        let vc = CapturedImageViewController()
        vc.capturedImage = capturedImage
        present(vc, animated: true)

    }
    

}

extension ViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard error == nil else {
            print("Error in capture process: \(String(describing: error))")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Unable to create image data")
            return
        }
        
        capturedImage = imageData
        capturedImageThumbnailButton.setBackgroundImage(UIImage(data: capturedImage!), for: .normal)
        
    }
    
}


```
