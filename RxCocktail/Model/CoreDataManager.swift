//
//  CoreDataManager.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 6/18/22.
//

import Foundation
import SDWebImage
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RxCocktail")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func createNewFavorite(cocktail: Cocktail, cocktailImage: UIImage?, ingredients: [String]) -> Bool {
        let createFavorite = FavoriteCocktail(context: container.viewContext)
        createFavorite.dateAdded = Date()
        createFavorite.name = cocktail.name
        createFavorite.isFavorite = true
        createFavorite.id = cocktail.id
        createFavorite.image = Utility.saveImage(image: cocktailImage, id: cocktail.id)
        createFavorite.cocktailIngredients = ingredients
        saveContext()
        return createFavorite.isFavorite
    }
    
    func removeFavorite(favoriteCocktail: FavoriteCocktail) {
        container.viewContext.delete(favoriteCocktail)
        removeImage(id: favoriteCocktail.id)
        saveContext()
    }
    
    private func removeImage(id: String?) {
        guard let id = id else { return }
        let filename = Utility.getAppDirectory().appendingPathComponent("\(id).png")
        print(filename)
        do {
            // Remove from Cache
            SDImageCache.shared.removeImage(forKey: id)
            // Remove from Disk
            try FileManager.default.removeItem(at: filename)
        } catch let error as NSError {
            print("Error deleting image in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
}
