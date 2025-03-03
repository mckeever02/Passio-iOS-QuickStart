import SwiftUI
import PassioNutritionAISDK

struct NutritionFactsRowView: View {
    var nutrientName: String
    var nutrientValue: Double
    var unit: String
    var isSubItem: Bool = false
    var dailyValue: Double? = nil
    
    var body: some View {
        HStack {
            if isSubItem {
                Text("   \(nutrientName)")
                    .font(.subheadline)
            } else {
                Text(nutrientName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("\(nutrientValue.asString()) \(unit)")
                    .font(.subheadline)
                
                if let dailyValue = dailyValue, dailyValue > 0 {
                    Text("\(Int(dailyValue))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct NutritionFactsView: View {
    var nutritionFacts: PassioNutritionFacts
    @State private var showAllNutrients: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("Nutrition Facts")
                    .font(.headline)
                
                Spacer()
                
                if let servingSize = nutritionFacts.servingSize, !servingSize.isEmpty {
                    Text("Per \(servingSize)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 4)
            
            Divider()
            
            // Calories
            HStack {
                Text("Calories")
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(nutritionFacts.calories))")
                    .font(.headline)
            }
            .padding(.vertical, 4)
            
            Divider()
            
            // Macronutrients
            Group {
                NutritionFactsRowView(
                    nutrientName: "Total Fat",
                    nutrientValue: nutritionFacts.fat,
                    unit: "g",
                    dailyValue: nutritionFacts.fat / 78 * 100 // Based on 2000 calorie diet
                )
                
                if nutritionFacts.saturatedFat > 0 {
                    NutritionFactsRowView(
                        nutrientName: "Saturated Fat",
                        nutrientValue: nutritionFacts.saturatedFat,
                        unit: "g",
                        isSubItem: true,
                        dailyValue: nutritionFacts.saturatedFat / 20 * 100
                    )
                }
                
                if nutritionFacts.transFat > 0 {
                    NutritionFactsRowView(
                        nutrientName: "Trans Fat",
                        nutrientValue: nutritionFacts.transFat,
                        unit: "g",
                        isSubItem: true
                    )
                }
                
                if nutritionFacts.polyunsaturatedFat > 0 {
                    NutritionFactsRowView(
                        nutrientName: "Polyunsaturated Fat",
                        nutrientValue: nutritionFacts.polyunsaturatedFat,
                        unit: "g",
                        isSubItem: true
                    )
                }
                
                if nutritionFacts.monounsaturatedFat > 0 {
                    NutritionFactsRowView(
                        nutrientName: "Monounsaturated Fat",
                        nutrientValue: nutritionFacts.monounsaturatedFat,
                        unit: "g",
                        isSubItem: true
                    )
                }
                
                Divider()
                
                NutritionFactsRowView(
                    nutrientName: "Cholesterol",
                    nutrientValue: nutritionFacts.cholesterol,
                    unit: "mg",
                    dailyValue: nutritionFacts.cholesterol / 300 * 100
                )
                
                NutritionFactsRowView(
                    nutrientName: "Sodium",
                    nutrientValue: nutritionFacts.sodium,
                    unit: "mg",
                    dailyValue: nutritionFacts.sodium / 2300 * 100
                )
                
                Divider()
                
                NutritionFactsRowView(
                    nutrientName: "Total Carbohydrate",
                    nutrientValue: nutritionFacts.carbs,
                    unit: "g",
                    dailyValue: nutritionFacts.carbs / 275 * 100
                )
                
                if nutritionFacts.fiber > 0 {
                    NutritionFactsRowView(
                        nutrientName: "Dietary Fiber",
                        nutrientValue: nutritionFacts.fiber,
                        unit: "g",
                        isSubItem: true,
                        dailyValue: nutritionFacts.fiber / 28 * 100
                    )
                }
                
                if nutritionFacts.sugar > 0 {
                    NutritionFactsRowView(
                        nutrientName: "Total Sugars",
                        nutrientValue: nutritionFacts.sugar,
                        unit: "g",
                        isSubItem: true
                    )
                }
            }
            
            Divider()
            
            NutritionFactsRowView(
                nutrientName: "Protein",
                nutrientValue: nutritionFacts.protein,
                unit: "g",
                dailyValue: nutritionFacts.protein / 50 * 100
            )
            
            if showAllNutrients {
                Divider()
                
                // Additional nutrients if available
                Group {
                    if nutritionFacts.calcium > 0 {
                        NutritionFactsRowView(
                            nutrientName: "Calcium",
                            nutrientValue: nutritionFacts.calcium,
                            unit: "mg",
                            dailyValue: nutritionFacts.calcium / 1300 * 100
                        )
                    }
                    
                    if nutritionFacts.iron > 0 {
                        NutritionFactsRowView(
                            nutrientName: "Iron",
                            nutrientValue: nutritionFacts.iron,
                            unit: "mg",
                            dailyValue: nutritionFacts.iron / 18 * 100
                        )
                    }
                    
                    if nutritionFacts.potassium > 0 {
                        NutritionFactsRowView(
                            nutrientName: "Potassium",
                            nutrientValue: nutritionFacts.potassium,
                            unit: "mg",
                            dailyValue: nutritionFacts.potassium / 4700 * 100
                        )
                    }
                    
                    if nutritionFacts.vitaminA > 0 {
                        NutritionFactsRowView(
                            nutrientName: "Vitamin A",
                            nutrientValue: nutritionFacts.vitaminA,
                            unit: "µg",
                            dailyValue: nutritionFacts.vitaminA / 900 * 100
                        )
                    }
                    
                    if nutritionFacts.vitaminC > 0 {
                        NutritionFactsRowView(
                            nutrientName: "Vitamin C",
                            nutrientValue: nutritionFacts.vitaminC,
                            unit: "mg",
                            dailyValue: nutritionFacts.vitaminC / 90 * 100
                        )
                    }
                }
            }
            
            Button(action: {
                showAllNutrients.toggle()
            }) {
                Text(showAllNutrients ? "Show Less" : "Show More")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct NutritionFactsView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionFactsView(
            nutritionFacts: PassioNutritionFacts(
                calories: 240,
                protein: 10,
                carbs: 30,
                fat: 8,
                saturatedFat: 2.5,
                transFat: 0,
                polyunsaturatedFat: 1.5,
                monounsaturatedFat: 4,
                cholesterol: 15,
                sodium: 430,
                fiber: 5,
                sugar: 12,
                calcium: 200,
                potassium: 450,
                vitaminA: 120,
                vitaminC: 30,
                iron: 2.5,
                servingSize: "1 cup (240g)",
                servingUnit: "g",
                servingWeight: 240
            )
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 