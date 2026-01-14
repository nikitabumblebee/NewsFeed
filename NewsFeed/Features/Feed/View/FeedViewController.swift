//
//  FeedViewController.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit
import Combine

class FeedViewController: BaseViewController {
    enum State {
        case none
        case fetching
        case fetchedAll
        case navigating
    }

    nonisolated enum SectionType: CaseIterable, Hashable {
        case day
        case week
        case month
        case other

        var title: String {
            switch self {
            case .day:
                "Today's news"
            case .week:
                "Week's news"
            case .month:
                "Month's news"
            case .other:
                "Past news"
            }
        }
        
        var dateRange: ClosedRange<Date> {
            let now = Date()
            switch self {
            case .day:
                return now.startOfDay()...now
            case .week:
                return now.changeDays(by: -7).startOfDay()...now.changeDays(by: -1).endOfDay()
            case .month:
                return now.changeDays(by: -30).startOfDay()...now.changeDays(by: -8).endOfDay()
            case .other:
                return Date(timeIntervalSince1970: 0)...now.changeDays(by: -31).endOfDay()
            }
        }
        
        static func == (lhs: SectionType, rhs: SectionType) -> Bool {
            switch (lhs, rhs) {
            case (.day, .day), (.week, .week), (.month, .month), (.other, .other):
                true
            default:
                false
            }
        }
    }
    
    @IBOutlet private var tableView: UITableView!
    
    private let headerViewReuseIdentifier: String = String(describing: SectionHeaderView.self)
    private let pagingLimit: Int = 50

    typealias DataSource = UITableViewDiffableDataSource<SectionType, NewsViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionType, NewsViewModel>

    private lazy var dataSource = makeDataSource()

    private var currentStateSubject = CurrentValueSubject<State, Never>(.none)
    
    private let feedParserService: FeedParserService = .shared

    let viewModel: FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Feed"
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.backgroundColor = .backgroundPrimary
        tableView.refreshControl = refresher
        FeedTableViewCell.registerNib(for: tableView)
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
            if let viewModel = viewModelItem as? NewsViewModel {
                let cell = FeedTableViewCell.dequeue(tableView)
                cell.setup(viewModel: viewModel)
            }
            return nil
        }
    }
    
    private func applySnapshot(_ notificationModels: [(SectionType, [NewsViewModel])]) {
        var snapshot = Snapshot()
        notificationModels.forEach {
            snapshot.appendSections([$0.0])
            snapshot.appendItems($0.1, toSection: $0.0)
        }

        dataSource.applySnapshotUsingReloadData(snapshot) { [weak self] in
            self?.currentStateSubject.value = .none
        }
    }
}

// MARK: UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 44.0 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let baseViewModel = viewModel.newsModels[indexPath.section].1[indexPath.row]
        if let viewModel = baseViewModel as? NewsViewModel {
            let viewController = NewsDetailViewController(viewModel: viewModel)
            Navigator.shared.push(viewController: viewController, navigationController: navigationController)
        } else {
            return
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < viewModel.newsModels.count else { return nil }

        let sectionType = viewModel.newsModels[section].0
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
            headerViewReuseIdentifier) as? SectionHeaderView
        view?.titleLabel.text = sectionType.title
        view?.separatorView.isHidden = section == 0

        return view
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard currentStateSubject.value == .none else { return }
        let bottomY = scrollView.contentOffset.y + scrollView.bounds.height

        if bottomY > scrollView.contentSize.height {
            loadPagedData(fromBeginning: false)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard currentStateSubject.value == .none else { return }
        guard indexPath.section == viewModel.newsModels.count - 1 else { return }
        guard indexPath.row == viewModel.newsModels[indexPath.section].1.count - 1 else { return }

        loadPagedData(fromBeginning: false)
    }
}
