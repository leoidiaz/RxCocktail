//
//  CocktailMock.swift
//  RxCocktailTests
//
//  Created by Leonardo Diaz on 3/20/22.
//

import Foundation
@testable import RxCocktail
import UIKit

func fetchMockCocktails() -> [Cocktail]{
    return [
        Cocktail(name: "Vodka Soda", image: "cup.and.saucer.fill", id: "112"),
        Cocktail(name: "Moscow Mule", image: "photo.fill", id: "82"),
        Cocktail(name: "Paloma", image: "star.fill", id: "232"),
    ]
}

func provideImageMock(url: String) -> UIImage {
    return UIImage(systemName: url)!
}
