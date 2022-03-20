//
//  CockTailDetailViewModel.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 2/19/22.
//

import Foundation
import RxSwift
import RxRelay


final class CocktailDetailViewModel {
    
    private var disposeBag = DisposeBag()
    
    var isLoading: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var details: BehaviorRelay<CocktailDetails> = BehaviorRelay(value: CocktailDetails(cocktail: nil, ingredients: nil))
    var ingredients: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    init(cocktail: Cocktail){
        isLoading.accept(true)
        fetchIngredients(cocktail: cocktail)
        observeIngredients()
    }
    
    private func fetchIngredients(cocktail: Cocktail) {
        NetworkManager.fetchDetails(cocktailName: cocktail.name) { [weak self] response in
            switch response {
            case .success(let drinkDetail):
                self?.details.accept(CocktailDetails(cocktail: cocktail, ingredients: drinkDetail.drinks[0]))
                self?.isLoading.accept(false)
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return
            }
        }
    }
    
    private func observeIngredients() {
        details.asObservable().subscribe(onNext: { [weak self] item in
            let newMeasurements:[String] = [item.ingredients?.strMeasure1,
                                item.ingredients?.strMeasure2,
                                item.ingredients?.strMeasure3,
                                item.ingredients?.strMeasure4,
                                item.ingredients?.strMeasure5,
                                item.ingredients?.strMeasure6,
                                item.ingredients?.strMeasure7,
                                item.ingredients?.strMeasure8,
                                item.ingredients?.strMeasure9,
                                item.ingredients?.strMeasure10,
                                item.ingredients?.strMeasure11,
                                item.ingredients?.strMeasure12,
                                item.ingredients?.strMeasure13,
                                item.ingredients?.strMeasure14,
                                item.ingredients?.strMeasure15
            ].compactMap({$0})
            let newIngredients:[String] = [item.ingredients?.strIngredient1,
                               item.ingredients?.strIngredient2,
                               item.ingredients?.strIngredient3,
                               item.ingredients?.strIngredient4,
                               item.ingredients?.strIngredient5,
                               item.ingredients?.strIngredient6,
                               item.ingredients?.strIngredient7,
                               item.ingredients?.strIngredient8,
                               item.ingredients?.strIngredient9,
                               item.ingredients?.strIngredient10,
                               item.ingredients?.strIngredient11,
                               item.ingredients?.strIngredient12,
                               item.ingredients?.strIngredient13,
                               item.ingredients?.strIngredient14,
                               item.ingredients?.strIngredient15
            ].compactMap({$0})
            // Combine the ingredients with measurements to create zipped string
            if !newMeasurements.isEmpty && !newIngredients.isEmpty && !newMeasurements.contains(" slice\n") {
                let filteredNewIngredients: [String] = newIngredients.filter({$0.isEmpty == false})
                let filteredNewMeasurements: [String] = newMeasurements.filter({$0.isEmpty == false})
                let zipped:Zip2Sequence<[String], [String]> = zip(filteredNewMeasurements, filteredNewIngredients)
                let zippedIngredients: [String] = zipped.map({$0 + " " + $1})
                self?.ingredients.accept(zippedIngredients)
            } else {
                let filteredNewIngredients: [String] = newIngredients.filter({$0.isEmpty == false})
                self?.ingredients.accept(filteredNewIngredients)
            }
//            self?.ingredients.accept(newIngredients.joined(separator: "\n"))
//            self?.measurements.accept(newMeasurements.joined(separator: "\n"))
        }).disposed(by: disposeBag)
        
    }
}
