//
//  NewsResource.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 16.01.2026.
//

import Foundation

nonisolated struct NewsResource: Hashable, Sendable, Codable {
    let name: String
    let url: String
    private(set) var show: Bool

    mutating func enableSource() {
        show = true
    }

    mutating func disableSource() {
        show = false
    }
}
