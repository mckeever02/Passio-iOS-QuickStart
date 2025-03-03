import SwiftUI
import PassioNutritionAISDK

struct FoodListCellView: View {
    var foodItem: FoodItem
    var showConfidence: Bool = true
    
    var body: some View {
        HStack(spacing: 12) {
            // Food image
            if let image = foodItem.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .padding(15)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(foodItem.name)
                    .font(.headline)
                    .lineLimit(1)
                
                if let nutritionFacts = foodItem.nutritionFacts {
                    Text("\(Int(nutritionFacts.calories)) kcal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if showConfidence {
                    Text("Confidence: \(Int(foodItem.confidence * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

struct FoodListCellView_Previews: PreviewProvider {
    static var previews: some View {
        FoodListCellView(
            foodItem: FoodItem(
                from: PassioIDAndConfidence(passioID: "apple", name: "Apple", confidence: 0.95),
                image: nil,
                nutritionFacts: PassioNutritionFacts(
                    calories: 95,
                    protein: 0.5,
                    carbs: 25.0,
                    fat: 0.3
                )
            )
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 