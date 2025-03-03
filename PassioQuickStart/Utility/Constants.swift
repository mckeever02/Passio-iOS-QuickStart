import SwiftUI

struct AppConstants {
    // Colors
    struct Colors {
        static let primaryColor = Color.blue
        static let secondaryColor = Color.green
        static let accentColor = Color.orange
        static let backgroundColor = Color(.systemBackground)
        static let textColor = Color.primary
        static let secondaryTextColor = Color.secondary
        
        // Nutrition colors
        static let proteinColor = Color.blue
        static let carbsColor = Color.green
        static let fatColor = Color.red
    }
    
    // Fonts
    struct Fonts {
        static let titleFont = Font.title
        static let headlineFont = Font.headline
        static let bodyFont = Font.body
        static let captionFont = Font.caption
    }
    
    // Layout
    struct Layout {
        static let standardPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let cornerRadius: CGFloat = 10
    }
    
    // Animation
    struct Animation {
        static let standardDuration: Double = 0.3
        static let standardCurve = SwiftUI.Animation.easeInOut
    }
} 