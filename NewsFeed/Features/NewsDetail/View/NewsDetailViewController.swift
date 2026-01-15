//
//  NewsDetailViewController.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit
import Combine

class NewsDetailViewController: BaseViewController {

    @IBOutlet private var newsImageView: UIImageView!
    @IBOutlet private var newsTitleLabel: UILabel!
    @IBOutlet private var newsBodyLabel: UILabel!
    
    override var shouldShowTabBar: Bool { false }
    
    let viewModel: NewsViewModel
    
    init(viewModel: NewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "News"
        setupUI()
        setupTitleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setupUI() {
        if let image = viewModel.news.image, let url = URL(string: image) {
            Task {
                await newsImageView.loadImage(from: url)
            }
        }
        newsTitleLabel.text = viewModel.news.title
        newsBodyLabel.text = viewModel.news.description
    }
    
    private func setupTitleView() {
        let readSelectorView = ReadSelectorView.loadFromNib()
        readSelectorView.readSelectionChangePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                switch $0 {
                case .short:
                    newsBodyLabel.isHiddenInStackView = true
                case .extended:
                    newsBodyLabel.isHiddenInStackView = false
                }
            }
            .store(in: &cancellables)
        readSelectorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            readSelectorView.widthAnchor.constraint(equalToConstant: 128),
            readSelectorView.heightAnchor.constraint(equalToConstant: 32)
        ])
        navigationItem.titleView = readSelectorView
    }
}
