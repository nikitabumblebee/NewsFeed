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
    private let feedParser: FeedParserService
    private var model: FeedModel
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var newsModels: [any NewsProtocol] = []

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

    private let applyNewsFilterSubject = PassthroughSubject<Void, Never>()
    var applyNewsFilterPublisher: AnyPublisher<Void, Never> {
        applyNewsFilterSubject.eraseToAnyPublisher()
    }

    private let reloadCurrentNewsSubject = PassthroughSubject<Void, Never>()
    var reloadCurrentNewsPublisher: AnyPublisher<Void, Never> {
        reloadCurrentNewsSubject.eraseToAnyPublisher()
    }

    init(newsStorage: NewsStorage, feedParser: FeedParserService) {
        if UserDefaults.standard.refreshNewsTimerDuration == 0 {
            UserDefaults.standard.refreshNewsTimerDuration = FeedConstants.defaultTimerDuration
        }
        let refreshNewsTimerDuration = UserDefaults.standard.refreshNewsTimerDuration
        model = .init(news: FeedConstants.initialNewsForLoad, refreshNewsTimerDuration: refreshNewsTimerDuration * 60)
        self.newsStorage = newsStorage
        self.feedParser = feedParser
        newsModels = model.news
        subscribeToNews()
    }

    func clearModels() {
        model.clearNews()
    }

    func buildViewModels(from newNews: [any NewsProtocol]) {
        guard contentLoadState != .loading else { return }
        newsModels = model.addNews(newNews)
    }

    func parseNewNews() {
        handleRefreshTimer()
        Task {
            await feedParser.parseNewNews()
        }
    }

    private func subscribeToNews() {
        newsStorage.initialNewsLoadedPublisher
            .removeDuplicates()
            .sink { [weak self] in
                guard let self, $0 else { return }
                handleRefreshTimer()
                changeViewState(to: newsStorage.filteredNews.isEmpty ? .noData : .loaded)
                initialNewsLoadedSubject.send($0)
            }
            .store(in: &cancellables)

        newsStorage.updateNewsPublisher
            .sink { [weak self] updatedNews in
                guard let self, let changedNewsIndex = newsModels.firstIndex(where: { $0.id == updatedNews.id }) else { return }
                newsModels = model.changeNews(updatedNews, at: Int(changedNewsIndex))
            }
            .store(in: &cancellables)

        newsStorage.uploadNewNewsPublisher
            .sink { [weak self] uploadedNews in
                guard let self, !uploadedNews.isEmpty else {
                    self?.hideRefresherSubject.send()
                    return
                }
                newsModels = model.insertNews(uploadedNews, at: 0)
                hideRefresherSubject.send()
            }
            .store(in: &cancellables)

        newsStorage.applyFilteredNewsPublisher
            .sink { [weak self] in
                guard let self else { return }
                applyNewsFilterSubject.send()
            }
            .store(in: &cancellables)

        newsStorage.reloadCurrentNewsPublisher
            .sink { [weak self] in
                guard let self else { return }
                reloadCurrentNewsSubject.send()
            }
            .store(in: &cancellables)
    }

    private func changeViewState(to newState: ContentLoadState) {
        contentLoadState = newState
    }

    func handleRefreshTimer() {
        refreshTimer?.invalidate()
        model.changeRefreshNewsTimerDuration(UserDefaults.standard.refreshNewsTimerDuration * 60)
        refreshTimer = Timer.scheduledTimer(withTimeInterval: Double(model.refreshNewsTimerDuration), repeats: false, block: { [weak self] _ in
            guard let self else { return }
            Task {
                await MainActor.run {
                    self.refreshTimerSignalSubject.send(())
                }
            }
        })
    }
}
