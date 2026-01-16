//
//  NewsStorage.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 16.01.2026.
//

import Combine
import Foundation

final class NewsStorage {
    static let shared = NewsStorage()

    private(set) var news: [any NewsProtocol] = []
    private let database: any DatabaseRepository

    private let currentNewsSubject = CurrentValueSubject<[any NewsProtocol]?, Never>(nil)
    var currentNewsPublisher: AnyPublisher<[any NewsProtocol]?, Never> {
        currentNewsSubject.eraseToAnyPublisher()
    }

    private init() {
        database = NewsDatabaseService.shared
        loadSavedNews()
    }

    func addNews(_ news: [any NewsProtocol]) {
        for item in news {
            self.news.removeAll(where: { $0.id == item.id })
        }
        self.news.append(contentsOf: news.sorted(by: { $0.date > $1.date }))
        currentNewsSubject.send(self.news)
    }

    func markNewsAsRead(_ news: any NewsProtocol) {
        self.news = self.news.map { item in
            var updatedItem = item
            if item.id == news.id {
                updatedItem.isViewed = true
            }
            return updatedItem
        }
        currentNewsSubject.send(self.news)
    }

    func fetchNews(fromBeginning _: Bool, limit _: Int) -> AnyPublisher<[any NewsProtocol], Never> {
        Future<[any NewsProtocol], Never> { [weak self] promise in
            guard let self else {
                promise(.success([]))
                return
            }
            promise(.success(news))
        }
        .eraseToAnyPublisher()
    }

    private func loadSavedNews() {
        guard let newsDatabaseService = database as? NewsDatabaseService,
              let news = try? newsDatabaseService.getAll().map({ convertFromNewsDBToFeedNews(from: $0) }).sorted(by: { $0.date > $1.date })
        else { return }
        self.news.append(contentsOf: news)
    }

    private func convertFromNewsDBToFeedNews(from newsDB: NewsDB) -> any NewsProtocol {
        BaseNews(
            id: newsDB.id,
            title: newsDB.title,
            description: newsDB.newsDescription,
            link: newsDB.link,
            image: newsDB.image,
            date: newsDB.date,
            source: newsDB.source,
            resource: newsDB.resource,
            isViewed: newsDB.isViewed
        )
    }
}
