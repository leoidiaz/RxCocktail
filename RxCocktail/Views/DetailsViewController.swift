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
    // MARK: - Properties
    private var viewModel: CocktailDetailViewModel!
    private var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Views
    lazy var closeButton: UIButton = {
        let barButton = UIButton(type: .close)
        barButton.translatesAutoresizingMaskIntoConstraints = false
        return barButton
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
        title.numberOfLines = 1
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .preferredFont(forTextStyle: .title2)
        return title
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
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
        
        viewModel.details.asObservable().subscribe(onNext: { [weak self] item in
            if let image = SDImageCache.shared.imageFromCache(forKey: item.cocktail?.image) {
                self?.imageView.image = image
            }
            self?.titleLabel.text = item.cocktail?.name
        }).disposed(by: disposeBag)
        
        viewModel.ingredients.asObservable().subscribe(onNext: { [weak self] _ in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    @objc func closeButtonAction() {
        dismiss(animated: true)
    }
    
    private func addConstraints(){
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            imageView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 250),
            imageView.widthAnchor.constraint(equalToConstant: 250),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -16),
            tableView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
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
