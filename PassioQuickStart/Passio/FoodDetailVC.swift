//
//  FoodDetailVC.swift
//  PassioQuickStart
//
//  Created by Pratik on 23/10/24.
//

import UIKit
import PassioNutritionAISDK

class FoodDetailVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var loadingView: UIView!

    var didFetchData: Bool = false
    
    var food: PassioAdvisorFoodInfo?
    var foodItem: PassioFoodItem?
    private var cachedMaxForSlider = [String: Float]()

    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
        fetchPassioFoodItem()
    }
    
    func basicSetup() {
        loadingView.layer.cornerRadius = 6
        tableView.registerNib(ServingSizeCell.self)
        tableView.registerNib(FoodNutrientsCell.self)
    }
    
    func updateLoader(show: Bool) {
        loadingView.isHidden = !show
    }
    
    func fetchPassioFoodItem() {
        
        guard let food = food else { return }
        
        if let packagedFoodItem = food.packagedFoodItem {
            self.foodItem = packagedFoodItem
            reloadData()
        }
        else {
            if let foodDataInfo = food.foodDataInfo {
                let servingQuantity = foodDataInfo.nutritionPreview?.servingQuantity
                let servingUnit = foodDataInfo.nutritionPreview?.servingUnit
                
                updateLoader(show: true)
                PassioNutritionAI.shared.fetchFoodItemFor(foodDataInfo: foodDataInfo,
                                                          servingQuantity: servingQuantity,
                                                          servingUnit: servingUnit) { passioFoodItem in
                    DispatchQueue.main.async {
                        self.updateLoader(show: false)
                        if let foodItem = passioFoodItem {
                            self.foodItem = foodItem
                            self.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @objc func onChangeUnit(sender: UIButton) {
        guard let servingUnits = foodItem?.amount.servingUnits else { return }
        let items = servingUnits.map { $0.unitName }
        let dropDown = DropDownVC(nibName: "DropDownVC", bundle: nil)
        dropDown.loadViewIfNeeded()
        dropDown.pickerItems = items.map { DropDownElement(title: $0) }
        if let frame = sender.superview?.convert(sender.frame, to: nil) {
            dropDown.pickerFrame = CGRect(
                x: frame.origin.x - 5,
                y: frame.origin.y + 50,
                width: frame.width + 10,
                height: 36 * Double(items.count))
        }
        dropDown.delegate = self
        dropDown.modalTransitionStyle = .crossDissolve
        dropDown.modalPresentationStyle = .overFullScreen
        self.present(dropDown, animated: true, completion: nil)
    }
    
    @objc func onChangeQuantity(sender: UISlider) {
        let maxSlider = Int(sender.maximumValue)
        var sizeOfAtTick: Double
        switch maxSlider {
        case 0..<10:
            sizeOfAtTick = 0.5
        case 10..<100:
            sizeOfAtTick = 1
        case 100..<500:
            sizeOfAtTick = 1
        default:
            sizeOfAtTick = 10
        }
        var newValue = round(Double(sender.value)/sizeOfAtTick) * sizeOfAtTick
        guard newValue != foodItem?.amount.selectedQuantity,
              var tempFoodItem = foodItem else {
            return
        }
        newValue = newValue == 0 ? sizeOfAtTick/1000 : newValue
        tempFoodItem.setSelectedQuantity(newValue)
        foodItem = tempFoodItem
        reloadData()
    }

    func getAmount(slider: UISlider) -> (quantity: Double, unitName: String, weight: String) {
        
        slider.minimumValue = 0.0
        slider.tag = 0
        
        guard let foodItem = self.foodItem else { return(100, UnitsTexts.cGrams, "100") }
        
        let sliderMultiplier: Float = 5.0
        let maxSliderFromData = Float(1) * sliderMultiplier
        let currentValue = Float(foodItem.amount.selectedQuantity)
        
        if cachedMaxForSlider[foodItem.amount.selectedUnit] == nil {
            cachedMaxForSlider = [foodItem.amount.selectedUnit: sliderMultiplier * currentValue]
            slider.maximumValue = sliderMultiplier * currentValue
        }
        else if let maxFromCache = cachedMaxForSlider[foodItem.amount.selectedUnit],
                maxFromCache > maxSliderFromData, maxFromCache > currentValue {
            slider.maximumValue = maxFromCache
        }
        else if maxSliderFromData > currentValue {
            slider.maximumValue = maxSliderFromData
        }
        else {
            slider.maximumValue = currentValue
            cachedMaxForSlider = [foodItem.amount.selectedUnit: currentValue]
        }
        slider.value = currentValue
                
        return (Double(currentValue),
                foodItem.amount.selectedUnit.capitalizingFirst(),
                String(foodItem.amount.weight().value.oneDigit))
    }
    
    func reloadData() {
        didFetchData = true
        tableView.reloadData()
    }
}

extension FoodDetailVC: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return didFetchData ? 2 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row
        {
        case 0: 
            guard let foodItem = self.foodItem else { return UITableViewCell() }
            let cell = tableView.dequeue(FoodNutrientsCell.self, for: indexPath)
            cell.setup(foodItem: foodItem)
            return cell
            
        case 1:
            let cell = tableView.dequeue(ServingSizeCell.self, for: indexPath)
            let (quantity, unitName, weight) = getAmount(slider: cell.quantitySlider)
            cell.setup(quantity: quantity, unitName: unitName, weight: weight)
            cell.quantityTextField.delegate = self
            cell.unitButton.addTarget(self, action: #selector(onChangeUnit(sender:)), for: .touchUpInside)
            cell.quantitySlider.addTarget(self, action: #selector(onChangeQuantity(sender:)), for: .valueChanged)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

extension FoodDetailVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, text.contains("."), string == "." {
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let quantity = Double(textField.replaceCommaWithDot) else { return }
        self.foodItem?.setSelectedQuantity(quantity)
        reloadData()
    }
}

extension FoodDetailVC: DropDownDelegate {
    func onPickerSelection(value: String, selectedIndex: Int) {
        self.foodItem?.setSelectedUnit(value)
        reloadData()
    }
}
