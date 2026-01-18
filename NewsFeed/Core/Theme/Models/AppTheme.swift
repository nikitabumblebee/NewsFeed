//
//  AppTheme.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 16.01.2026.
//

import Foundation
import UIKit

enum AppTheme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var title: String {
        switch self {
        case .light: "Светлая"
        case .dark: "Темная"
        case .system: "Системная"
        }
    }

    var uiInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: .light
        case .dark: .dark
        case .system: .unspecified
        }
    }

    init?(uiInterfaceStyle: UIUserInterfaceStyle) {
        switch uiInterfaceStyle {
        case .light: self = .light
        case .dark: self = .dark
        case .unspecified: self = .system
        @unknown default: self = .system
        }
    }
}
