//
//  HomeViewController.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 2/15/22.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    // MARK: - Views
    lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(systemItem: .bookmarks, menu: configureMenu())
        button.tintColor = UIColor.orange
        return button
    }()
    
    private let searchBarController: UISearchController = {
        var search = UISearchController()
        return search
    }()
    
    // MARK: - Properties
    private let tableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    private var filteredList: [Cocktail] = []
    private let viewModel: CocktailViewModel!
    private var disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    init(viewModel: CocktailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cocktails"
        navigationItem.rightBarButtonItem = menuButton
        navigationItem.searchController = searchBarController
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }
    
    private func registerObservers(){
        let source = viewModel.cocktails
        let search = searchBarController.searchBar.rx.text
            .orEmpty
            .throttle(RxTimeInterval.milliseconds(5), scheduler: MainScheduler.asyncInstance)
            .distinctUntilChanged()
        
        Observable.combineLatest(source, search) { [weak self] data, filter in
            guard !data.isEmpty else { return }
            self?.filteredList = !filter.isEmpty ? data.filter({ $0.name.flatten().contains(filter.flatten()) }) : source.value
        }
        .subscribe(onNext: { [weak self] in
            self?.tableView.reloadData()
        })
        .disposed(by: disposeBag)
    }
    
    private func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CocktailCell.self, forCellReuseIdentifier: CocktailCell.reuseIdentifier)
        view.addSubview(tableView)
        addConstraints()
    }
    
    private func configureMenu() -> UIMenu? {
        let alcohols: [UIMenuElement] = AlcoholBase.allCases.compactMap { alcohol in
            let base = alcohol.rawValue.capitalized
            let ingredient = UIAction(title: base, image: nil, state: .on) { [weak self] action in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.ingredient.accept(base)
            }
            return ingredient
        }
        let menu = UIMenu(title: "Alcohol", options: .singleSelection, children: alcohols)
        return menu
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

extension HomeViewController: UITableViewDelegate, UITableViewDataSource, CocktailCellDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CocktailCell.reuseIdentifier, for: indexPath) as? CocktailCell else { return UITableViewCell() }
        let cocktail = filteredList[indexPath.row]
        cell.delegate = self
        cell.cocktailTitle.text = cocktail.name
        configureCell(cocktail: cocktail, favoriteCocktail: nil, imageView: cell.cocktailImageView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cocktail = filteredList[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as? CocktailCell
        let favoriteCocktail = viewModel.fetchFavoriteCocktail(cocktailID: cocktail.id)
        let detailViewModel = CocktailDetailViewModel(cocktail: cocktail,
                                                      cocktailImage: cell?.cocktailImageView.image,
                                                      favoriteCocktail: favoriteCocktail,
                                                      fromDisk: false)
        let detailsViewController = DetailsViewController(viewModel: detailViewModel)
        navigationController?.present(detailsViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func configureCell(cocktail: Cocktail?, favoriteCocktail: FavoriteCocktail?, imageView: UIImageView) {
        guard let cocktail = cocktail else { return }
        viewModel.loadCellImage(cocktail: cocktail, imageView: imageView)
    }
}
