//
//  CapturedImageViewController.swift
//  CustomCameraApp
//
//  Created by paige shin on 2022/05/10.
//

import UIKit

class CapturedImageViewController: UIViewController {

    var capturedImage: Data?
    
    private lazy var capturedImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        return imageView
    }()
    
    private lazy var dismissButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("Close", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        return button
    }()
    
    override func loadView() {
        super.loadView()
        view.addSubview(capturedImageView)
        view.addSubview(dismissButton)
        capturedImageView.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            capturedImageView.topAnchor.constraint(equalTo: view.topAnchor),
            capturedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            capturedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            capturedImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = capturedImage {
            capturedImageView.image = UIImage(data: data)
        }
    }
    

    @objc
    private func dismissViewController(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
