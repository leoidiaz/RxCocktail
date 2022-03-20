//
//  CocktailCell.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 2/15/22.
//

import UIKit
import Alamofire

class CocktailCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureCell(cocktail: Cocktail) {
        var content = defaultContentConfiguration()
        content.text = cocktail.name
        content.imageProperties.maximumSize = CGSize(width: 30, height: 40)
        content.imageProperties.cornerRadius = 5
        content.textProperties.font = UIFont.preferredFont(forTextStyle: .title3)
        content.image = UIImage(systemName: "photo.fill")
        contentConfiguration = content
        NetworkManager.fetchImage(imageURL: cocktail.image) { [weak self] cocktailImage in
            if let image = cocktailImage {
                content.image = image
                self?.contentConfiguration = content
            }
        }
    }
}
