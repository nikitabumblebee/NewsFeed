//
//  FeedParserService.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation
import Combine
import FeedKit
internal import XMLKit

class FeedParserService {
    static let shared = FeedParserService()
    
    private var cancellables: Set<AnyCancellable> = []
    private var news: [News] = []
    private let initialNewsLoadedSubject: CurrentValueSubject<Bool, Never> = .init(false)
    var initialNewsLoaded: AnyPublisher<Bool, Never> {
        initialNewsLoadedSubject.eraseToAnyPublisher()
    }
    
    private init() {
        Task {
            let vedomostiUrl = "https://www.vedomosti.ru/rss/news.xml"
            async let newsVedomosti = parceFeed(from: vedomostiUrl)
//            self.news.append(contentsOf: newsVedomosti)
            let rbcUrl = "https://rssexport.rbc.ru/rbcnews/news/30/full.rss"
            async let newsRbc = await parceFeed(from: rbcUrl)
//            self.news.append(contentsOf: newsRbc)
            let news = await (newsRbc + newsVedomosti)
            self.news.append(contentsOf: news)
            initialNewsLoadedSubject.send(true)
        }
    }

    func parceFeed(from urlString: String) async -> [News] {
        guard let url = URL(string: urlString) else { return [] }
        do {
            var news: [News] = []
            let feed = try await Feed(url: url)
            switch feed {
            case let .atom(feed):
                let a = feed
            case let .rss(feed):
//                let a = try feed.toXMLString(formatted: true)
                feed.channel?.items?.forEach({ item in
                    if let link = item.link, let date = item.pubDate {
                        let rssNews = News(
//                            id: UUID(),
                            title: item.title ?? "",
                            description: item.description ?? "",
                            link: URL(string: link),
                            image: item.enclosure?.attributes?.url,
                            date: date,
                            source: item.author,
                            isViewed: false
                        )
                        news.append(rssNews)
                    }
                })
            case let .json(feed):
                let a = try feed.toJSONString(formatted: true)
            }
            print("🔥 \(news.count)")
            return news
        } catch {
            print("Error")
            return []
        }
    }
    
    func fetchFeed(fromBeginning: Bool, limit: Int) -> AnyPublisher<[News], Never> {
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
