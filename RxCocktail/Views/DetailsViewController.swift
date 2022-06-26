//
//  DetailsViewController.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 2/20/22.
//

import UIKit
import RxSwift
import SDWebImage

class DetailsViewController: UIViewController {
    struct Constants {
        static let star = "star"
        static let starFill = "star.fill"
        static let padding: CGFloat = 16
        static let imageSize: CGFloat = 250
    }
    // MARK: - Properties
    private var viewModel: CocktailDetailViewModel!
    private var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Views
    lazy var closeButton: UIButton = {
        let barButton = UIButton(type: .close)
        barButton.translatesAutoresizingMaskIntoConstraints = false
        return barButton
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.orange
        button.setImage(UIImage(systemName: Constants.star, withConfiguration: UIImage.large()), for: .normal)
        button.setImage(UIImage(systemName: Constants.starFill, withConfiguration: UIImage.large()), for: .selected)
        return button
    }()
    
    lazy var progressIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .black
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.numberOfLines = 0
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .preferredFont(forTextStyle: .title2)
        return title
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: Constants.imageSize, height: Constants.imageSize))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 5
        return imageView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Initialize
    init(viewModel: CocktailDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        configFavorite()
        addConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposeBag = DisposeBag()
    }
    
    private func registerObserver(){
        viewModel.isLoading.asObservable().subscribe(onNext: { [weak self] result in
            result == true ? self?.progressIndicator.startAnimating() : self?.progressIndicator.stopAnimating()
        }).disposed(by: disposeBag)
        
        titleLabel.text = viewModel.cocktail?.name ?? viewModel.favoriteCocktail?.name
        
        viewModel.isFavorite.asObservable().subscribe { [weak self] isFavorite in
            if let isFavorite = isFavorite.element {
                self?.favoriteButton.isSelected = isFavorite
            }
        }.disposed(by: disposeBag)
        
        viewModel.ingredients.asObservable().subscribe(onNext: { [weak self] _ in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.shouldDismiss.asObservable().subscribe { [weak self] value in
            if let value = value.element, value {
                self?.dismiss(animated: true)
            }
        }.disposed(by: disposeBag)
    }
    
    @objc func favoriteButtonToggle() {
        viewModel.didToggleFavorite()
    }
    
    @objc func closeButtonAction() {
        dismiss(animated: true)
    }
    
    private func addConstraints(){
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.padding),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            
            favoriteButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.padding),
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
            
            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            imageView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: Constants.padding),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.padding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -Constants.padding),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.padding),
            tableView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -Constants.padding),
            tableView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Constants.padding),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configView(){
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(tableView)
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(progressIndicator)
        view.addSubview(imageView)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .secondarySystemBackground
        tableView.dataSource = self
        tableView.delegate = self
        closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        imageView.image = viewModel.cocktailImage
    }
    
    private func configFavorite() {
        favoriteButton.addTarget(self, action: #selector(favoriteButtonToggle), for: .touchUpInside)
        view.addSubview(favoriteButton)
    }
}

extension DetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.ingredients.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        cell.backgroundColor = .systemBackground
        content.text = viewModel.ingredients.value[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
}
