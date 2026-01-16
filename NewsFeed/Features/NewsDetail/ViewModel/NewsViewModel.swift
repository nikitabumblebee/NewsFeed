//
//  NewsViewModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation

class NewsViewModel: Sendable {
    private let databaseService = NewsDatabaseService.shared
    private let newsStorage = NewsStorage.shared
    let news: NewsProtocol

    init(news: NewsProtocol) {
        self.news = news
    }

    func setNewsAsViewedIfNeeded() {
        try? databaseService.update(by: news.id, updateBlock: { newsDB in
            newsDB.isViewed = true
        })
        newsStorage.markNewsAsRead(news)
    }
}

extension NewsViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(news.id)
    }

    static func == (lhs: NewsViewModel, rhs: NewsViewModel) -> Bool {
        lhs.news.id == rhs.news.id
    }
}
