import SwiftUI
import UIKit
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIViewController {
        if sourceType == .camera {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = context.coordinator
            return imagePicker
        } else {
            if #available(iOS 14, *) {
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = 1
                configuration.filter = .images
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = context.coordinator
                return picker
            } else {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = context.coordinator
                return imagePicker
            }
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // UIImagePickerController delegate methods
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
        
        // PHPickerViewController delegate methods
        @available(iOS 14, *)
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.parent.selectedImage = image
                    }
                }
            }
        }
    }
}

// Helper view to present the image picker
struct ImagePickerButton: View {
    @Binding var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                sourceType = .camera
                isShowingImagePicker = true
            }) {
                VStack {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24))
                    Text("Camera")
                        .font(.caption)
                }
                .frame(width: 80, height: 80)
                .background(AppConstants.Colors.primaryColor.opacity(0.1))
                .cornerRadius(10)
            }
            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
            
            Button(action: {
                sourceType = .photoLibrary
                isShowingImagePicker = true
            }) {
                VStack {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 24))
                    Text("Gallery")
                        .font(.caption)
                }
                .frame(width: 80, height: 80)
                .background(AppConstants.Colors.primaryColor.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, isPresented: $isShowingImagePicker, sourceType: sourceType)
        }
    }
} 