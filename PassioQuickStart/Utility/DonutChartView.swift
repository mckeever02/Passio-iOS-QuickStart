import SwiftUI

struct DonutChartView: View {
    var segments: [NutrientSegment]
    var centerText: String
    var lineWidth: CGFloat = 40
    
    var body: some View {
        ZStack {
            ForEach(segments) { segment in
                DonutSegment(
                    startAngle: segment.startAngle,
                    endAngle: segment.endAngle,
                    color: segment.color,
                    lineWidth: lineWidth
                )
            }
            
            Text(centerText)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
}

struct DonutSegment: View {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
    var lineWidth: CGFloat
    
    var body: some View {
        Circle()
            .trim(from: startAngle.degrees / 360, to: endAngle.degrees / 360)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .rotationEffect(Angle(degrees: -90))
    }
}

struct NutrientSegment: Identifiable {
    var id = UUID()
    var value: Double
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
    
    init(value: Double, startAngle: Double, endAngle: Double, color: Color) {
        self.value = value
        self.startAngle = Angle(degrees: startAngle)
        self.endAngle = Angle(degrees: endAngle)
        self.color = color
    }
}

extension DonutChartView {
    static func createNutrientSegments(protein: Double, carbs: Double, fat: Double) -> [NutrientSegment] {
        let total = protein + carbs + fat
        
        // If total is 0, create equal segments
        if total == 0 {
            return [
                NutrientSegment(value: 1, startAngle: 0, endAngle: 120, color: .blue),
                NutrientSegment(value: 1, startAngle: 120, endAngle: 240, color: .green),
                NutrientSegment(value: 1, startAngle: 240, endAngle: 360, color: .red)
            ]
        }
        
        // Calculate angles based on proportions
        let proteinProportion = protein / total
        let carbsProportion = carbs / total
        let fatProportion = fat / total
        
        let proteinAngle = 360 * proteinProportion
        let carbsAngle = 360 * carbsProportion
        let fatAngle = 360 * fatProportion
        
        return [
            NutrientSegment(value: protein, startAngle: 0, endAngle: proteinAngle, color: .blue),
            NutrientSegment(value: carbs, startAngle: proteinAngle, endAngle: proteinAngle + carbsAngle, color: .green),
            NutrientSegment(value: fat, startAngle: proteinAngle + carbsAngle, endAngle: 360, color: .red)
        ]
    }
} 