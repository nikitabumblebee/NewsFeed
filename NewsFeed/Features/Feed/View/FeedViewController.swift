//
//  FeedViewController.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import UIKit

class FeedViewController: BaseViewController {
    enum State {
        case none
        case fetching
        case fetchedAll
        case navigating
    }

//    nonisolated enum SectionType: CaseIterable, Hashable {
//        case day
//        case week
//        case month
//        case other
//
//        var title: String {
//            switch self {
//            case .day:
//                "Today's news"
//            case .week:
//                "Week's news"
//            case .month:
//                "Month's news"
//            case .other:
//                "Past news"
//            }
//        }
//
//        var dateRange: ClosedRange<Date> {
//            let now = Date()
//            switch self {
//            case .day:
//                return now.startOfDay() ... now
//            case .week:
//                return now.changeDays(by: -7).startOfDay() ... now.changeDays(by: -1).endOfDay()
//            case .month:
//                return now.changeDays(by: -30).startOfDay() ... now.changeDays(by: -8).endOfDay()
//            case .other:
//                return Date(timeIntervalSince1970: 0) ... now.changeDays(by: -31).endOfDay()
//            }
//        }
//
//        static func == (lhs: SectionType, rhs: SectionType) -> Bool {
//            switch (lhs, rhs) {
//            case (.day, .day), (.week, .week), (.month, .month), (.other, .other):
//                true
//            default:
//                false
//            }
//        }
//    }

    @IBOutlet private var tableView: UITableView!

    override var shouldShowTabBar: Bool { true }

    private let pagingLimit: Int = 50

    typealias DataSource = UITableViewDiffableDataSource<Int, News>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, News>

    private lazy var dataSource = makeDataSource()

    private var currentStateSubject = CurrentValueSubject<State, Never>(.none)

    private let feedParserService: FeedParserService = .shared

    let viewModel: FeedViewModel

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Feed"
        setupTableView()
        setupSubscriptions()
    }

    private func setupTableView() {
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.backgroundColor = .backgroundPrimary
        tableView.refreshControl = refresher
        FeedTableViewCell.registerNib(for: tableView)
    }

    func setupSubscriptions() {
        currentStateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
//                self?.tableView.tableFooterView = currentState == .fetching ? self?.footerActivityIndicator : nil
            }
            .store(in: &cancellables)

        viewModel.$newsModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newsModels in
                print("🚫 \(newsModels.count)")
                self?.applySnapshot(newsModels)
            }
            .store(in: &cancellables)
        feedParserService.initialNewsLoaded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self, $0 else { return }
                viewModel.changeViewState(to: .loaded)
                print("🟡")
                tableView.reloadData()
                loadPagedData(fromBeginning: true)
            }
            .store(in: &cancellables)
    }

    @objc override func updateData() {
        loadPagedData(fromBeginning: true)
    }
}

// MARK: - Data

extension FeedViewController {
    private func loadPagedData(fromBeginning: Bool) {
        currentStateSubject.value = .fetching
        loadData(feedParserService.fetchFeed(fromBeginning: fromBeginning, limit: pagingLimit)) { [weak self] result in
            guard let self else { return }

            hideRefresher()

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
            print("‼️ \(viewModel.contentLoadState)")
            cell.setup(viewModel: NewsViewModel(news: viewModelItem), state: viewModel.contentLoadState)
            return cell
        }
    }

    private func applySnapshot(_ notificationModels: [News]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(notificationModels, toSection: 0)

        dataSource.applySnapshotUsingReloadData(snapshot) { [weak self] in
            self?.currentStateSubject.value = .none
        }
    }
}

// MARK: UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat { 44.0 }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = viewModel.newsModels[indexPath.row]
        let viewController = NewsDetailViewController(viewModel: NewsViewModel(news: viewModel))
        Navigator.shared.push(viewController: viewController)
    }
}
