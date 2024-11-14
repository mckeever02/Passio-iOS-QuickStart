//
//  FoodListCell.swift
//  PassioQuickStart
//
//  Created by Pratik on 22/10/24.
//

import UIKit
import PassioNutritionAISDK

class FoodListCell: UITableViewCell {

    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var foodDetailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        foodImageView.layer.cornerRadius = foodImageView.frame.size.height/2
        foodImageView.clipsToBounds = true
    }
    
    func configure(food: PassioAdvisorFoodInfo) {
        
        if let foodInfo = food.foodDataInfo {
            
            foodImageView.loadIcon(id: foodInfo.iconID)
            foodNameLabel.text = foodInfo.foodName.capitalized
            
            if let nutritionPreview = foodInfo.nutritionPreview {
                let servingQuantity = nutritionPreview.servingQuantity.twoDigits
                foodDetailsLabel.text = "\(servingQuantity) \(nutritionPreview.servingUnit) | \(nutritionPreview.calories) cal"
            } else {
                foodDetailsLabel.text = ""
            }
        }
        
        else if let packagedFoodItem = food.packagedFoodItem {
            
            foodNameLabel.text = packagedFoodItem.name
            
            let servingQuantity = packagedFoodItem.amount.selectedQuantity.twoDigits
            let calories = packagedFoodItem.nutrientsReference().calories()?.value ?? 0
            foodDetailsLabel.text = "\(servingQuantity) \(packagedFoodItem.amount.selectedUnit) | \(calories.twoDigits) cal"
        }
        
        else {
            foodNameLabel.text = ""
            foodDetailsLabel.text = ""
        }
    }
}
