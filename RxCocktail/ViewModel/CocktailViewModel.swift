//
//  CocktailViewModel.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 2/16/22.
//

import Foundation
import RxSwift
import RxRelay
import UIKit

final class CocktailViewModel {
    
    var cocktails: BehaviorRelay<[Cocktail]> = BehaviorRelay(value: [])
    var images: BehaviorRelay<[UIImage]> = BehaviorRelay(value: [])
    
    var ingredient: String = "" {
        didSet {
            fetchCocktails()
            fetchImage()
        }
    }
    
    private func fetchCocktails(){
        guard !ingredient.isEmpty else { return }
        NetworkManager.fetchIngredient(ingredient: ingredient) { results in
            DispatchQueue.main.async {
                switch results {
                case .success(let drinks):
                    let newCocktails = drinks.drinks
                    self.cocktails.accept(newCocktails)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchImage() {
        var newImages: [UIImage] = []
        for cocktail in cocktails.value {
            NetworkManager.fetchImage(imageURL: cocktail.image) { image in
                guard let image = image else {
                    newImages.append(UIImage(systemName: "photo.fill")!)
                    return
                }
                newImages.append(image)
            }
        }
        images.accept(newImages)
    }
}
