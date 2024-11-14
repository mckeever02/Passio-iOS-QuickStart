//
//  QSImagePicker.swift
//  PassioQuickStart
//
//  Created by Pratik on 21/10/24.
//

import Foundation
import UIKit
import PhotosUI

protocol QSImagePickerDelegate: NSObjectProtocol {
    func didSelect(images: [UIImage])
}

class QSImagePicker: NSObject
{
    var selectionLimit: Int = 1
    weak var delegate: QSImagePickerDelegate?

    override init() {
        super.init()
    }
    
    func present(on viewController: UIViewController) {
        
        PHPhotoLibrary.requestAuthorization() { status in
            DispatchQueue.main.async {
                if status == .authorized {
                    self.presentImagePicker(on: viewController)
                } else {
                    self.showPermissionAlert(on: viewController)
                }
            }
        }
    }
    
    func showPermissionAlert(on viewController: UIViewController) {
        let alert = UIAlertController(title: "Allow access to your photos",
                                      message: "This lets you share from your camera roll and enables real-time food recognition. Go to your settings and tap \"Photos\".",
                                      preferredStyle: .alert)
        
        let notNowAction = UIAlertAction(title: "Not Now",
                                         style: .cancel,
                                         handler: nil)
        alert.addAction(notNowAction)
        
        let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) {_ in
            self.gotoAppPrivacySettings()
        }
        alert.addAction(openSettingsAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            assertionFailure("Not able to open App privacy settings")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func presentImagePicker(on viewController: UIViewController) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = selectionLimit
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.isModalInPresentation = true
        picker.delegate = self
        
        DispatchQueue.main.async {
            viewController.present(picker, animated: true)
        }
    }
}

extension QSImagePicker: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, 
                didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true) { [weak self] in
            
            if results.count < 1 { return }
            
            var selectedImages: [UIImage] = []
            let itemProviders = results.map(\.itemProvider)
            let dispatchGroup = DispatchGroup()
            
            for itemProvider in itemProviders {
                dispatchGroup.enter()
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { image , error  in
                        if let image = image as? UIImage {
                            selectedImages.append(image)
                            dispatchGroup.leave()
                        } else {
                            dispatchGroup.leave()
                        }
                    }
                } else {
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) { [weak self] in
                guard let self else { return }
                if selectedImages.count < 1 { return }
                self.delegate?.didSelect(images: selectedImages)
            }
        }
    }
}
