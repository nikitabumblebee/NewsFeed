//
//  AppNavigation.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation
import UIKit

final class AppNavigation {
    private unowned let sceneDelegate: SceneDelegate

    init(_ sceneDelegate: SceneDelegate) {
        self.sceneDelegate = sceneDelegate
    }

    func setRootViewController(
        _ viewController: UIViewController,
        animated: Bool = true,
        completionHandler: (() -> Void)? = nil
    ) {
        guard let window = sceneDelegate.window else {
            return
        }
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        guard animated else {
            completionHandler?()
            return
        }
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: { _ in
                completionHandler?()
            }
        )
    }
}
