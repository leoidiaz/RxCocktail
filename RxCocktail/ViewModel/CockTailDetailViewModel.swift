//
//  CockTailDetailViewModel.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 2/19/22.
//

import Foundation
import RxSwift
import RxRelay
import CoreData
import SDWebImage
import UIKit

final class CocktailDetailViewModel {
    
    private var disposeBag = DisposeBag()
    var isFavorite: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var fromDisk: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var shouldDismiss: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var ingredients: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    var favoriteCocktail: FavoriteCocktail?
    var cocktail: Cocktail?
    var cocktailImage: UIImage?
    
    init(cocktail: Cocktail?, cocktailImage: UIImage?, favoriteCocktail: FavoriteCocktail?, fromDisk: Bool) {
        self.cocktail = cocktail
        self.cocktailImage = cocktailImage
        self.fromDisk.accept(fromDisk)
        isLoading.accept(true)
        if let favoriteCocktail = favoriteCocktail  {
            self.favoriteCocktail = favoriteCocktail
            isFavorite.accept(favoriteCocktail.isFavorite)
        }
        fetchIngredients()
    }
    
    private func fetchIngredients() {
        if fromDisk.value {
            ingredients.accept(favoriteCocktail?.cocktailIngredients ?? [""])
            isLoading.accept(false)
        } else {
            guard let cocktail = cocktail else { return }
            NetworkManager.fetchDetails(cocktailName: cocktail.name) { [weak self] response in
                switch response {
                case .success(let drinkDetail):
                    guard let self = self else { return }
                    let processedIngredients = self.processIngredients(ingredients: drinkDetail.drinks[0])
                    self.ingredients.accept(processedIngredients)
                    self.isLoading.accept(false)
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    return
                }
            }
        }
    }
    
    //TODO: Move to NetworkManager
    private func processIngredients(ingredients: RawDetails) -> [String] {
        var filteredIngredients: [String] = []
        let newMeasurements:[String] = [ingredients.strMeasure1,
                                        ingredients.strMeasure2,
                                        ingredients.strMeasure3,
                                        ingredients.strMeasure4,
                                        ingredients.strMeasure5,
                                        ingredients.strMeasure6,
                                        ingredients.strMeasure7,
                                        ingredients.strMeasure8,
                                        ingredients.strMeasure9,
                                        ingredients.strMeasure10,
                                        ingredients.strMeasure11,
                                        ingredients.strMeasure12,
                                        ingredients.strMeasure13,
                                        ingredients.strMeasure14,
                                        ingredients.strMeasure15
        ].compactMap({$0})
        let newIngredients:[String] = [ingredients.strIngredient1,
                                       ingredients.strIngredient2,
                                       ingredients.strIngredient3,
                                       ingredients.strIngredient4,
                                       ingredients.strIngredient5,
                                       ingredients.strIngredient6,
                                       ingredients.strIngredient7,
                                       ingredients.strIngredient8,
                                       ingredients.strIngredient9,
                                       ingredients.strIngredient10,
                                       ingredients.strIngredient11,
                                       ingredients.strIngredient12,
                                       ingredients.strIngredient13,
                                       ingredients.strIngredient14,
                                       ingredients.strIngredient15
        ].compactMap({$0})
        // Combine the ingredients with measurements to create zipped string
        if !newMeasurements.isEmpty && !newIngredients.isEmpty && !newMeasurements.contains(" slice\n") {
            let filteredNewIngredients: [String] = newIngredients.filter({$0.isEmpty == false})
            let filteredNewMeasurements: [String] = newMeasurements.filter({$0.isEmpty == false})
            let zipped:Zip2Sequence<[String], [String]> = zip(filteredNewMeasurements, filteredNewIngredients)
            let zippedIngredients: [String] = zipped.map({$0 + " " + $1})
            filteredIngredients += zippedIngredients
        } else {
            let filteredNewIngredients: [String] = newIngredients.filter({$0.isEmpty == false})
            filteredIngredients += filteredNewIngredients
        }
        return filteredIngredients
    }
    
    func didToggleFavorite() {
        if isFavorite.value {
            guard let favoriteCocktail = favoriteCocktail else { return }
            CoreDataManager.shared.removeFavorite(favoriteCocktail: favoriteCocktail)
            isFavorite.accept(false)
            if cocktail == nil {
                shouldDismiss.accept(true)
            }
        } else {
            guard let cocktail = cocktail else { return }
            let newFavorite = CoreDataManager.shared.createNewFavorite(cocktail: cocktail, cocktailImage: cocktailImage, ingredients: ingredients.value)
            isFavorite.accept(newFavorite)
        }
    }
}
