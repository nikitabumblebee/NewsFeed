//
//  BaseNavigationViewController.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

final class BaseNavigationViewController: UINavigationController {
    var currentStyle: NavigationBarAppearance.Style?

    convenience init(rootViewController: UIViewController, hideNavigationBar: Bool = false, currentStyle: NavigationBarAppearance.Style? = nil) {
        self.init(rootViewController: rootViewController)
        self.currentStyle = currentStyle
        setNavigationBarHidden(hideNavigationBar, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarAppearance(for: currentStyle ?? .opaque)
        delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarAppearance(for: currentStyle ?? .opaque)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: UINavigationControllerDelegate

extension BaseNavigationViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let viewControllersCountGreaterThanOne = viewControllers.count > 1
        navigationController.interactivePopGestureRecognizer?.delegate = viewControllersCountGreaterThanOne ? self : nil
        navigationController.interactivePopGestureRecognizer?.isEnabled = viewControllersCountGreaterThanOne
    }
}

// MARK: UIGestureRecognizerDelegate

extension BaseNavigationViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard presentedViewController == nil else { return false }
        return viewControllers.count > 1
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        (visibleViewController as? BaseNavigationPopGestureDelegate)?.shouldRecognizeSimultaneously(gestureRecognizer, with: otherGestureRecognizer) ?? true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        (visibleViewController as? BaseNavigationPopGestureDelegate)?.shouldRequireFailure(gestureRecognizer, of: otherGestureRecognizer) ?? false
    }
}

// MARK: - BaseNavigationPopGestureDelegate

protocol BaseNavigationPopGestureDelegate {
    func shouldRecognizeSimultaneously(_ gestureRecognizer: UIGestureRecognizer, with otherGestureRecognizer: UIGestureRecognizer) -> Bool

    func shouldRequireFailure(_ gestureRecognizer: UIGestureRecognizer, of otherGestureRecognizer: UIGestureRecognizer) -> Bool
}
