//
//  Collection+Extension.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : .none
    }
}
