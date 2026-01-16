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
    private var firstNews: (any NewsProtocol)?
    private var lastNews: (any NewsProtocol)?

    private let currentNewsSubject = CurrentValueSubject<[any NewsProtocol]?, Never>(nil)
    var currentNewsPublisher: AnyPublisher<[any NewsProtocol]?, Never> {
        currentNewsSubject.eraseToAnyPublisher()
    }

    private let initialNewsLoadedSubject = CurrentValueSubject<Bool, Never>(false)
    var initialNewsLoadedPublisher: AnyPublisher<Bool, Never> {
        initialNewsLoadedSubject.eraseToAnyPublisher()
    }

    private let updateNewsSubject = PassthroughSubject<any NewsProtocol, Never>()
    var updateNewsPublisher: AnyPublisher<any NewsProtocol, Never> {
        updateNewsSubject.eraseToAnyPublisher()
    }

    private let uploadNewNewsSubject = PassthroughSubject<[any NewsProtocol], Never>()
    var uploadNewNewsPublisher: AnyPublisher<[any NewsProtocol], Never> {
        uploadNewNewsSubject.eraseToAnyPublisher()
    }

    private init() {
        database = NewsDatabaseService.shared
        loadSavedNews()
    }

    func addNews(_ news: [any NewsProtocol]) {
        for item in news {
            self.news.removeAll(where: { $0.id == item.id })
        }
        self.news.append(contentsOf: news)
        self.news = self.news.sorted(by: { $0.date > $1.date })
        compareFirstNewsWithArrayFirst(self.news.first)
        initialNewsLoadedSubject.send(true)
    }

    func markNewsAsRead(_ news: any NewsProtocol) {
        guard let itemIndex = self.news.firstIndex(where: { $0.id == news.id }), let database = database as? NewsDatabaseService else { return }
        try? database.update(by: news.id, updateBlock: { newsDB in
            newsDB.isViewed = true
        })
        var updatedItem = news
        updatedItem.isViewed = true
        self.news[itemIndex] = updatedItem
        updateNewsSubject.send(updatedItem)
    }

    func fetchNews(fromBeginning: Bool, limit: Int) -> AnyPublisher<[any NewsProtocol], Never> {
        Future<[any NewsProtocol], Never> { [weak self] promise in
            guard let self else {
                promise(.success([]))
                return
            }
            var loadedNews: [any NewsProtocol] = []
            if fromBeginning {
                loadedNews = Array(news.prefix(limit))
                lastNews = loadedNews.last
            } else if let lastNewsIndex = news.firstIndex(where: { $0.id == lastNews?.id }), news.count - 1 > Int(lastNewsIndex) {
                let intLastIndex = Int(lastNewsIndex) + 1
                let newsSlice: ArraySlice<any NewsProtocol> = if news.count > intLastIndex + limit {
                    news[intLastIndex ... (intLastIndex + limit)]
                } else {
                    news[intLastIndex ... news.count - 1]
                }
                loadedNews = Array(newsSlice)
                lastNews = loadedNews.last
            }
            promise(.success(loadedNews))
        }
        .eraseToAnyPublisher()
    }

    private func loadSavedNews() {
        guard let newsDatabaseService = database as? NewsDatabaseService,
              let news = try? newsDatabaseService.getAll().map({ convertFromNewsDBToFeedNews(from: $0) }).sorted(by: { $0.date > $1.date })
        else { return }
        self.news.append(contentsOf: news)
        compareFirstNewsWithArrayFirst(self.news.first)
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

    private func compareFirstNewsWithArrayFirst(_ arrayFirst: (any NewsProtocol)?) {
        if let firstNews {
            if let arrayFirst, firstNews.date < arrayFirst.date {
                if let indexForCurrentFirstNews = news.firstIndex(where: { $0.id == firstNews.id }) {
                    let newsSlice: ArraySlice<any NewsProtocol> = news[0 ... (indexForCurrentFirstNews - 1)]
                    let newsArray: [any NewsProtocol] = Array(newsSlice)
                    uploadNewNewsSubject.send(newsArray)
                }
                self.firstNews = arrayFirst
            } else {
                uploadNewNewsSubject.send([])
            }
        } else {
            firstNews = arrayFirst
        }
    }
}
