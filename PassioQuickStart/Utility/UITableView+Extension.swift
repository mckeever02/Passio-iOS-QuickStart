//
//  UITableView+Extension.swift
//  PassioQuickStart
//
//  Created by Pratik on 22/10/24.
//

import UIKit

protocol NibProvidable {
    static var nibName: String { get }
    static var nib: UINib { get }
}

extension NibProvidable {
    static var nibName: String {
        return "\(self)"
    }
    static var nib: UINib {
        return UINib(nibName: self.nibName, bundle: nil)
    }
}

protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return "\(self)"
    }
}

extension UITableView {
    
    func registerNib<T: UITableViewCell>(_ cell: T.Type) {
        let nib = UINib(nibName: "\(cell)", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "\(cell)")
    }
    
    func dequeue<T: UITableViewCell>(_ cell: T.Type, for indexPath: IndexPath) -> T  {
        guard let cell = self.dequeueReusableCell(withIdentifier: "\(cell)", for: indexPath) as? T else {
            fatalError("Error: cell with identifier: \(cell) for index path: \(indexPath) is not \(T.self)")
        }
        return cell
    }
}
