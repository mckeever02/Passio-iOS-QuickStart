//
//  DropDownCell.swift
//  PassioQuickStart
//
//  Created by Pratik on 28/10/24.
//

import UIKit

final class DropDownCell: UITableViewCell {

    @IBOutlet weak var pickerName: UILabel!
    @IBOutlet weak var pickerImageView: UIImageView!
    
    func configure(element: DropDownElement, disableCapatlized: Bool) {
        let title = (element.title ?? "")
        pickerName.text = disableCapatlized ? title : title == "ml" ? title : title.capitalized
        pickerImageView.image = element.image
        pickerImageView.isHidden = element.image == nil
        pickerImageView.tintColor = .indigo600
    }
}
