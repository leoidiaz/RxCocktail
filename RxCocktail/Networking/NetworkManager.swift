//
//  NetworkManager.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 2/16/22.
//

import UIKit
import Alamofire
import SDWebImage

struct NetworkManager {
    
    typealias DrinksCompletion = (Result<Drinks, AFError>) -> Void
    typealias DetailDrinksCompletion = (Result<DetailDrink, AFError>) -> Void
    
    static func fetchIngredient(ingredient: String, completion: @escaping DrinksCompletion) {
        let path = "/api/json/v1/1/filter.php"
        let query = "i="
        guard var urlRequest = URLComponents.request(path: path, query: query, parameter: ingredient) else { return }
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        AF.request(urlRequest).validate().responseDecodable(of: Drinks.self) { response in
            completion(response.result)
        }
    }
    
    static func fetchImage(imageURL: String, completion: @escaping (UIImage?) -> Void) {
        SDWebImageManager.shared.loadImage(with: URL(string: imageURL), options: [.highPriority, .progressiveLoad], progress: nil) { image, _, error, cache, _, _ in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
            }
                completion(image)
        }
    }
    
    static func fetchImage(imageURL: URL, completion: @escaping (UIImage?) -> Void) {
        SDWebImageManager.shared.loadImage(with: imageURL, options: [.highPriority, .progressiveLoad], progress: nil) { image, _, error, cache, _, _ in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
            }
                completion(image)
        }
    }
    
    static func fetchDetails(cocktailName: String, completion: @escaping DetailDrinksCompletion) {
        let path = "/api/json/v1/1/search.php"
        let query = "s="
        guard var urlRequest = URLComponents.request(path: path, query: query, parameter: cocktailName) else { return }
        urlRequest.cachePolicy = .returnCacheDataElseLoad
        AF.request(urlRequest).validate().responseDecodable(of: DetailDrink.self) { response in
            completion(response.result)
        }
    }
}

extension URLComponents {
    static func request(scheme: String = "https",
                        host: String = "www.thecocktaildb.com",
                        path: String,
                        query: String,
                        parameter: String) -> URLRequest? {
        var urlComponent = self.init()
       urlComponent.scheme = scheme
       urlComponent.host = host
       urlComponent.path = path
       urlComponent.query = "\(query)\(parameter)"
       guard let url = urlComponent.url else { return nil }
       return URLRequest(url: url)
   }
}
