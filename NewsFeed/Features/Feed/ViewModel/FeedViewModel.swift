//
//  FeedViewModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import Foundation

final class FeedViewModel: ObservableObject {
    private let feedParserService: FeedParserService
    private var news = [News]()
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var newsModels: [News] = [
        News(id: "123", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        News(id: "234", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        News(id: "345", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        News(id: "456", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        News(id: "567", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        News(id: "678", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        News(id: "789", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        News(id: "890", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        News(id: "901", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
        News(id: "012", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", resource: nil, isViewed: false),
    ]

    private(set) var contentLoadState: ContentLoadState = .loading

    init(feedParserService: FeedParserService) {
        self.feedParserService = feedParserService
        subscribeToParser()
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

    func buildViewModels(from newNews: [News]) {
        guard contentLoadState != .loading else { return }
        news.append(contentsOf: newNews)
        newsModels = newNews
    }

    private func subscribeToParser() {
        feedParserService.currentNewsPublisher
            .sink { [weak self] news in
                guard let self, let news else { return }
                changeViewState(to: news.isEmpty ? .noData : .loaded)
                newsModels = news
            }
            .store(in: &cancellables)
    }
}
