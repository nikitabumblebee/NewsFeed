//
//  News.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation

nonisolated struct News: Hashable {
//    let id: UUID
    let title: String
    let description: String
    let link: URL?
    let image: String?
    let date: Date
    let source: String?
    let isViewed: Bool
}
