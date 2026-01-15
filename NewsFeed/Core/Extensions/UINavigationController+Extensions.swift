//
//  UINavigationController+Extensions.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

extension UINavigationController {
    func pushViewController(viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        pushViewController(viewController, animated: animated)

        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }

    func popViewController(animated: Bool, completion: @escaping () -> Void) {
        popViewController(animated: animated)

        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }

    @discardableResult
    func popToViewController(
        _ viewController: UIViewController,
        animated: Bool,
        completion: @escaping () -> Void
    )
        -> [UIViewController]?
    {
        let viewController = popToViewController(viewController, animated: animated)
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
        return viewController
    }

    func setNavigationBarAppearance(for style: NavigationBarAppearance.Style) {
        let appearance = NavigationBarAppearance.create(for: style)
        navigationBar.standardAppearance = appearance.standard
        navigationBar.scrollEdgeAppearance = appearance.scroll
        navigationBar.compactAppearance = appearance.compact
        navigationBar.tintColor = appearance.tintColor
    }
}
