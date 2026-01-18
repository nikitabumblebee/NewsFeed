//
//  MainTabBarController.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

final class MainTabBarController: BaseViewController, BaseTabBar {
    var basePresentedViewController: UIViewController?
    var rootView: UIView?

    static let safeAreaViewId = "safeAreaView"
    static let backgroundView = "tabBarBackgroundView"

    @IBOutlet var controllerContainerView: UIView!
    @IBOutlet var backgroundView: UIView!

    @IBOutlet var tabBarView: UIView!
    @IBOutlet private var tabBar: TabBar!
    @IBOutlet var safeAreaView: UIView?
    @IBOutlet var tabBarStackView: UIStackView!

    private(set) var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        rootView = view
        basePresentedViewController = presentedViewController

        safeAreaView?.accessibilityIdentifier = Self.safeAreaViewId
        backgroundView.accessibilityIdentifier = Self.backgroundView
        backgroundView.isHidden = false

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func setupUI() {
        configureTabs()

        tabBar.delegate = self
        tabBar.reloadTabs(0)
    }

    private func configureTabs() {
        configureFeedTabItem()
        configureSettingsTabItem()
    }

    private func configureFeedTabItem() {
        let createTabItem = ImageTabBarItem.loadFromNib()
        createTabItem.type = TabBarItemType(index: 0, name: "Feed")
        createTabItem.iconName = "newspaper"
        createTabItem.title = "Лента"

        let viewModel = FeedViewModel(newsStorage: NewsStorage.shared, feedParser: FeedParserService.shared)
        let viewController = BaseNavigationViewController(rootViewController: FeedViewController(
            viewModel: viewModel,
            newsStorage: NewsStorage.shared,
            navigator: Navigator.shared,
            imageCache: ImageCache.shared
        ))
        tabBar.addTabItem(createTabItem, viewController: viewController)
    }

    private func configureSettingsTabItem() {
        let createTabItem = ImageTabBarItem.loadFromNib()
        createTabItem.type = TabBarItemType(index: 1, name: "Settings")
        createTabItem.iconName = "gear"
        createTabItem.title = "Настройки"

        let viewModel = SettingsViewModel(imageCache: ImageCache.shared, newsStorage: NewsStorage.shared, parserService: FeedParserService.shared)
        let viewController = BaseNavigationViewController(rootViewController: SettingsViewController(viewModel: viewModel, navigator: Navigator.shared))
        tabBar.addTabItem(createTabItem, viewController: viewController)
    }

    func goToFeed() {
        tabBar.selectItem(at: 0)
    }

    func goToSettings() {
        tabBar.selectItem(at: 1)
    }

    func getCurrentViewController() -> UINavigationController? {
        tabBar.getViewController(at: currentIndex) as? UINavigationController
    }

    func getViewController(at tabItem: TabBarItemType) -> UIViewController? {
        tabBar.getViewController(at: tabItem.index)
    }
}

extension MainTabBarController: TabBarDelegate {
    func tabBar(tabBarItem: TabBarItem, didSelectTabAtIndex index: Int, viewController: UIViewController) {
        controllerContainerView.isHidden = false
        viewController.view.layoutInto(controllerContainerView)
        addChild(viewController)
        viewController.didMove(toParent: self)

        currentIndex = index
        ((viewController as? UINavigationController)?.topViewController as? TabDelegate)?.tabWillAppear(tabBarItem)
    }

    func tabBar(tabBarItem _: TabBarItem, didDeselectTabAtIndex _: Int, viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        viewController.view.removeFromSuperview()

        ((viewController as? UINavigationController)?.topViewController as? TabDelegate)?.tabWillDisappear()
    }
}
