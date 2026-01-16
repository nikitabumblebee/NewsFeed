//
//  SettingsViewModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import Foundation

final class SettingsViewModel {
    private enum Constants {
        static let defaultTimerDuration: Int = 300
    }

    private var reloadTimerDuration: Int = Constants.defaultTimerDuration
    private(set) var selectedSource: NewsSource?

    private var model: SettingsModel
    private let imageCache: ImageCache

    private let sourcesListSubject = CurrentValueSubject<[NewsSource], Never>([])
    var sourcesListPublisher: AnyPublisher<[NewsSource], Never> {
        sourcesListSubject.eraseToAnyPublisher()
    }

    private let cacheResetSuccessSubject = PassthroughSubject<Void, Never>()
    var cacheResetSuccessPublisher: AnyPublisher<Void, Never> {
        cacheResetSuccessSubject.eraseToAnyPublisher()
    }

    private(set) var sources: [NewsSource] = []

    init(imageCache: ImageCache) {
        model = SettingsModel(
            sources: [
                NewsSource(name: "Rbc", url: "https://rssexport.rbc.ru/rbcnews/news/30/full.rss", show: true),
                NewsSource(name: "Vedomosti", url: "https://www.vedomosti.ru/rss/news.xml", show: true),
            ],
            appTheme: .system,
            refreshInterval: Constants.defaultTimerDuration
        )
        self.imageCache = imageCache
        sources = model.sources
        sourcesListSubject.send(model.sources)
    }

    func resetImagesCache() {
        imageCache.clearCache()
        cacheResetSuccessSubject.send(())
    }

    func addSource(_ source: NewsSource) {
        model.addSource(source)
        sources = model.sources
        sourcesListSubject.send(model.sources)
    }

    func deleteSource(_ source: NewsSource) {
        model.deleteSource(source)
        sources = model.sources
        sourcesListSubject.send(model.sources)
    }

    func disableSource(_ source: NewsSource) {
        model.disableSource(source)
    }

    func enableSource(_ source: NewsSource) {
        model.enableSource(source)
    }

    func changeRefreshTimerDuration(_ duration: Int) {
        model.refreshInterval = duration
    }

    func selectSource(_ source: NewsSource?) {
        selectedSource = source
    }

    func deselectSource() {
        selectedSource = nil
    }
}
