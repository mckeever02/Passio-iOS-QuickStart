import SwiftUI
import PassioNutritionAISDK

struct FoodDetailView: View {
    let foodItem: FoodItem
    
    @State private var selectedServingIndex: Int = 0
    @State private var servingQuantity: Double = 1.0
    @State private var servingSizes: [PassioServingSize] = []
    @State private var adjustedNutritionFacts: PassioNutritionFacts?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Food image
                if let image = foodItem.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                // Food name and confidence
                VStack(alignment: .leading, spacing: 4) {
                    Text(foodItem.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("Confidence: \(Int(foodItem.confidence * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Macronutrient chart
                if let nutrition = adjustedNutritionFacts ?? foodItem.nutritionFacts {
                    MacronutrientChartView(nutritionFacts: nutrition)
                        .padding()
                }
                
                // Serving size selector
                if !servingSizes.isEmpty {
                    ServingSizeView(
                        servingSizes: servingSizes,
                        selectedServingIndex: $selectedServingIndex,
                        servingQuantity: $servingQuantity
                    )
                    .padding(.horizontal)
                    .onChange(of: selectedServingIndex) { _ in
                        updateNutritionFacts()
                    }
                    .onChange(of: servingQuantity) { _ in
                        updateNutritionFacts()
                    }
                }
                
                // Nutrition facts
                if let nutrition = adjustedNutritionFacts ?? foodItem.nutritionFacts {
                    NutritionFactsView(nutritionFacts: nutrition)
                        .padding(.horizontal)
                } else {
                    Text("No nutrition information available")
                        .italic()
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("Food Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadServingSizes()
        }
    }
    
    private func loadServingSizes() {
        // Get serving sizes from the Passio SDK
        if let attributes = PassioNutritionAI.shared.lookupPassioIDAttributesFor(passioID: foodItem.passioID),
           let sizes = attributes.servingSizes, !sizes.isEmpty {
            servingSizes = sizes
            
            // Set default serving size
            if let defaultIndex = sizes.firstIndex(where: { $0.unitName.lowercased() == "gram" }) {
                selectedServingIndex = defaultIndex
            }
            
            updateNutritionFacts()
        }
    }
    
    private func updateNutritionFacts() {
        guard selectedServingIndex < servingSizes.count,
              let originalNutrition = foodItem.nutritionFacts else {
            return
        }
        
        let selectedServing = servingSizes[selectedServingIndex]
        
        // Calculate the adjustment factor based on serving size and quantity
        var adjustmentFactor: Double = servingQuantity
        
        if let originalWeight = originalNutrition.servingWeight, originalWeight > 0,
           let selectedWeight = selectedServing.weight, selectedWeight > 0 {
            adjustmentFactor = (selectedWeight * servingQuantity) / originalWeight
        }
        
        // Create adjusted nutrition facts
        adjustedNutritionFacts = PassioNutritionFacts(
            calories: originalNutrition.calories * adjustmentFactor,
            protein: originalNutrition.protein * adjustmentFactor,
            carbs: originalNutrition.carbs * adjustmentFactor,
            fat: originalNutrition.fat * adjustmentFactor,
            saturatedFat: originalNutrition.saturatedFat * adjustmentFactor,
            transFat: originalNutrition.transFat * adjustmentFactor,
            polyunsaturatedFat: originalNutrition.polyunsaturatedFat * adjustmentFactor,
            monounsaturatedFat: originalNutrition.monounsaturatedFat * adjustmentFactor,
            cholesterol: originalNutrition.cholesterol * adjustmentFactor,
            sodium: originalNutrition.sodium * adjustmentFactor,
            fiber: originalNutrition.fiber * adjustmentFactor,
            sugar: originalNutrition.sugar * adjustmentFactor,
            sugarsAdded: originalNutrition.sugarsAdded * adjustmentFactor,
            calcium: originalNutrition.calcium * adjustmentFactor,
            potassium: originalNutrition.potassium * adjustmentFactor,
            vitaminA: originalNutrition.vitaminA * adjustmentFactor,
            vitaminC: originalNutrition.vitaminC * adjustmentFactor,
            iron: originalNutrition.iron * adjustmentFactor,
            servingSize: "\(servingQuantity) \(selectedServing.unitName)",
            servingUnit: selectedServing.unitName,
            servingWeight: selectedServing.weight != nil ? selectedServing.weight! * servingQuantity : nil
        )
    }
}

struct MacronutrientChartView: View {
    let nutritionFacts: PassioNutritionFacts
    
    var body: some View {
        VStack(spacing: 16) {
            // Donut chart
            DonutChartView(
                segments: DonutChartView.createNutrientSegments(
                    protein: nutritionFacts.protein,
                    carbs: nutritionFacts.carbs,
                    fat: nutritionFacts.fat
                ),
                centerText: "\(Int(nutritionFacts.calories))\nkcal"
            )
            .frame(height: 180)
            
            // Legend
            HStack(spacing: 20) {
                MacroLegendItem(
                    color: .blue,
                    name: "Protein",
                    value: "\(nutritionFacts.protein.asString())g"
                )
                
                MacroLegendItem(
                    color: .green,
                    name: "Carbs",
                    value: "\(nutritionFacts.carbs.asString())g"
                )
                
                MacroLegendItem(
                    color: .red,
                    name: "Fat",
                    value: "\(nutritionFacts.fat.asString())g"
                )
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct MacroLegendItem: View {
    var color: Color
    var name: String
    var value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
}

struct NutritionFactsView: View {
    let nutritionFacts: PassioNutritionFacts
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nutrition Facts")
                .font(.headline)
                .padding(.horizontal)
            
            Divider()
            
            Group {
                nutritionRow(name: "Calories", value: "\(Int(nutritionFacts.calories)) kcal")
                nutritionRow(name: "Protein", value: "\(nutritionFacts.protein.formattedNutrition()) g")
                nutritionRow(name: "Carbohydrates", value: "\(nutritionFacts.carbs.formattedNutrition()) g")
                nutritionRow(name: "Fat", value: "\(nutritionFacts.fat.formattedNutrition()) g")
                
                if nutritionFacts.saturatedFat > 0 {
                    nutritionRow(name: "Saturated Fat", value: "\(nutritionFacts.saturatedFat.formattedNutrition()) g", isSubItem: true)
                }
                
                if nutritionFacts.transFat > 0 {
                    nutritionRow(name: "Trans Fat", value: "\(nutritionFacts.transFat.formattedNutrition()) g", isSubItem: true)
                }
                
                if nutritionFacts.cholesterol > 0 {
                    nutritionRow(name: "Cholesterol", value: "\(nutritionFacts.cholesterol.formattedNutrition()) mg")
                }
                
                if nutritionFacts.sodium > 0 {
                    nutritionRow(name: "Sodium", value: "\(nutritionFacts.sodium.formattedNutrition()) mg")
                }
                
                if nutritionFacts.fiber > 0 {
                    nutritionRow(name: "Fiber", value: "\(nutritionFacts.fiber.formattedNutrition()) g", isSubItem: true)
                }
                
                if nutritionFacts.sugar > 0 {
                    nutritionRow(name: "Sugar", value: "\(nutritionFacts.sugar.formattedNutrition()) g", isSubItem: true)
                }
            }
            
            if let servingSize = nutritionFacts.servingSize, !servingSize.isEmpty {
                Divider()
                Text("Serving Size: \(servingSize)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
    
    private func nutritionRow(name: String, value: String, isSubItem: Bool = false) -> some View {
        HStack {
            if isSubItem {
                Text("   \(name)")
                    .font(.subheadline)
            } else {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct FoodDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FoodDetailView(foodItem: FoodItem(
                from: PassioIDAndConfidence(passioID: "apple", name: "Apple", confidence: 0.95),
                image: UIImage(systemName: "apple.logo"),
                nutritionFacts: PassioNutritionFacts(
                    calories: 95,
                    protein: 0.5,
                    carbs: 25.0,
                    fat: 0.3,
                    saturatedFat: 0.1,
                    transFat: 0,
                    cholesterol: 0,
                    sodium: 2,
                    fiber: 4.4,
                    sugar: 19,
                    servingSize: "1 medium apple (182g)",
                    servingUnit: "g",
                    servingWeight: 182
                )
            ))
        }
    }
} 