//
//  UINavigationItem+Extension.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

extension UINavigationItem {
    func setAppearance(for style: NavigationBarAppearance.Style) {
        let appearance = NavigationBarAppearance.create(for: style)
        standardAppearance = appearance.standard
        scrollEdgeAppearance = appearance.scroll
        compactAppearance = appearance.compact
        titleView?.tintColor = appearance.tintColor
        leftBarButtonItem?.tintColor = appearance.tintColor
        rightBarButtonItem?.tintColor = appearance.tintColor
    }
}
