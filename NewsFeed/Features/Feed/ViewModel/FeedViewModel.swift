//
//  FeedViewModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import Foundation

final class FeedViewModel: ObservableObject {
    private let newsStorage: NewsStorage
    private var news = [any NewsProtocol]()
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var newsModels: [any NewsProtocol] = [
        BaseNews(id: "123", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "234", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "345", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "456", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "567", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "678", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "789", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "890", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "901", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "012", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
    ]

    private(set) var contentLoadState: ContentLoadState = .loading

    init(newsStorage: NewsStorage) {
        self.newsStorage = newsStorage
        subscribeToNews()
    }

    func changeViewState(to newState: ContentLoadState) {
        contentLoadState = newState
        switch newState {
        case .loaded, .noData:
            clearModels()
        case .loading:
            break
        }
    }

    func clearModels() {
        news.removeAll()
    }

    func buildViewModels(from newNews: [any NewsProtocol]) {
        guard contentLoadState != .loading else { return }
        news.append(contentsOf: newNews.compactMap { $0 as? BaseNews })
        newsModels = newNews
    }

    private func subscribeToNews() {
        newsStorage.currentNewsPublisher
            .sink { [weak self] news in
                guard let self, let news else { return }
                changeViewState(to: news.isEmpty ? .noData : .loaded)
                newsModels = news
            }
            .store(in: &cancellables)
    }
}
