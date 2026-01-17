//
//  BaseNews.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 16.01.2026.
//

import Foundation

final nonisolated class BaseNews: NewsProtocol, Hashable {
    let id: String
    let title: String
    let description: String
    let link: URL?
    let image: String?
    let date: Date
    let author: String?
    let resource: String?
    var isViewed: Bool

    init(
        id: String,
        title: String,
        description: String,
        link: URL?,
        image: String?,
        date: Date,
        author: String?,
        resource: String?,
        isViewed: Bool
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.link = link
        self.image = image
        self.date = date
        self.author = author
        self.resource = resource
        self.isViewed = isViewed
    }

    func toNewsDB() -> NewsDB {
        let newsDB = NewsDB()
        newsDB.id = id
        newsDB.title = title
        newsDB.newsDescription = description
        newsDB.linkString = link?.absoluteString
        newsDB.image = image
        newsDB.date = date
        newsDB.author = author
        newsDB.resource = resource
        newsDB.isViewed = isViewed
        return newsDB
    }

    static func == (lhs: BaseNews, rhs: BaseNews) -> Bool {
        lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.description == rhs.description &&
            lhs.link == rhs.link &&
            lhs.image == rhs.image &&
            lhs.date == rhs.date &&
            lhs.author == rhs.author &&
            lhs.resource == rhs.resource
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
