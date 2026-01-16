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
    private var refreshTimer: Timer?

    private let initialNewsLoadedSubject = CurrentValueSubject<Bool, Never>(false)
    var initialNewsLoadedPublisher: AnyPublisher<Bool, Never> {
        initialNewsLoadedSubject.eraseToAnyPublisher()
    }

    private let hideRefresherSubject = PassthroughSubject<Void, Never>()
    var hideRefresherPublisher: AnyPublisher<Void, Never> {
        hideRefresherSubject.eraseToAnyPublisher()
    }

    private let refreshTimerSignalSubject = PassthroughSubject<Void, Never>()
    var refreshTimerSignalPublisher: AnyPublisher<Void, Never> {
        refreshTimerSignalSubject.eraseToAnyPublisher()
    }

    init(newsStorage: NewsStorage) {
        self.newsStorage = newsStorage
        subscribeToNews()
    }

    func clearModels() {
        newsModels.removeAll()
    }

    func buildViewModels(from newNews: [any NewsProtocol]) {
        guard contentLoadState != .loading else { return }
        newsModels.append(contentsOf: newNews)
    }

    func parseNewNews() {
        handleRefreshTimer()
        Task {
            await FeedParserService.shared.parseNewNews()
        }
    }

    private func subscribeToNews() {
        newsStorage.initialNewsLoadedPublisher
            .removeDuplicates()
            .sink { [weak self] in
                guard let self, $0 else { return }
                handleRefreshTimer()
                changeViewState(to: newsStorage.news.isEmpty ? .noData : .loaded)
                initialNewsLoadedSubject.send($0)
            }
            .store(in: &cancellables)

        newsStorage.currentNewsPublisher
            .sink { [weak self] news in
                guard let self, let news else { return }
                changeViewState(to: news.isEmpty ? .noData : .loaded)
                newsModels = news
            }
            .store(in: &cancellables)

        newsStorage.updateNewsPublisher
            .sink { [weak self] updatedNews in
                guard let self, let changedNewsIndex = newsModels.firstIndex(where: { $0.id == updatedNews.id }) else { return }
                newsModels[changedNewsIndex] = updatedNews
            }
            .store(in: &cancellables)

        newsStorage.uploadNewNewsPublisher
            .sink { [weak self] uploadedNews in
                guard let self, !uploadedNews.isEmpty else {
                    self?.hideRefresherSubject.send(())
                    return
                }
                newsModels.insert(contentsOf: uploadedNews, at: 0)
                hideRefresherSubject.send(())
            }
            .store(in: &cancellables)
    }

    private func changeViewState(to newState: ContentLoadState) {
        contentLoadState = newState
    }

    func handleRefreshTimer() {
        refreshTimer?.invalidate()
        let refreshNewsTimerDuration = UserDefaults.standard.refreshNewsTimerDuration == 0
            ? AppConstants.defaultTimerDuration
            : UserDefaults.standard.refreshNewsTimerDuration
        refreshTimer = Timer.scheduledTimer(withTimeInterval: Double(refreshNewsTimerDuration * 60), repeats: true, block: { [weak self] _ in
            guard let self else { return }
            Task {
                await MainActor.run {
                    self.refreshTimerSignalSubject.send(())
                }
            }
        })
    }
}
