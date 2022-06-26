//
//  CocktailFavoriteViewModel.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 6/21/22.
//

import RxSwift
import RxRelay
import CoreData
import SDWebImage
import UIKit

final class CocktailFavoriteViewModel {
    // MARK: - Properties
    var favoriteCocktails: BehaviorRelay<[FavoriteCocktail]> = BehaviorRelay(value: [])
    var images: BehaviorRelay<[UIImage]> = BehaviorRelay(value: [])
    private var disposeBag = DisposeBag()
    
    init() {
        fetchFavoriteStatus()
        observeChanges()
    }
    
    @objc private func fetchFavoriteStatus() {
        let request: NSFetchRequest<FavoriteCocktail> = FavoriteCocktail.fetchRequest()
        do {
            var cocktails = try CoreDataManager.shared.container.viewContext.fetch(request)
            cocktails.sort { $0.dateAdded ?? Date() > $1.dateAdded ?? Date()}
            favoriteCocktails.accept(cocktails)
            fetchImage()
        } catch {
            fatalError("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
    
    func observeChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchFavoriteStatus),
                                               name: .NSManagedObjectContextDidSave,
                                               object: CoreDataManager.shared.container.viewContext)
    }
    
    func loadCellImage(favoriteCocktail: FavoriteCocktail, imageView: UIImageView) {
        imageView.image = UIImage.defaultImage
        guard let id = favoriteCocktail.id else { return }
        
        if let cachedImage = SDImageCache.shared.imageFromCache(forKey: id) {
            imageView.image = cachedImage
        } else {
            Utility.loadImageData(id: id) { data in
                DispatchQueue.main.async {
                    let cocktailImage = UIImage(data: data)
                    imageView.image = cocktailImage ?? UIImage.defaultImage
                    SDImageCache.shared.store(cocktailImage, imageData: nil, forKey: id, cacheType: .memory)
                }
            }
        }
    }
    
    func fetchImage() {
        var newImages: [UIImage] = []
        favoriteCocktails.value.forEach { favoriteCocktail in
            if let id = favoriteCocktail.id {
                Utility.loadImageData(id: id) { data in
                    let image = UIImage(data: data) ?? UIImage.defaultImage
                    newImages.append(image)
                }
            } else {
                newImages.append(UIImage.defaultImage)
            }
        }
        images.accept(newImages)
    }
    
    func removeFavorite(favoriteCocktail: FavoriteCocktail) {
        CoreDataManager.shared.removeFavorite(favoriteCocktail: favoriteCocktail)        
    }
}
