//
//  FeedViewController.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import UIKit

// MARK: - FeedViewController

final class FeedViewController: BaseViewController {
    private enum State {
        case none
        case fetching
        case fetchedAll
    }

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var noNewsLabel: UILabel!

    typealias DataSource = UITableViewDiffableDataSource<Int, BaseNews>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, BaseNews>

    private lazy var dataSource = makeDataSource()

    private var currentStateSubject = CurrentValueSubject<State, Never>(.none)

    private let newsStorage: NewsStorage
    private let navigator: Navigator
    private let imageCache: ImageCache

    let viewModel: FeedViewModel

    init(
        viewModel: FeedViewModel,
        newsStorage: NewsStorage,
        navigator: Navigator,
        imageCache: ImageCache
    ) {
        self.viewModel = viewModel
        self.newsStorage = newsStorage
        self.navigator = navigator
        self.imageCache = imageCache
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Лента"
        setupRefresher()
        setupTableView()
        setupSubscriptions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.handleRefreshTimer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Connectivity.isConnectedToInternet {
            noNewsLabel.text = "Нет новостей\nВключите ресурсы"
        } else {
            noNewsLabel.text = "Нет новостей\nПроверьте соединение с итернетом"
        }
    }

    private func setupTableView() {
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.refreshControl = refresher
        FeedTableViewCell.registerNib(for: tableView)
    }

    override func scrollToTop() {
        guard !viewModel.newsModels.isEmpty else { return }
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }

    func setupSubscriptions() {
        viewModel.$newsModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newsModels in
                self?.applySnapshot(newsModels)
            }
            .store(in: &cancellables)

        viewModel.initialNewsLoadedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self, $0 else { return }
                loadPagedData(fromBeginning: true)
            }
            .store(in: &cancellables)

        viewModel.hideRefresherPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.hideRefresher()
            }
            .store(in: &cancellables)

        viewModel.refreshTimerSignalPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.refresher?.beginRefreshing()
                self?.viewModel.parseNewNews()
            }
            .store(in: &cancellables)

        viewModel.applyNewsFilterPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadPagedData(fromBeginning: true)
            }
            .store(in: &cancellables)

        viewModel.reloadCurrentNewsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                applySnapshot(viewModel.newsModels)
            }
            .store(in: &cancellables)

        Connectivity.internetConnectionFailedSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                let alertViewController = UIAlertController.informationAlert(title: "Нет соединения с интернетом!", message: "Проверьте соединение и обновите стрницу") { [weak self] in
                    self?.hideRefresher()
                }
                let topViewController = navigator.topNavigationController
                navigator.present(viewController: alertViewController, presentingViewController: topViewController)
            }
            .store(in: &cancellables)
    }

    @objc override func updateData() {
        guard viewModel.contentLoadState != .loading else { return }
        viewModel.parseNewNews()
    }
}

// MARK: - Data

extension FeedViewController {
    private func loadPagedData(fromBeginning: Bool) {
        currentStateSubject.value = .fetching
        loadData(newsStorage.fetchNews(fromBeginning: fromBeginning, limit: FeedConstants.pagingLimit)) { [weak self] result in
            guard let self else { return }

            if result.isEmpty, !fromBeginning {
                currentStateSubject.value = .fetchedAll
                return
            }

            if fromBeginning {
                viewModel.clearModels()
            }

            viewModel.buildViewModels(from: result)
        }
    }
}

// MARK: - UITableViewDiffableDataSource

extension FeedViewController {
    private func makeDataSource() -> DataSource {
        DataSource(tableView: tableView) { [weak self] tableView, _, viewModelItem -> UITableViewCell? in
            guard let self else { return nil }
            let cell = FeedTableViewCell.dequeue(tableView)
            cell.setup(news: viewModelItem, state: viewModel.contentLoadState, imageCache: imageCache)
            return cell
        }
    }

    private func applySnapshot(_ newsModels: [any NewsProtocol]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(newsModels.compactMap { $0 as? BaseNews }, toSection: 0)

        dataSource.applySnapshotUsingReloadData(snapshot) { [weak self] in
            self?.currentStateSubject.value = .none
        }
    }
}

// MARK: UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = viewModel.newsModels[indexPath.row]
        let viewController = NewsDetailViewController(viewModel: NewsDetailViewModel(news: viewModel, newsStorage: newsStorage))
        navigator.push(viewController: viewController)
    }

    func tableView(_: UITableView, willDisplay _: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard currentStateSubject.value == .none,
              viewModel.contentLoadState != .loading,
              indexPath.row == viewModel.newsModels.count - 1
        else { return }

        loadPagedData(fromBeginning: false)
    }
}
