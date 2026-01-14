//
//  BaseViewController.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit
import Combine

class BaseViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView?
    var refresher: UIRefreshControl?
    var cancellables = Set<AnyCancellable>()
    var ignoreScrollView: Bool = false

    var shouldShowTabBar: Bool { true }
    var navigationBarStyle: NavigationBarAppearance.Style {
        (navigationController as? BaseNavigationViewController)?.currentStyle ?? .opaque
    }

    var shouldHideBackButton = false {
        didSet {
            navigationItem.hidesBackButton = shouldHideBackButton
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundPrimary
        updateData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setAppearance(for: navigationBarStyle)
        scrollView?.indicatorStyle = .default
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    var dataCancellables = Set<AnyCancellable>()

    func loadData<T>(_ f: AnyPublisher<T, Never>, handler: @escaping (T) -> Void) {
        f.receive(on: DispatchQueue.main).sink { result in
            handler(result)
        }.store(in: &dataCancellables)
    }

    func execute(_ f: AnyPublisher<some Any, Error>) {
        f.receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { state in
                switch state {
                case .failure(let error):
                    AlertView.showError(with: error.localizedDescription)
                default:
                    break
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func setupRefresher() {
        refresher = UIRefreshControl()
        refresher?.tintColor = .gray4
        refresher?.addTarget(self, action: #selector(updateData), for: .valueChanged)
    }

    func hideRefresher() {
        guard let refresher else { return }
        if refresher.isRefreshing {
            refresher.endRefreshing()
        }
    }

    func addRefresher(view: UIView) {
        guard let refresher else { return }
        view.addSubview(refresher)
    }
    
    @objc func updateData() {
        // clean up all data cancellables
        dataCancellables = Set<AnyCancellable>()
    }
}
