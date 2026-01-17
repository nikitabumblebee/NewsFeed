//
//  ThemeManager.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 17.01.2026.
//

import Foundation
import UIKit

final class ThemeManager {
    static let shared = ThemeManager()

    private init() {
        applyTheme(UserDefaults.standard.currentTheme)
    }

    func applyTheme(_ theme: AppTheme) {
        UserDefaults.standard.currentTheme = theme

        UIView.animate(withDuration: 0.3) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first
            {
                window.overrideUserInterfaceStyle = theme.uiInterfaceStyle
            }
        }
    }

    @objc private func themeChanged() {
        // Auto-update если system
        if UserDefaults.standard.currentTheme == .system {
            applyTheme(.system)
        }
    }
}

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}
