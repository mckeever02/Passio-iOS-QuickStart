import SwiftUI
import PassioNutritionAISDK

struct ServingSizeView: View {
    var servingSizes: [PassioServingSize]
    @Binding var selectedServingIndex: Int
    @Binding var servingQuantity: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Serving Size")
                .font(.headline)
                .padding(.bottom, 4)
            
            HStack(spacing: 12) {
                // Quantity stepper
                HStack {
                    Button(action: {
                        if servingQuantity > 0.5 {
                            servingQuantity -= 0.5
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    TextField("Qty", text: Binding(
                        get: { String(format: "%.1f", servingQuantity) },
                        set: { if let value = Double($0) { servingQuantity = value } }
                    ))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 50)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    Button(action: {
                        servingQuantity += 0.5
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .frame(width: 120)
                
                // Serving size picker
                if !servingSizes.isEmpty {
                    Picker("", selection: $selectedServingIndex) {
                        ForEach(0..<servingSizes.count, id: \.self) { index in
                            Text(servingSizes[index].unitName)
                                .tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            // Display weight equivalent if available
            if selectedServingIndex < servingSizes.count,
               let weight = servingSizes[selectedServingIndex].weight {
                Text("(\(servingQuantity * weight, specifier: "%.1f")g)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

struct ServingSizeView_Previews: PreviewProvider {
    static var previews: some View {
        ServingSizeView(
            servingSizes: [
                PassioServingSize(unitName: "cup", weight: 240),
                PassioServingSize(unitName: "tablespoon", weight: 15),
                PassioServingSize(unitName: "gram", weight: 1)
            ],
            selectedServingIndex: .constant(0),
            servingQuantity: .constant(1.0)
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 