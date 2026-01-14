//
//  NavigationBarAppearance.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation
import UIKit

struct NavigationBarAppearance {
    enum Style {
        case opaque
        case transparent
        case dark
    }

    let standard: UINavigationBarAppearance
    let scroll: UINavigationBarAppearance
    let compact: UINavigationBarAppearance
    let tintColor: UIColor?

    static func create(for style: Style) -> NavigationBarAppearance {
        switch style {
        case .opaque:
            createOpaqueStyle()
        case .transparent:
            createTransparentStyle()
        case .dark:
            createDarkStyle()
        }
    }

    private static func createOpaqueStyle() -> NavigationBarAppearance {
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.textPrimary]

        let doneButtonAppearance = UIBarButtonItemAppearance()
        doneButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.accent]

        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = .backgroundPrimary
        standardAppearance.titleTextAttributes = getTextAttributes(titleBarColor: UIColor.textPrimary)
        standardAppearance.buttonAppearance = buttonAppearance
        standardAppearance.doneButtonAppearance = doneButtonAppearance
        standardAppearance.shadowColor = .clear

        return NavigationBarAppearance(standard: standardAppearance, scroll: standardAppearance.copy(), compact: standardAppearance.copy(), tintColor: .gray2)
    }

    private static func createTransparentStyle() -> NavigationBarAppearance {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.titleTextAttributes = getTextAttributes(titleBarColor: UIColor.textPrimary)
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundColor = .clear

        return NavigationBarAppearance(standard: navigationBarAppearance, scroll: navigationBarAppearance.copy(), compact: navigationBarAppearance.copy(), tintColor: .white)
    }

    private static func createDarkStyle() -> NavigationBarAppearance {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .gray6
        navigationBarAppearance.titleTextAttributes = getTextAttributes(titleBarColor: UIColor.textPrimary)
        navigationBarAppearance.shadowColor = .clear

        return NavigationBarAppearance(
            standard: navigationBarAppearance,
            scroll: navigationBarAppearance.copy(),
            compact: navigationBarAppearance.copy(),
            tintColor: .gray2
        )
    }

    /// Gets text attributes
    private static func getTextAttributes(titleBarColor: UIColor) -> [NSAttributedString.Key: Any] {
        [
            .foregroundColor: titleBarColor,
            .font: UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        ]
    }
}
