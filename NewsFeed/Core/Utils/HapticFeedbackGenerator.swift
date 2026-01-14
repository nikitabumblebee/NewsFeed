//
//  HapticFeedbackGenerator.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

class HapticFeedbackGenerator {
    static func playResultFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    static func playSelectionFeedback() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func playImpactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .soft:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.9)
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        default:
            break
        }
    }
}
