import SwiftUI
import PassioNutritionAISDK

struct ImageRecognitionView: View {
    @StateObject private var viewModel = ImageRecognitionViewModel()
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        VStack {
            if let selectedImage = viewModel.selectedImage {
                // Display the selected image
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(10)
                    .padding()
                
                if viewModel.isRecognizing {
                    // Show progress indicator while recognizing
                    ProgressView("Recognizing food...")
                        .padding()
                } else if let recognizedFood = viewModel.recognizedFood {
                    // Show recognized food
                    VStack(spacing: 12) {
                        Text("Recognized: \(recognizedFood.name)")
                            .font(.headline)
                        
                        Text("Confidence: \(Int(recognizedFood.confidence * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        NavigationLink(
                            destination: FoodDetailView(foodItem: FoodItem(
                                from: recognizedFood,
                                image: selectedImage,
                                nutritionFacts: viewModel.nutritionFacts
                            ))
                        ) {
                            Text("View Details")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 200)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    
                    // Show alternatives if available
                    if !viewModel.alternatives.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Alternatives")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.alternatives, id: \.passioID) { alternative in
                                        Button(action: {
                                            viewModel.selectAlternative(alternative)
                                        }) {
                                            HStack {
                                                Text(alternative.name)
                                                    .foregroundColor(.primary)
                                                
                                                Spacer()
                                                
                                                Text("\(Int(alternative.confidence * 100))%")
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding()
                                            .background(
                                                alternative.passioID == viewModel.recognizedFood?.passioID ?
                                                Color.blue.opacity(0.1) : Color(.systemGray6)
                                            )
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 200)
                        }
                    }
                } else {
                    // Button to start recognition
                    Button(action: {
                        viewModel.recognizeFood()
                    }) {
                        Text("Recognize Food")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
                // Button to select a different image
                Button(action: {
                    viewModel.reset()
                }) {
                    Text("Select Different Image")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                }
            } else {
                // Initial state - show image selection options
                VStack(spacing: 30) {
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("Select an image to recognize food")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack(spacing: 30) {
                        Button(action: {
                            sourceType = .camera
                            isShowingImagePicker = true
                        }) {
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                
                                Text("Camera")
                                    .font(.caption)
                                    .padding(.top, 8)
                            }
                        }
                        .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                        
                        Button(action: {
                            sourceType = .photoLibrary
                            isShowingImagePicker = true
                        }) {
                            VStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.green)
                                    .clipShape(Circle())
                                
                                Text("Gallery")
                                    .font(.caption)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            
            Spacer()
        }
        .navigationTitle("Food Recognition")
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(
                selectedImage: $viewModel.selectedImage,
                isPresented: $isShowingImagePicker,
                sourceType: sourceType
            )
        }
    }
}

class ImageRecognitionViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var recognizedFood: PassioIDAndConfidence?
    @Published var nutritionFacts: PassioNutritionFacts?
    @Published var alternatives: [PassioIDAndConfidence] = []
    @Published var isRecognizing = false
    
    func recognizeFood() {
        guard let image = selectedImage else { return }
        
        isRecognizing = true
        
        // Use Passio SDK to recognize food in the image
        PassioNutritionAI.shared.recognizeFood(in: image) { [weak self] candidates, visualCandidates, nutritionFacts in
            DispatchQueue.main.async {
                self?.isRecognizing = false
                
                if let firstCandidate = candidates?.first {
                    self?.recognizedFood = firstCandidate
                    self?.nutritionFacts = nutritionFacts
                    
                    // Get alternatives
                    if let alternatives = PassioNutritionAI.shared.lookupAlternatives(for: firstCandidate.passioID) {
                        self?.alternatives = alternatives
                    } else {
                        self?.alternatives = []
                    }
                } else {
                    // No food recognized
                    self?.recognizedFood = nil
                    self?.nutritionFacts = nil
                    self?.alternatives = []
                }
            }
        }
    }
    
    func selectAlternative(_ alternative: PassioIDAndConfidence) {
        recognizedFood = alternative
        
        // Look up nutrition facts for the selected alternative
        if let attributes = PassioNutritionAI.shared.lookupPassioIDAttributesFor(passioID: alternative.passioID) {
            nutritionFacts = attributes.nutritionFacts
        } else {
            nutritionFacts = nil
        }
    }
    
    func reset() {
        selectedImage = nil
        recognizedFood = nil
        nutritionFacts = nil
        alternatives = []
        isRecognizing = false
    }
}

struct ImageRecognitionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImageRecognitionView()
        }
    }
} 