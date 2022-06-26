//
//  CocktailCell.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 2/15/22.
//

import UIKit

protocol CocktailCellDelegate: AnyObject {
    func configureCell(cocktail: Cocktail?, favoriteCocktail: FavoriteCocktail?, imageView: UIImageView)
}

class CocktailCell: UITableViewCell {
    weak var delegate: CocktailCellDelegate?
    
    let cocktailImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let cocktailTitle: UILabel = {
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        cocktailImageView.image = UIImage.defaultImage
        super.prepareForReuse()
    }
    
    private func setupView() {
        cocktailTitle.font = UIFont.preferredFont(forTextStyle: .title3)
        cocktailImageView.layer.cornerRadius = 5
        cocktailImageView.clipsToBounds = true
        contentView.addSubview(cocktailImageView)
        contentView.addSubview(cocktailTitle)
        NSLayoutConstraint.activate([
            cocktailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cocktailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cocktailImageView.widthAnchor.constraint(equalToConstant: 30),
            cocktailImageView.heightAnchor.constraint(equalToConstant: 30),
            cocktailTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cocktailTitle.leadingAnchor.constraint(equalTo: cocktailImageView.trailingAnchor, constant: 16),
            cocktailTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cocktailTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
}
