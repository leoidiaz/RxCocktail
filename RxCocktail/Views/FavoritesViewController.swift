//
//  FavoritesViewController.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 6/18/22.
//

import RxSwift
import RxRelay
import SDWebImage
import UIKit

class FavoritesViewController: UIViewController {
    // MARK: - Properties
    lazy var tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var disposeBag = DisposeBag()
    let viewModel: CocktailFavoriteViewModel!
    
    // MARK: - Lifecycle
    init(viewModel: CocktailFavoriteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupObservers()
    }
    
    private func setupObservers() {
        viewModel.favoriteCocktails.asObservable()
            .subscribe { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 100
        tableView.register(CocktailCell.self, forCellReuseIdentifier: CocktailCell.reuseIdentifier)
        view.addSubview(tableView)
        addConstraints()
    }
    
    private func addConstraints(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource, CocktailCellDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favoriteCocktails.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CocktailCell.reuseIdentifier, for: indexPath) as? CocktailCell else { return UITableViewCell() }
        let favoriteCocktail = viewModel.favoriteCocktails.value[indexPath.row]
        cell.delegate = self
        cell.cocktailTitle.text = favoriteCocktail.name
        configureCell(cocktail: nil, favoriteCocktail: favoriteCocktail, imageView: cell.cocktailImageView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favoriteCocktail = viewModel.favoriteCocktails.value[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as? CocktailCell
        let detailViewModel = CocktailDetailViewModel(cocktail: nil, cocktailImage: cell?.cocktailImageView.image, favoriteCocktail: favoriteCocktail, fromDisk: true)
        let detailsViewController = DetailsViewController(viewModel: detailViewModel)
        navigationController?.present(detailsViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func configureCell(cocktail: Cocktail?, favoriteCocktail: FavoriteCocktail?, imageView: UIImageView) {
        guard let favoriteCocktail = favoriteCocktail else { return }
        viewModel.loadCellImage(favoriteCocktail: favoriteCocktail, imageView: imageView)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favoriteCocktail = viewModel.favoriteCocktails.value[indexPath.row]
        let action = UIContextualAction(style: .destructive, title: nil) { [weak self] action, _, completion in
            self?.viewModel.removeFavorite(favoriteCocktail: favoriteCocktail)
            completion(true)
        }
        action.image = UIImage(systemName: "star.slash.fill")
        return UISwipeActionsConfiguration(actions: [action])
    }
}
