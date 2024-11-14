//
//  Double+Extension.swift
//  PassioQuickStart
//
//  Created by Pratik on 23/10/24.
//

import Foundation

extension Double {
    
    func roundUpto(_ max: Int) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = max
        formatter.minimumFractionDigits = 0
        guard let formattedString = formatter.string(for: self) else {
            return ""
        }
        return formattedString
    }
    
    var noDigit: String {
        return roundUpto(0)
    }
    var oneDigit: String {
        return roundUpto(1)
    }
    var twoDigits: String {
        return roundUpto(2)
    }
    var threeDigits: String {
        return roundUpto(3)
    }
}
