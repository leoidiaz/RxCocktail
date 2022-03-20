//
//  RxCocktailTests.swift
//  RxCocktailTests
//
//  Created by Leonardo Diaz on 2/15/22.
//

import XCTest
@testable import RxCocktail

class RxCocktailTests: XCTestCase {
    
    private var viewModel = CocktailViewModel()
    private var images: [UIImage] = []
    
    override func setUp() {
        viewModel.cocktails.accept(fetchMockCocktails())
    }
    
    func testItems() {
        XCTAssertEqual(viewModel.cocktails.value.count, 3)
    }
    
    func testImages() {
        for cocktail in viewModel.cocktails.value {
            images.append(provideImageMock(url: cocktail.image))
        }
        XCTAssertEqual(images.count, 3)
    }
}
