//
//  SettingsViewController.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import UIKit

// MARK: - SettingsViewController

final class SettingsViewController: BaseViewController {
    @IBOutlet private var refreshLabel: UILabel!
    @IBOutlet private var refreshSlider: UISlider!
    @IBOutlet private var themeSegmentedControl: UISegmentedControl!
    @IBOutlet private var resetCacheButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var addSourceButton: UIButton!

    private let navigator: Navigator

    let viewModel: SettingsViewModel

    typealias DataSource = UITableViewDiffableDataSource<Int, NewsResource>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, NewsResource>

    private lazy var dataSource = makeDataSource()

    init(viewModel: SettingsViewModel, navigator: Navigator) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    @MainActor required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Настройки"
        setupUI()
        setupTableView()
        setupSubscriptions()
    }

    @IBAction private func onChangeSliderValue(_ sender: UISlider) {
        refreshLabel.text = "Интервал обновления (минуты): \(Int(sender.value))"
        viewModel.changeRefreshTimerDuration(Int(sender.value))
    }

    @IBAction private func onAddNewSource(_: Any) {
        let addOrEditViewModel = AddOrEditResourceViewModel(resource: nil)
        let viewController = AddOrEditResourceViewController(viewModel: addOrEditViewModel, navigator: navigator)
        viewController.onSave = { [weak self] resource in
            guard let self, let resource else { return }
            viewModel.addResource(resource)
        }
        navigator.push(viewController: viewController, navigationController: nil)
    }

    @IBAction private func onResetImagesCache(_: Any) {
        let controller = UIAlertController.confirmationAlert(title: "Вы уверены, что хотите очистить кэш изображений?") { [weak self] in
            self?.viewModel.resetImagesCache()
        }
        let topNavigationController = navigator.topNavigationController
        navigator.present(viewController: controller, presentingViewController: topNavigationController)
    }

    @IBAction func onChangeTheme(_ sender: UISegmentedControl) {
        let theme = AppTheme.allCases[sender.selectedSegmentIndex]
        ThemeManager.shared.applyTheme(theme)
    }

    private func setupUI() {
        themeSegmentedControl.removeAllSegments()
        for theme in AppTheme.allCases.enumerated() {
            themeSegmentedControl.insertSegment(withTitle: theme.element.title, at: theme.offset, animated: false)
        }
        themeSegmentedControl.selectedSegmentIndex = AppTheme.allCases.firstIndex(where: { $0 == viewModel.appTheme }) ?? 0
        refreshSlider.value = Float(viewModel.reloadTimerDuration)
        refreshLabel.text = "Интервал обновления (минуты): \(viewModel.reloadTimerDuration)"
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
            .sink { [weak self] in
                guard let self else { return }
                let controller = UIAlertController.informationAlert(title: "Кэш изображений успешно сброшен!", message: "", actionInfo: {})
                let topNavigationController = navigator.topNavigationController
                navigator.present(viewController: controller, presentingViewController: topNavigationController)
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
        let edit = UIContextualAction(style: .normal, title: "Изменить") { [weak self] _, _, completion in
            guard let self else { return }
            let addOrEditResourceViewModel = AddOrEditResourceViewModel(resource: viewModel.resources[indexPath.row])
            let viewController = AddOrEditResourceViewController(viewModel: addOrEditResourceViewModel, navigator: navigator)
            viewController.onSave = { [weak self] updateResource in
                guard let self, let updateResource else { return }
                viewModel.editResource(resource: viewModel.resources[indexPath.row], to: updateResource)
            }
            navigator.push(viewController: viewController, navigationController: nil)
            completion(true)
        }
        edit.backgroundColor = .accent
        edit.image = UIImage(systemName: "pencil")

        let delete = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            guard let self else { return }
            let alertController = UIAlertController.confirmationAlert(
                title: "Вы уверены, что хотите удалить этот ресурс?",
                message: "Это действие не может быть отменено.",
                actionConfirm: { [weak self] in
                    guard let self else { return }
                    viewModel.deleteResource(viewModel.resources[indexPath.row])
                }
            )
            let topNavigationController = navigator.topNavigationController
            navigator.present(viewController: alertController, presentingViewController: topNavigationController)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
}
