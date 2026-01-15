//
//  News.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation

nonisolated struct News: Hashable {
    let id: String
    let title: String
    let description: String
    let link: URL?
    let image: String?
    let date: Date
    let source: String?
    let resource: String?
    var isViewed: Bool

    @MainActor func toNewsDB() -> NewsDB {
        let newsDB = NewsDB()
        newsDB.id = id
        newsDB.title = title
        newsDB.newsDescription = description
        newsDB.linkString = link?.absoluteString
        newsDB.image = image
        newsDB.date = date
        newsDB.source = source
        newsDB.resource = resource
        newsDB.isViewed = isViewed
        return newsDB
    }
}
