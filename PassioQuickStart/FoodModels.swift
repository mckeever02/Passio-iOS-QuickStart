import Foundation
import PassioNutritionAISDK
import SwiftUI

// Extension to make PassioIDAndConfidence more SwiftUI-friendly
extension PassioIDAndConfidence: Identifiable {
    public var id: String {
        return passioID
    }
}

// Food item model that can be used in SwiftUI views
struct FoodItem: Identifiable {
    var id = UUID()
    var passioID: String
    var name: String
    var confidence: Double
    var image: UIImage?
    var nutritionFacts: PassioNutritionFacts?
    
    init(from passioFood: PassioIDAndConfidence, image: UIImage? = nil, nutritionFacts: PassioNutritionFacts? = nil) {
        self.passioID = passioFood.passioID
        self.name = passioFood.name
        self.confidence = passioFood.confidence
        self.image = image
        self.nutritionFacts = nutritionFacts
    }
}

// View model for food scanning
class FoodScannerViewModel: ObservableObject {
    @Published var scannedFoods: [FoodItem] = []
    @Published var currentScan: FoodItem?
    @Published var isScanning = false
    
    func addScannedFood(_ food: FoodItem) {
        currentScan = food
        scannedFoods.append(food)
    }
    
    func clearCurrentScan() {
        currentScan = nil
    }
} 