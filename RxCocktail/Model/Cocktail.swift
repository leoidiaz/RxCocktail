//
//  Cocktail.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 2/16/22.
//

import Foundation

struct Drinks: Decodable {
    var drinks: [Cocktail]
}

struct Cocktail: Decodable {
    var name: String
    var image: String
    var id: String
    
    enum CodingKeys: String, CodingKey {
        case name = "strDrink"
        case image = "strDrinkThumb"
        case id = "idDrink"
    }
}
