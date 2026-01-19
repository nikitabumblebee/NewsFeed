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
        self.dataBase = NewsDatabaseService.shared

        Task {
            await loadNewsFromDifferentSources()
        }
    }

    func parseNewNews() async {
        await loadNewsFromDifferentSources()
    }

    private func loadNewsFromDifferentSources() async {
        guard Connectivity.isConnectedToInternet else {
            newsStorage.addNews([])
            Connectivity.internetConnectionFailedSubject.send()
            return
        }
        let news = await withTaskGroup(of: [any NewsProtocol].self, returning: [any NewsProtocol].self) { [weak self] group in
            guard let self else { return [] }
            let newsResourcesFromUserDefaults: [NewsResource]? = UserDefaults.standard.newsResources
            let urls: [String] =
                if let newsResourcesFromUserDefaults {
                    newsResourcesFromUserDefaults.compactMap(\.url).isEmpty
                        ? newsStorage.allNewsResources.compactMap(\.url)
                        : newsResourcesFromUserDefaults.compactMap(\.url)
                } else {
                    newsStorage.allNewsResources.compactMap(\.url)
                }
            for item in urls {
                group.addTask {
                    let news = await self.parceFeed(from: item)
                    return news
                }
            }
            var newsList: [any NewsProtocol] = []
            for await news in group {
                newsList.append(contentsOf: news)
            }
            return newsList
        }.sorted(by: { $0.date > $1.date })
        var loadedNews: [any NewsProtocol] = []
        for item in news {
            if let realmDataBase = dataBase as? NewsDatabaseService {
                if let existingItem = try? realmDataBase.get(by: item.id) {
                    var updatedItem: any NewsProtocol = item
                    if existingItem.isViewed {
                        updatedItem.isViewed = true
                    }
                    loadedNews.append(item)
                    updateDabaseObjectIfNeeded(for: existingItem, with: item)
                } else {
                    loadedNews.append(item)
                    let newsToSafe = item.toNewsDB()
                    try? await realmDataBase.save(newsToSafe)
                }
            }
        }
        newsStorage.addNews(loadedNews)
    }

    private func parceFeed(from urlString: String) async -> [any NewsProtocol] {
        guard let url = URL(string: urlString) else { return [] }
        do {
            var news: [any NewsProtocol] = []
            let feed = try await Feed(url: url)
            switch feed {
            case .atom:
                break
            case .rss(let feed):
                feed.channel?.items?.forEach { item in
                    if let link = item.link, let date = item.pubDate {
                        let rssNews = BaseNews(
                            id: link,
                            title: item.title ?? "",
                            description: item.description ?? "",
                            link: URL(string: link),
                            image: item.enclosure?.attributes?.url,
                            date: date,
                            author: item.author ?? feed.channel?.description ?? "неизвестно",
                            resource: urlString,
                            isViewed: false
                        )
                        news.append(rssNews)
                    }
                }
            case .json:
                break
            }
            return news
        } catch {
            print("Error: \(error.localizedDescription)")
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
        if existedObject.author != newObject.author {
            updateParameters.append(.source(newObject.author))
        }
        if existedObject.resource != newObject.resource {
            updateParameters.append(.resource(newObject.resource))
        }
        guard !updateParameters.isEmpty else { return }
        try? realmDataBase.update(by: existedObject.id) { newsDB in
            for parameter in updateParameters {
                switch parameter {
                case .title(let title):
                    newsDB.title = title
                case .description(let description):
                    newsDB.newsDescription = description
                case .link(let link):
                    newsDB.linkString = link
                case .image(let image):
                    newsDB.image = image
                case .date(let date):
                    newsDB.date = date
                case .source(let source):
                    newsDB.author = source
                case .resource(let resource):
                    newsDB.resource = resource
                }
            }
        }
    }
}
