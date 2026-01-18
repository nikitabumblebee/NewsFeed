//
//  Navigator.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import Foundation
import UIKit

// MARK: - Navigator

final class Navigator: NSObject {
    override private init() {}

    static let shared = Navigator()

    var navigationController: UINavigationController? {
        UIApplication.shared.windows.filter(\.isKeyWindow).first?.rootViewController as? UINavigationController
    }

    var topViewController: UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter(\.isKeyWindow).first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }

    var tabBarController: (any BaseTabBar)? {
        let keyWindow = UIApplication.shared.windows.filter(\.isKeyWindow).first
        guard var topController = keyWindow?.rootViewController else { return nil }
        if let navigation = topController as? UINavigationController, let tabBarController = navigation.viewControllers.first as? (any BaseTabBar) {
            return tabBarController
        }
        if let tabBarController = topController as? (any BaseTabBar) {
            return tabBarController
        }
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
            if let tabBarController = topController as? (any BaseTabBar) {
                return tabBarController
            }
        }
        return nil
    }

    var topNavigationController: UINavigationController? {
        let viewController = topViewController
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        } else if let tabBarController = viewController as? (any BaseTabBar) {
            return tabBarController.getCurrentViewController()
        }
        return viewController?.navigationController
    }
}

// MARK: - MVC navigation

extension Navigator {
    /// если передаем navigationController пустым, то открывается от основного контроллера без таб бара
    func push(
        viewController: UIViewController,
        navigationController: UINavigationController? = nil,
        animated: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        let navigationController = navigationController ?? self.navigationController
        navigationController?.pushViewController(viewController: viewController, animated: animated, completion: completion)
    }

    func present(
        viewController: UIViewController,
        presentingViewController: UIViewController? = nil,
        modalPresentationStyle: UIModalPresentationStyle = .automatic,
        modalTransitionStyle: UIModalTransitionStyle = .coverVertical,
        animated: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        viewController.modalPresentationStyle = modalPresentationStyle
        viewController.modalTransitionStyle = modalTransitionStyle

        let presenterVC = presentingViewController ?? navigationController

        presenterVC?.present(viewController, animated: animated, completion: completion)
    }

    func popViewController(navigationController: UINavigationController? = nil, animated: Bool = true, completion: @escaping () -> Void = {}) {
        let navigationController = navigationController ?? self.navigationController
        navigationController?.popViewController(animated: animated, completion: completion)
    }

    func popToRoot(navigationController: UINavigationController? = nil, animated: Bool = true) {
        let navigationController = navigationController ?? self.navigationController
        navigationController?.popToRootViewController(animated: animated)
    }

    func popToViewController(
        _ viewController: UIViewController,
        navigationController: UINavigationController? = nil,
        animated: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        let navigationController = navigationController ?? self.navigationController
        navigationController?.popToViewController(viewController, animated: animated, completion: completion)
    }

    func back(navigationController: UINavigationController? = nil, animated: Bool = true) {
        let navigationController = navigationController ?? self.navigationController
        navigationController?.popViewController(animated: animated)
    }

    func dismiss(presentingBy viewController: UIViewController?, animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController?.dismiss(animated: animated, completion: completion)
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        dismiss(presentingBy: navigationController, animated: animated, completion: completion)
    }
}
