//
//  SettingsViewController.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import UIKit

final class SettingsViewController: BaseViewController {
    @IBOutlet private var refreshLabel: UILabel!
    @IBOutlet private var refreshSlider: UISlider!
    @IBOutlet private var themeSegmentedControl: UISegmentedControl!
    @IBOutlet private var resetCacheButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addSourceButton: UIButton!

    let viewModel: SettingsViewModel

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
        let addOrEditViewModel = AddOrEditResourceViewModel(resource: nil)
        let viewController = AddOrEditResourceViewController(viewModel: addOrEditViewModel)
        viewController.onSave = { [weak self] resource in
            guard let self, let resource else { return }
            viewModel.addResource(resource)
        }
        Navigator.shared.push(viewController: viewController, navigationController: nil)
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
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.sectionIndexBackgroundColor = .accent
        tableView.allowsSelection = false
        NewsResourceTableViewCell.registerNib(for: tableView)
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
            let cell = NewsResourceTableViewCell.dequeue(tableView)
            cell.setup(newsResource: viewModelItem)
            cell.onResourceSwitchChange = { [weak self] isOn in
                if isOn {
                    self?.viewModel.enableResource(viewModelItem)
                } else {
                    self?.viewModel.disableResource(viewModelItem)
                }
            }
            return cell
        }
    }

    private func applySnapshot(_ newsResources: [NewsResource]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(newsResources, toSection: 0)

        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}

// MARK: UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            guard let self else { return }
            let addOrEditResourceViewModel = AddOrEditResourceViewModel(resource: viewModel.resources[indexPath.row])
            let viewController = AddOrEditResourceViewController(viewModel: addOrEditResourceViewModel)
            viewController.onSave = { [weak self] updateResource in
                guard let self, let updateResource else { return }
                viewModel.editResource(resource: viewModel.resources[indexPath.row], to: updateResource)
            }
            Navigator.shared.push(viewController: viewController, navigationController: nil)
            completion(true)
        }
        edit.backgroundColor = .accent
        edit.image = UIImage(systemName: "pencil")

        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else { return }
            let alertController = UIAlertController.confirmationAlert(title: "Are you sure you want to delete this resource?", message: "This action cannot be undone.", actionConfirm: { [weak self] in
                guard let self else { return }
                viewModel.deleteResource(viewModel.resources[indexPath.row])
            })
            let topNavigationController = Navigator.shared.topNavigationController
            Navigator.shared.present(viewController: alertController, presentingViewController: topNavigationController)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
}
