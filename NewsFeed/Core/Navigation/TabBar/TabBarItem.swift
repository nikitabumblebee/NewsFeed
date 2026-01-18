//
//  TabBarItem.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import UIKit

// MARK: - TabBarItem

class TabBarItem: UIButton {
    enum PresentationContext {
        case current
        case overCurrent
    }

    var type: TabBarItemType = .init(index: -1, name: "Unknown")
    var presentationContext: PresentationContext = .current

    func setSelected(_: Bool) {}
}

// MARK: - ImageTabBarItem

class ImageTabBarItem: TabBarItem {
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var bottomTitleLabel: UILabel!

    override nonisolated func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated {
            backgroundColor = .clear
            iconImageView.tintColor = unselectedTintColor
            bottomTitleLabel.textColor = unselectedTintColor
        }
    }

    var iconName: String = "" {
        didSet {
            iconImageView.image = UIImage(systemName: iconName)
        }
    }

    var title: String = "" {
        didSet {
            bottomTitleLabel.text = title
        }
    }

    var selectedTintColor: UIColor = .accent
    var unselectedTintColor: UIColor = .gray4

    override func setSelected(_ selected: Bool) {
        iconImageView.tintColor = selected ? selectedTintColor : unselectedTintColor
        bottomTitleLabel.textColor = selected ? selectedTintColor : unselectedTintColor
    }
}
