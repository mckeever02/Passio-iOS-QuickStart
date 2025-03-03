import Foundation

extension Double {
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func asString(withDecimalPlaces places: Int = 1) -> String {
        return String(format: "%.\(places)f", self)
    }
    
    func asCaloriesString() -> String {
        return "\(Int(self.rounded())) kcal"
    }
    
    func asGramsString() -> String {
        return "\(self.rounded(toPlaces: 1).asString())g"
    }
    
    func asMilligramsString() -> String {
        return "\(self.rounded(toPlaces: 1).asString())mg"
    }
    
    func asPercentageString() -> String {
        return "\(Int(self * 100))%"
    }
} 