//
//  FeedModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 17.01.2026.
//

import Foundation

struct FeedModel {
    private(set) var news: [any NewsProtocol]
    private(set) var refreshNewsTimerDuration: Int

    mutating func addNews(_ news: [any NewsProtocol]) -> [any NewsProtocol] {
        self.news.append(contentsOf: news)
        return self.news
    }

    mutating func clearNews() -> [any NewsProtocol] {
        news.removeAll()
        return news
    }

    mutating func changeNews(_ news: any NewsProtocol, at index: Int) -> [any NewsProtocol] {
        self.news[index] = news
        return self.news
    }

    mutating func insertNews(_ news: [any NewsProtocol], at index: Int) -> [any NewsProtocol] {
        self.news.insert(contentsOf: news, at: index)
        return self.news
    }

    mutating func changeRefreshNewsTimerDuration(_ duration: Int) {
        refreshNewsTimerDuration = duration
    }
}
