//
//  ImageSelectionVC.swift
//  PassioQuickStart
//
//  Created by Pratik on 21/10/24.
//

import UIKit
import PassioNutritionAISDK
import AVFoundation

class ImageSelectionVC: UIViewController
{
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var gallaryButton: UIButton!

    private let passioSDK = PassioNutritionAI.shared
    private var passioConfig = PassioConfiguration(key: Config.PASSIO_KEY)
    
    // Capure photo
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var resumeSession: Bool = false
    
    // Pick from gallery
    lazy var imagePicker = QSImagePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
        configurePassioSDK()
    }
    
    func basicSetup() {
        captureButton.layer.cornerRadius = 5
        gallaryButton.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if resumeSession {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                self.captureSession.startRunning()
                resumeSession = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let session = captureSession else { return }
        if session.isRunning {
            session.stopRunning()
            resumeSession = true
        }
    }
    
    @IBAction func captureButtonTapped(_ sender: UIButton) {
        captureImage()
    }
    
    @IBAction func gallaryButtonTapped(_ sender: UIButton) {
        openGallary()
    }
    
    func navigateToImageRecogniser(image: UIImage) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let recognizeImageVC = storyBoard.instantiateViewController(withIdentifier: "RecognizeImageVC") as! RecognizeImageVC
        recognizeImageVC.selectedImage = image
        self.navigationController?.pushViewController(recognizeImageVC, animated: true)
    }
    
    // MARK: - SDK configuration
    
    func configurePassioSDK() {
        /** 
         debugMode --> 0 means no logging/print
         Change to 31418, -333 or 1 for logging
         */
        passioConfig.debugMode = 0
        passioSDK.statusDelegate = self
        passioConfig.remoteOnly = true
        
        passioSDK.configure(passioConfiguration: passioConfig) { status in
            print("Mode = \(status.mode)")
            print("Missingfiles = \(String(describing: status.missingFiles))")
        }
    }
    
    func configUI(status: PassioStatus) {
        
        DispatchQueue.main.async {
            switch status.mode {
            case .isReadyForDetection:
                self.askForCapturePermission()
            case .isBeingConfigured:
                self.statusLabel.text = "Configuraing SDK..."
            case .failedToConfigure:
                self.statusLabel.text = "SDK failed to configure!"
            case .isDownloadingModels:
                self.statusLabel.text = "SDK is downloading files..."
            case .notReady:
                self.statusLabel.text = "SDK is not ready!"
            @unknown default:
                self.statusLabel.text = "Unknown passio status!"
            }
        }
    }
}

extension ImageSelectionVC: PassioStatusDelegate {
    
    func passioStatusChanged(status: PassioStatus) {
        print("Status changed: \(status)")
        configUI(status: status)
    }
    
    func passioProcessing(filesLeft: Int) {
        print("Files to download: \(filesLeft)")
    }
    
    func completedDownloadingAllFiles(filesLocalURLs: [FileLocalURL]) {
        print("All files downloaded")
    }
    
    func completedDownloadingFile(fileLocalURL: FileLocalURL, filesLeft: Int) {
        print("File downloaded: \(fileLocalURL)")
    }
    
    func downloadingError(message: String) {
        print("Downloading error: \(message)")
    }
}

extension ImageSelectionVC: AVCapturePhotoCaptureDelegate {
    
    func askForCapturePermission() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            configureCamera()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.configureCamera()
                    } else {
                        self.statusLabel.text = "Please grant permission from Settings to use camera."
                    }
                }
            }
        }
    }
    
    private func configureCamera() {
        
        statusLabel.text = "Setting up camera..."
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            statusLabel.text = "Unable to access back camera!"
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) &&
                captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error {
            statusLabel.text = "Error Unable to initialize back camera:  \(error.localizedDescription)"
        }
    }
    
    func setupLivePreview() {
        
        statusView.isHidden = true
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill //.resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        self.captureView.layer.insertSublayer(videoPreviewLayer, at: 0)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.captureView.bounds
            }
        }
    }
    
    func captureImage() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        navigateToImageRecogniser(image: image)
    }
}

extension ImageSelectionVC: QSImagePickerDelegate {
    
    func openGallary() {
        imagePicker.delegate = self
        imagePicker.present(on: self)
    }
    func didSelect(images: [UIImage]) {
        navigateToImageRecogniser(image: images[0])
    }
}
