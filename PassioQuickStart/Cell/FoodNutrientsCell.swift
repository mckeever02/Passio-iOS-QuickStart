//
//  FoodNutrientsCell.swift
//  PassioQuickStart
//
//  Created by Pratik on 29/10/24.
//

import UIKit
import PassioNutritionAISDK

class FoodNutrientsCell: UITableViewCell {

    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelShortName: UILabel!
    @IBOutlet weak var nutritionView: DonutChartView!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var protienLabel: UILabel!
    @IBOutlet weak var carbsPercentLabel: UILabel!
    @IBOutlet weak var fatPercentLabel: UILabel!
    @IBOutlet weak var protienPercentLabel: UILabel!
    @IBOutlet weak var insetBackground: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        insetBackground.setShadow(radius: 8,
                                  offset: CGSize(width: 0, height: 1),
                                  color: .black.withAlphaComponent(0.06),
                                  shadowRadius: 2,
                                  shadowOpacity: 1)
    }

    func setup(foodItem: PassioFoodItem) {

        // 1. Name & short name
        labelName.text = foodItem.name
        labelShortName.text = foodItem.details

        let entityType: PassioIDEntityType = foodItem.ingredients.count > 1 ? .recipe : .item
        
        if labelName.text?.lowercased() == self.labelShortName.text?.lowercased()
            || entityType == .recipe {
            labelShortName.isHidden = true
        } else {
            labelShortName.isHidden = false
        }

        // 2. Food image
        imageFood.loadIcon(id: foodItem.iconId)

        let calories = foodItem.nutrientsSelectedSize().calories()?.value ?? 0
        let carbs = foodItem.nutrientsSelectedSize().carbs()?.value ?? 0
        let protein = foodItem.nutrientsSelectedSize().protein()?.value ?? 0
        let fat = foodItem.nutrientsSelectedSize().fat()?.value ?? 0
        
        // 3. Chart
        let percents = macronutrientPercentages(carbsG: carbs,
                                                fatG: fat,
                                                proteinG: protein,
                                                totalCalories: calories)
        let c = DonutChartView.ChartDatasource(color: .lightBlue,
                                             percent: percents.carbPercentage)
        let p = DonutChartView.ChartDatasource(color: .green500,
                                             percent: percents.proteinPercentage)
        let f = DonutChartView.ChartDatasource(color: .purple500,
                                             percent: percents.fatPercentage)
        nutritionView.updateData(data: [c,p,f])
        
        // 4. Calories
        caloriesLabel.text = calories.noDigit
        carbsLabel.text = carbs.oneDigit + " \(UnitsTexts.g)"
        protienLabel.text = protein.oneDigit + " \(UnitsTexts.g)"
        fatLabel.text = fat.oneDigit + " \(UnitsTexts.g)"
        
        // 5. Percentage
        let total = [c,p,f].reduce(0, { $0 + $1.percent })
        if total > 0 {
            fatPercentLabel.text = "(\(f.percent.oneDigit)%)"
            protienPercentLabel.text = "(\(p.percent.oneDigit)%)"
            carbsPercentLabel.text = "(\(c.percent.oneDigit)%)"
        } else {
            fatPercentLabel.text = "(0%)"
            protienPercentLabel.text = "(0%)"
            carbsPercentLabel.text = "(0%)"
        }
    }

    func macronutrientPercentages(carbsG: Double,
                                  fatG: Double,
                                  proteinG: Double,
                                  totalCalories: Double) -> (carbPercentage: Double,
                                                             fatPercentage: Double,
                                                             proteinPercentage: Double)
    {
        // Calculate calories contributed by each macronutrient
        let carbCalories = carbsG * 4
        let fatCalories = fatG * 9
        let proteinCalories = proteinG * 4

        // Calculate total calories from macronutrients
        let totalMacronutrientCalories = carbCalories + fatCalories + proteinCalories

        // Calculate percentages
        let carbPercentage = (carbCalories / totalMacronutrientCalories) * 100
        let fatPercentage = (fatCalories / totalMacronutrientCalories) * 100
        let proteinPercentage = (proteinCalories / totalMacronutrientCalories) * 100

        return (carbPercentage: carbPercentage,
                fatPercentage: fatPercentage,
                proteinPercentage: proteinPercentage)
    }
}
