//
//  CocktailViewModel.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 2/16/22.
//

import Foundation
import RxSwift
import RxRelay
import CoreData
import UIKit

final class CocktailViewModel {
    
    var cocktails: BehaviorRelay<[Cocktail]> = BehaviorRelay(value: [])
    var images: BehaviorRelay<[UIImage]> = BehaviorRelay(value: [])
    var favoriteCocktails: BehaviorRelay<[FavoriteCocktail]> = BehaviorRelay(value: [])
    var ingredient: BehaviorRelay<String> = BehaviorRelay(value: AlcoholBase.vodka.rawValue.capitalized)
    
    private let disposeBag = DisposeBag()
    
    init() {
        fetchFavoriteStatus()
        observeChanges()
    }

    private func fetchCocktails(alcoholBase: String){
        guard !ingredient.value.isEmpty else { return }
        NetworkManager.fetchIngredient(ingredient: alcoholBase) { results in
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
    
    func loadCellImage(cocktail: Cocktail, imageView: UIImageView) {
        NetworkManager.fetchImage(imageURL: cocktail.image) { cocktailImage in
            if let image = cocktailImage {
                imageView.image = image
            }
        }
    }
    
    @objc private func fetchFavoriteStatus() {
        let request: NSFetchRequest<FavoriteCocktail> = FavoriteCocktail.fetchRequest()
        do {
            let favorites = try CoreDataManager.shared.container.viewContext.fetch(request)
            favoriteCocktails.accept(favorites)
        } catch {
            fatalError("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
    
    func fetchFavoriteCocktail(cocktailID: String) -> FavoriteCocktail? {
        let cocktail = favoriteCocktails.value.filter { cocktail in
            return cocktail.id == cocktailID
        }
        guard !cocktail.isEmpty else { return nil }
        return cocktail.first
    }
    
    func observeChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchFavoriteStatus),
                                               name: .NSManagedObjectContextDidSave,
                                               object: CoreDataManager.shared.container.viewContext)
        
        ingredient.asObservable().subscribe { [weak self] alcoholBase in
            if let element = alcoholBase.element {
                self?.fetchCocktails(alcoholBase: element)
                self?.fetchImage()
            }
        }.disposed(by: disposeBag)
    }
}
