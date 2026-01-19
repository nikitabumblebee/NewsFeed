//
//  NewsDetailViewModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation

// MARK: - NewsDetailViewModel

class NewsDetailViewModel: Sendable {
    private let newsStorage: NewsStorage
    let news: any NewsProtocol

    init(news: any NewsProtocol, newsStorage: NewsStorage) {
        self.news = news
        self.newsStorage = newsStorage
    }

    func setNewsAsViewedIfNeeded() {
        newsStorage.markNewsAsRead(news)
    }
}

// MARK: Hashable

extension NewsDetailViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(news.id)
    }

    static func == (lhs: NewsDetailViewModel, rhs: NewsDetailViewModel) -> Bool {
        lhs.news.id == rhs.news.id
    }
}
