//
//  UIImageView+Extension.swift
//  PassioIntegration
//
//  Created by Pratik on 03/09/24.
//

import Foundation
import UIKit
import PassioNutritionAISDK

extension UIImageView {
    
    func loadIcon(id passioID: PassioID,
                  entityType: PassioIDEntityType = .item,
                  size: IconSize = .px90) {
        
        let (placeHolderIcon, icon) = PassioNutritionAI.shared.lookupIconsFor(
            passioID: passioID,
            size: size,
            entityType: entityType
        )
        if let icon = icon {
            DispatchQueue.main.async {
                self.image = icon
            }
        } else {
            DispatchQueue.main.async {
                self.image = placeHolderIcon
            }
            PassioNutritionAI.shared.fetchIconFor(passioID: passioID) { image in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}

