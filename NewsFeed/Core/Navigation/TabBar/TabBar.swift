//
//  TabBar.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

class TabBar: UIStackView {
    private var tabItems = [TabBarItem]()
    private var viewControllers = [UIViewController]()
    private var currentItemIndex: Int?
    private var recentItemIndex: Int?
    private let navigator = Navigator.shared

    weak var delegate: TabBarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupTabBar()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)

        setupTabBar()
    }

    private func setupTabBar() {
        distribution = .fillEqually
        alignment = .fill
    }

    func addTabItem(_ tabItem: TabBarItem, viewController: UIViewController) {
        tabItems.append(tabItem)
        viewControllers.append(viewController)
        addArrangedSubview(tabItem)

        tabItem.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
    }

    @objc private func itemTapped(_ sender: TabBarItem) {
        guard let index = tabItems.firstIndex(of: sender) else { return }
        recentItemIndex = currentItemIndex ?? index
        selectItem(at: index)
    }

    func getTabItem(at index: Int) -> TabBarItem? {
        guard index < tabItems.count else {
            return .none
        }
        return tabItems[index]
    }

    func getTabItem(for type: TabBarItemType) -> TabBarItem? {
        guard !tabItems.isEmpty else { return .none }
        return tabItems.filter { $0.type.index == type.index }.first
    }

    func getViewController(for type: TabBarItemType) -> UIViewController? {
        let item = getTabItem(for: type)
        guard let index = tabItems.firstIndex(where: { $0 == item }),
              index < viewControllers.endIndex
        else {
            return nil
        }
        return viewControllers[index]
    }

    func getViewController(at index: Int) -> UIViewController? {
        guard index < viewControllers.count else {
            return .none
        }
        return viewControllers[index]
    }

    func popToRootCurrentView() {
        for viewController in viewControllers {
            let navigation = viewController as? UINavigationController ?? viewController.navigationController
            navigation?.popToRootViewController(animated: false)
        }
    }

    func selectItem(at index: Int, skipRootReturn: Bool = false, from _: String? = nil) {
        guard index != currentItemIndex else {
            // first we do actions with the current screen, for example, if we were on the home page and pressed home
            if let navigationViewController = viewControllers[index] as? BaseNavigationViewController {
                (navigationViewController.topViewController as? BaseViewController)?.scrollToTop()
            } else if let viewController = viewControllers[index] as? BaseViewController {
                viewController.scrollToTop()
            }

            // and after that we do navigation to the root screen if necessary, if necessary
            if !skipRootReturn {
                let navigation = viewControllers[index] as? UINavigationController ?? viewControllers[index].navigationController
                navigation?.popToRootViewController(animated: true)
                navigator.popToRoot()
            }

            return
        }

        guard let sender = tabItems[safe: index] else { return }

        if let currentItemIndex {
            deselectItem(at: currentItemIndex, selectedIndex: index, senderType: sender.presentationContext)
        }

        currentItemIndex = index
        sender.setSelected(true)
        delegate?.tabBar(tabBarItem: sender, didSelectTabAtIndex: index, viewController: viewControllers[index])
    }

    func goToRecentTab() {
        selectItem(at: recentItemIndex ?? 0)
    }

    func reloadTabs(_ initialTabItemIndex: Int) {
        if let currentItemIndex {
            let tabBarItem = tabItems[currentItemIndex]
            tabBarItem.setSelected(false)
            delegate?.tabBar(tabBarItem: tabBarItem, didDeselectTabAtIndex: currentItemIndex, viewController: viewControllers[currentItemIndex])
        }
        currentItemIndex = initialTabItemIndex
        let tabBarItem = tabItems[initialTabItemIndex]
        tabBarItem.setSelected(true)
        delegate?.tabBar(tabBarItem: tabBarItem, didSelectTabAtIndex: initialTabItemIndex, viewController: viewControllers[initialTabItemIndex])
    }

    private func deselectItem(at currentIndex: Int, selectedIndex: Int, popToRoot: Bool = false, senderType: TabBarItem.PresentationContext) {
        if popToRoot {
            if let navigationController = viewControllers[selectedIndex] as? UINavigationController {
                navigator.popToRoot(navigationController: navigationController)
            }
        }
        let deselectedTabItem = tabItems[currentIndex]
        deselectedTabItem.setSelected(false)
        if senderType == .current {
            delegate?.tabBar(tabBarItem: deselectedTabItem, didDeselectTabAtIndex: currentIndex, viewController: viewControllers[currentIndex])
        }
    }
}

// MARK: - TabBarDelegate

protocol TabBarDelegate: AnyObject {
    func tabBar(tabBarItem: TabBarItem, didDeselectTabAtIndex: Int, viewController: UIViewController)

    func tabBar(tabBarItem: TabBarItem, didSelectTabAtIndex: Int, viewController: UIViewController)

    // MARK: optional functions

    func shouldReplaceSelection(at index: Int, tabBarItem: TabBarItem) -> Bool

    func replaceSelection(at index: Int, viewController: UIViewController)
}

extension TabBarDelegate {
    func shouldReplaceSelection(at _: Int, tabBarItem _: TabBarItem) -> Bool { false }

    func replaceSelection(at _: Int, viewController _: UIViewController) {}
}
