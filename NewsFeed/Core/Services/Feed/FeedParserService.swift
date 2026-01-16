//
//  FeedParserService.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import FeedKit
import Foundation
internal import XMLKit

class FeedParserService {
    private enum NewsKeys {
        case title(String)
        case description(String)
        case link(String?)
        case image(String?)
        case date(Date)
        case source(String?)
        case resource(String?)
    }

    static let shared = FeedParserService()

    private let dataBase: any DatabaseRepository
    private let newsStorage = NewsStorage.shared
    private var cancellables: Set<AnyCancellable> = []

    private init() {
        dataBase = NewsDatabaseService.shared
        loadNewsFromDifferentSources()
    }

    private func loadNewsFromDifferentSources() {
        Task {
            let news = await withTaskGroup(of: [any NewsProtocol].self, returning: [any NewsProtocol].self) { [weak self] group in
                guard let self else { return [] }
                for item in NewsSources.allCases {
                    group.addTask {
                        let news = await self.parceFeed(from: item.rawValue)
                        return news
                    }
                }
                var newsList: [any NewsProtocol] = []
                for await news in group {
                    newsList.append(contentsOf: news)
                }
                return newsList
            }.sorted(by: { $0.date > $1.date })
            print("🔥 \(news.count)")
            var loadedNews: [any NewsProtocol] = []
            for item in news {
                if let realmDataBase = dataBase as? NewsDatabaseService {
                    if let existingItem = try? realmDataBase.get(by: item.id) {
                        var updatedItem: any NewsProtocol = item
                        if existingItem.isViewed {
                            updatedItem.isViewed = true
                        }
                        print("✅ \(existingItem.id); \(existingItem.isViewed)")
                        loadedNews.append(item)
                        updateDabaseObjectIfNeeded(for: existingItem, with: item)
                    } else {
                        print("🥶")
                        loadedNews.append(item)
                        let newsToSafe = item.toNewsDB()
                        try? await realmDataBase.save(newsToSafe)
                    }
                }
            }
            newsStorage.addNews(loadedNews)
        }
    }

    private func parceFeed(from urlString: String) async -> [any NewsProtocol] {
        guard let url = URL(string: urlString) else { return [] }
        do {
            var news: [any NewsProtocol] = []
            let feed = try await Feed(url: url)
            switch feed {
            case let .atom(feed):
                break
            case let .rss(feed):
                feed.channel?.items?.forEach { item in
                    if let link = item.link, let date = item.pubDate {
                        let rssNews = BaseNews(
                            id: link,
                            title: item.title ?? "",
                            description: item.description ?? "",
                            link: URL(string: link),
                            image: item.enclosure?.attributes?.url,
                            date: date,
                            source: item.author,
                            resource: urlString,
                            isViewed: false
                        )
                        news.append(rssNews)
                    }
                }
            case let .json(feed):
                break
            }
            return news
        } catch {
            print("Error")
            return []
        }
    }

    private func updateDabaseObjectIfNeeded(for existedObject: NewsDB, with newObject: any NewsProtocol) {
        guard let realmDataBase = dataBase as? NewsDatabaseService else { return }
        var updateParameters: [NewsKeys] = []
        if existedObject.title != newObject.title {
            updateParameters.append(.title(newObject.title))
        }
        if existedObject.newsDescription != newObject.description {
            updateParameters.append(.description(newObject.description))
        }
        if existedObject.linkString != newObject.link?.absoluteString {
            updateParameters.append(.link(newObject.link?.absoluteString))
        }
        if existedObject.image != newObject.image {
            updateParameters.append(.image(newObject.image))
        }
        if existedObject.date != newObject.date {
            updateParameters.append(.date(newObject.date))
        }
        if existedObject.source != newObject.source {
            updateParameters.append(.source(newObject.source))
        }
        if existedObject.resource != newObject.resource {
            updateParameters.append(.resource(newObject.resource))
        }
        guard !updateParameters.isEmpty else { return }
        print("🧠 \(existedObject.id); \(updateParameters)")
        try? realmDataBase.update(by: existedObject.id) { newsDB in
            for parameter in updateParameters {
                switch parameter {
                case let .title(title):
                    newsDB.title = title
                case let .description(description):
                    newsDB.newsDescription = description
                case let .link(link):
                    newsDB.linkString = link
                case let .image(image):
                    newsDB.image = image
                case let .date(date):
                    newsDB.date = date
                case let .source(source):
                    newsDB.source = source
                case let .resource(resource):
                    newsDB.resource = resource
                }
            }
        }
    }
}
