import SwiftUI
import PassioNutritionAISDK

struct FoodScannerView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: FoodScannerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PassioFoodScannerViewController {
        let viewController = PassioFoodScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: PassioFoodScannerViewController, context: Context) {
        // Updates from SwiftUI to UIKit go here if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PassioFoodScannerDelegate {
        var parent: FoodScannerView
        
        init(_ parent: FoodScannerView) {
            self.parent = parent
        }
        
        func foodScannerDidDetectFood(foodCandidate: PassioIDAndConfidence, image: UIImage?, nutritionFacts: PassioNutritionFacts?) {
            let foodItem = FoodItem(
                from: foodCandidate,
                image: image,
                nutritionFacts: nutritionFacts
            )
            
            DispatchQueue.main.async {
                self.parent.viewModel.addScannedFood(foodItem)
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }
        
        func foodScannerDidFailWithError(_ error: Error) {
            print("Food scanner error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// This is a UIKit view controller that will be wrapped by SwiftUI
class PassioFoodScannerViewController: UIViewController, PassioNutritionAISDKDelegate {
    weak var delegate: PassioFoodScannerDelegate?
    private var passioSDK: PassioNutritionAI!
    private var cameraView: UIView!
    private var foodRecognitionLayer: CALayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passioSDK = PassioNutritionAI.shared
        passioSDK.nutritionAISDKDelegate = self
        
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startFoodDetection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopFoodDetection()
    }
    
    private func setupCamera() {
        cameraView = UIView()
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraView)
        
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add a close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        // Add a capture button
        let captureButton = UIButton(type: .system)
        captureButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        captureButton.tintColor = .white
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        view.addSubview(captureButton)
        
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func captureButtonTapped() {
        // Manually trigger a capture if needed
        // This is optional as the SDK will automatically detect food
    }
    
    private func startFoodDetection() {
        let cameraPosition = AVCaptureDevice.Position.back
        let videoOrientation = transformOrientation(orientation: UIInterfaceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!)
        
        passioSDK.startFoodDetection(detectionConfig: FoodDetectionConfiguration(detectBarcodes: true),
                                    foodRecognitionDelegate: self,
                                    completion: { (status) in
            if status == .success {
                if let previewLayer = self.passioSDK.getPreviewLayer() {
                    previewLayer.frame = self.cameraView.bounds
                    previewLayer.videoGravity = .resizeAspectFill
                    self.cameraView.layer.addSublayer(previewLayer)
                }
            } else {
                print("Failed to start food detection: \(status)")
                self.delegate?.foodScannerDidFailWithError(NSError(domain: "PassioSDK", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to start food detection"]))
            }
        })
    }
    
    private func stopFoodDetection() {
        passioSDK.stopFoodDetection()
        foodRecognitionLayer?.removeFromSuperlayer()
        foodRecognitionLayer = nil
    }
    
    private func transformOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    // MARK: - PassioNutritionAISDKDelegate
    
    func nutritionAISDKStatusChanged(status: PassioStatus) {
        print("Passio SDK status changed: \(status.debugDescription)")
    }
}

// MARK: - PassioFoodRecognitionDelegate

extension PassioFoodScannerViewController: PassioFoodRecognitionDelegate {
    func recognitionResults(candidates: PassioNutritionAI.FoodCandidates?, image: UIImage?, nutritionFacts: PassioNutritionFacts?) {
        guard let candidates = candidates, !candidates.isEmpty else { return }
        
        // Get the best candidate
        if let bestCandidate = candidates.first {
            // Look up nutrition facts if not provided
            var facts = nutritionFacts
            if facts == nil {
                facts = PassioNutritionAI.shared.lookupPassioIDAttributesFor(passioID: bestCandidate.passioID)?.nutritionFacts
            }
            
            delegate?.foodScannerDidDetectFood(foodCandidate: bestCandidate, image: image, nutritionFacts: facts)
        }
    }
}

// MARK: - Delegate Protocol

protocol PassioFoodScannerDelegate: AnyObject {
    func foodScannerDidDetectFood(foodCandidate: PassioIDAndConfidence, image: UIImage?, nutritionFacts: PassioNutritionFacts?)
    func foodScannerDidFailWithError(_ error: Error)
} 