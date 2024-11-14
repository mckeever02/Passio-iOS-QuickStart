//
//  File.swift
//  
//
//  Created by Pratik on 28/10/24.
//

import UIKit

extension UIView {
    
    @IBInspectable var isRounded: Bool {
        get {
            return self.isRounded
        }
        set {
            if newValue {
                roundCorner()
            }
        }
    }
    
    func roundCorner() {
        let radius = min(self.bounds.height, self.bounds.width)/2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
    func setShadow(radius: CGFloat,
                   offset: CGSize,
                   color: UIColor,
                   shadowRadius: CGFloat,
                   shadowOpacity: Float,
                   istopBottomRadius: Bool = false,
                   isUpperRadius: Bool = false,
                   isDownRadius: Bool = false) {
        layer.cornerRadius = radius
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
