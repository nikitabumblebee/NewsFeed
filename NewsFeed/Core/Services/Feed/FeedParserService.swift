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
    static let shared = FeedParserService()

    private let dataBase: any DatabaseRepository
    private var cancellables: Set<AnyCancellable> = []
    private var news: [News] = []
    private let initialNewsLoadedSubject: CurrentValueSubject<Bool, Never> = .init(false)
    var initialNewsLoaded: AnyPublisher<Bool, Never> {
        initialNewsLoadedSubject.eraseToAnyPublisher()
    }

    private init() {
        dataBase = RealmDatabaseRepository.shared
        loadNewsFromDifferentSources()
    }

    private func loadNewsFromDifferentSources() {
        Task {
            let news = await withTaskGroup(of: [News].self, returning: [News].self) { [weak self] group in
                guard let self else { return [] }
                for item in NewsSources.allCases {
                    group.addTask {
                        let news = await self.parceFeed(from: item.rawValue)
                        return news
                    }
                }
                var newsList: [News] = []
                for await news in group {
                    newsList.append(contentsOf: news)
                }
                return newsList
            }.sorted(by: { $0.date > $1.date })
            print("🔥 \(news.count)")
            self.news.append(contentsOf: news)
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            initialNewsLoadedSubject.send(true)
        }
    }

    private nonisolated func parceFeed(from urlString: String) async -> [News] {
        guard let url = URL(string: urlString) else { return [] }
        do {
            var news: [News] = []
            let feed = try await Feed(url: url)
            switch feed {
            case let .atom(feed):
                break
            case let .rss(feed):
                feed.channel?.items?.forEach { item in
                    if let link = item.link, let date = item.pubDate {
                        let rssNews = News(
                            id: link,
                            title: item.title ?? "",
                            description: item.description ?? "",
                            link: URL(string: link),
                            image: item.enclosure?.attributes?.url,
                            date: date,
                            source: item.author,
                            isViewed: false
                        )
//                        print("🟢 \(rssNews.id); \(rssNews.title)")
                        // TODO: Add DB synchronization
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

    func fetchFeed(fromBeginning _: Bool, limit _: Int) -> AnyPublisher<[News], Never> {
        Future<[News], Never> { [weak self] promise in
            guard let self else {
                promise(.success([]))
                return
            }
            promise(.success(news))
        }
        .eraseToAnyPublisher()
    }
}
