//
//  UITableViewCell+Extension.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 2/19/22.
//

import UIKit.UITableViewCell

extension UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self.self)
    }
}
