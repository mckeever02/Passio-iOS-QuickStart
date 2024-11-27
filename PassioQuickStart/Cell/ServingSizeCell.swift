//
//  ServingSizeCell.swift
//  
//
//  Created by Pratik on 29/10/24.
//

import UIKit

class CustomSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let point = CGPoint(x: bounds.minX, y: bounds.midY)
        return CGRect(origin: point, size: CGSize(width: bounds.width, height: 8))
    }
}

class ServingSizeCell: UITableViewCell {

    @IBOutlet var inputContainer: UIView!
    @IBOutlet var quantityTextField: UITextField! {
        didSet {
            quantityTextField?.addDoneCancelToolbar()
        }
    }
    @IBOutlet var unitButton: UIButton!
    @IBOutlet var quantitySlider: CustomSlider!
    @IBOutlet var weightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        basicSetup()
    }
    
    func basicSetup() {
        inputContainer.setShadow(radius: 8,
                                 offset: CGSize(width: 0, height: 1),
                                 color: .black.withAlphaComponent(0.06),
                                 shadowRadius: 2,
                                 shadowOpacity: 1)
        
        quantitySlider.isContinuous = false
        quantitySlider.tintColor = .theme
        quantitySlider.maximumTrackTintColor = .theme.withAlphaComponent(0.08)
        quantitySlider.thumbTintColor = .theme
        let image = UIImage.sliderThumb
        quantitySlider.setThumbImage(image, for: .normal)
        quantitySlider.setThumbImage(image, for: .highlighted)
    }
    
    func setup(quantity: Double, unitName: String, weight: String) {
        let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) : quantity.twoDigits
        quantityTextField.text = textAmount
        quantityTextField.backgroundColor = .white
        weightLabel.text = unitName ==  UnitsTexts.g ? "" : "(" + weight + " " + UnitsTexts.g + ") "
        let newTitle = " " + unitName.capitalized
        unitButton.setTitle(newTitle, for: .normal)
    }
}


