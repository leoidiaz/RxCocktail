//
//  String+Extension.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 3/4/22.
//

import Foundation

extension String {
    func flatten() -> String {
        return self.components(separatedBy: .whitespaces).joined().lowercased()
    }
}
