//
//  SettingsViewController.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import UIKit

class SettingsViewController: BaseViewController {
    @IBOutlet private var refreshLabel: UILabel!
    @IBOutlet private var refreshSlider: UISlider!
    @IBOutlet private var themeSegmentedControl: UISegmentedControl!
    @IBOutlet private var resetCacheButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addSourceButton: UIButton!
    @IBOutlet private var deleteSourceButton: UIButton!

    let viewModel: SettingsViewModel

    private var isSelectedSource: Bool = false

    typealias DataSource = UITableViewDiffableDataSource<Int, NewsResource>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, NewsResource>

    private lazy var dataSource = makeDataSource()

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    @MainActor required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Settings"
        setupUI()
        setupTableView()
        setupSubscriptions()
    }

    @IBAction private func onChangeSliderValue(_ sender: UISlider) {
        refreshLabel.text = "Refresh Interval (minutes): \(Int(sender.value))"
        viewModel.changeRefreshTimerDuration(Int(sender.value))
    }

    @IBAction private func onAddNewSource(_: Any) {
        print("🟢")
    }

    @IBAction private func onDeleteSource(_: Any) {
        print("🔴")
    }

    @IBAction private func onResetImagesCache(_: Any) {
        let controller = UIAlertController.confirmationAlert(title: "Are you sure to clear images cache?") { [weak self] in
            self?.viewModel.resetImagesCache()
        }
        let topNavigationController = Navigator.shared.topNavigationController
        Navigator.shared.present(viewController: controller, presentingViewController: topNavigationController)
    }

    private func setupUI() {
        themeSegmentedControl.removeAllSegments()
        for theme in AppTheme.Theme.allCases.enumerated() {
            themeSegmentedControl.insertSegment(withTitle: theme.element.rawValue, at: theme.offset, animated: false)
        }
        themeSegmentedControl.selectedSegmentIndex = 0
        refreshSlider.value = Float(viewModel.reloadTimerDuration)
        refreshLabel.text = "Refresh Interval (minutes): \(viewModel.reloadTimerDuration)"
    }

    private func setupTableView() {
        tableView.allowsMultipleSelection = false
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.sectionIndexBackgroundColor = .accent
        NewsSourceTableViewCell.registerNib(for: tableView)
    }

    private func setupSubscriptions() {
        viewModel.sourcesListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.applySnapshot($0)
            }
            .store(in: &cancellables)
        viewModel.cacheResetSuccessPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                let controller = UIAlertController.informationAlert(title: "Images cache was successfully reset!", message: "", actionInfo: {})
                let topNavigationController = Navigator.shared.topNavigationController
                Navigator.shared.present(viewController: controller, presentingViewController: topNavigationController)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDiffableDataSource

extension SettingsViewController {
    private func makeDataSource() -> DataSource {
        DataSource(tableView: tableView) { tableView, _, viewModelItem -> UITableViewCell? in
            let cell = NewsSourceTableViewCell.dequeue(tableView)
            cell.setup(newsSource: viewModelItem)
            cell.onResourceSwitchChange = { [weak self] isOn in
                if isOn {
                    self?.viewModel.enableSource(viewModelItem)
                } else {
                    self?.viewModel.disableSource(viewModelItem)
                }
            }
            return cell
        }
    }

    private func applySnapshot(_ newsSources: [NewsResource]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(newsSources, toSection: 0)

        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}

// MARK: UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSource = viewModel.sources[indexPath.row]
        if selectedSource == viewModel.selectedSource {
            isSelectedSource = false
            deleteSourceButton.isEnabled = false
            viewModel.deselectSource()
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.isSelected = false
            }
        } else {
            isSelectedSource = true
            deleteSourceButton.isEnabled = true
            viewModel.selectSource(selectedSource)
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        52
    }
}
