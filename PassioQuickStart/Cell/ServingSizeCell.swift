//
//  ServingSizeCell.swift
//  
//
//  Created by Pratik on 29/10/24.
//

import UIKit

class ServingSizeCell: UITableViewCell {

    @IBOutlet var inputContainer: UIView!
    @IBOutlet var quantityTextField: UITextField! {
        didSet {
            quantityTextField?.addDoneCancelToolbar()
        }
    }
    @IBOutlet var unitButton: UIButton!
    @IBOutlet var quantitySlider: UISlider!
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


