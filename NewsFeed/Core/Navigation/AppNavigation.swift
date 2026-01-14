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

//    func presentUserCheckScreen() {
//        let viewController = UserCheckViewController(viewModel: UserCheckDefaultViewModel())
//        viewController.navigator = self
//        setRootViewController(viewController, animated: false)
//    }

//    func presentScreen(
//        for profile: Profile?,
//        presentCousellor: Bool = false
//    ) {
//        guard let profile,
//              profile.nickname != nil
//        else {
//            setScene(.onboarding(fullOnboarding: !UserDefaults.standard.hasSeenOnboarding)) {
//                UniversalLinks.shared.handleExistingLink(isColdStart: true)
//            }
//            return
//        }
//
//        let registrationConfig = StaticRepository.shared.data.registrationConfig
//        let scene: Scene
//
//        var steps = [RegistrationFlowItem]()
//        if registrationConfig?.goals == true, profile.goals?.isEmpty == true {
//            steps.append(.goals)
//        }
//        if registrationConfig?.schedule == true, profile.aiCounselorSchedule?.isEmpty == true {
//            steps.append(.schedule)
//        }
//        if User.me.hasSeenCongratulationsScreen == false {
//            steps.append(.congratulation)
//        }
//
//        if !steps.isEmpty {
//            scene = .registration(type: nil, steps: steps)
//        } else {
//            scene = presentCousellor ? .counsellor : .main
//        }
//        setScene(scene) {
//            UniversalLinks.shared.handleExistingLink(isColdStart: true)
//        }
//    }

//    func setScene(_ scene: Scene, completionHandler: (() -> Void)? = nil) {
//        setRootViewController(scene.controller) {
//            completionHandler?()
//        }
//    }

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
