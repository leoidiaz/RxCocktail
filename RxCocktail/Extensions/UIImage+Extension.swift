//
//  UIImage+Extension.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 6/18/22.
//

import UIKit

extension UIImage {
    static func large() -> UIImage.SymbolConfiguration {
        return self.SymbolConfiguration.init(scale: .large)
    }
    
    static let defaultImage = UIImage(systemName: "photo.fill")!
}
