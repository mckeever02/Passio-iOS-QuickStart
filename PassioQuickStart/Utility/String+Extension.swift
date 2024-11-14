//
//  String+Extension.swift
//  PassioQuickStart
//
//  Created by Pratik on 30/10/24.
//

import Foundation

extension String {
    func capitalizingFirst() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}
