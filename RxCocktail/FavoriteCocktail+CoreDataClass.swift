//
//  FavoriteCocktail+CoreDataClass.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 6/25/22.
//
//

import Foundation
import CoreData

@objc(FavoriteCocktail)
public class FavoriteCocktail: NSManagedObject {
    var cocktailIngredients: [String] {
        get {
            guard let ingredients = ingredients else { return [] }
            let data = Data(ingredients.utf8)
            return (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                ingredients = String(data: data, encoding: .utf8)
            }
        }
    }
}
