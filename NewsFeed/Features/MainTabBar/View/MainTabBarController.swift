//
//  MainTabBarController.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

final class MainTabBarController: BaseViewController {
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
        tabBar.reloadTabs(TabBarItemType.feed.rawValue)
    }

    private func configureTabs() {
        configureFeedTabItem()
        configureSettingsTabItem()
    }

    private func configureFeedTabItem() {
        let createTabItem = ImageTabBarItem.loadFromNib()
        createTabItem.type = .feed
        createTabItem.iconName = "icon-button-create"

        let viewModel = FeedViewModel()
        let viewController = BaseNavigationViewController(rootViewController: FeedViewController(viewModel: viewModel))
        tabBar.addTabItem(createTabItem, viewController: viewController)
    }

    private func configureSettingsTabItem() {
        let createTabItem = ImageTabBarItem.loadFromNib()
        createTabItem.type = .settings
        createTabItem.iconName = "icon-button-create"
        
        let viewModel = SettingsViewModel()
        let viewController = BaseNavigationViewController(rootViewController: SettingsViewController(viewModel: viewModel))
        tabBar.addTabItem(createTabItem, viewController: viewController)
    }

    func goToFeed() {
        tabBar.selectItem(at: 0)
    }

    func goToSettings() {
        tabBar.selectItem(at: TabBarItemType.settings.rawValue)
    }
    
    func getCurrentViewController() -> UINavigationController? {
        tabBar.getViewController(at: currentIndex) as? UINavigationController
    }

    func getViewController(at tabItem: TabBarItemType) -> UIViewController? {
        tabBar.getViewController(at: tabItem.rawValue)
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

    func tabBar(tabBarItem: TabBarItem, didDeselectTabAtIndex: Int, viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        viewController.view.removeFromSuperview()

        ((viewController as? UINavigationController)?.topViewController as? TabDelegate)?.tabWillDisappear()
    }
}
