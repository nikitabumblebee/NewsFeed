//
//  SettingsViewModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import Foundation

final class SettingsViewModel {
    private(set) var reloadTimerDuration: Int = AppConstants.defaultTimerDuration
    private(set) var selectedSource: NewsSource?

    private var model: SettingsModel
    private let imageCache: ImageCache
    private let initialTimerValue: Int = UserDefaults.standard.refreshNewsTimerDuration == 0
        ? AppConstants.defaultTimerDuration
        : UserDefaults.standard.refreshNewsTimerDuration

    private let sourcesListSubject = CurrentValueSubject<[NewsSource], Never>([])
    var sourcesListPublisher: AnyPublisher<[NewsSource], Never> {
        sourcesListSubject.eraseToAnyPublisher()
    }

    private let cacheResetSuccessSubject = PassthroughSubject<Void, Never>()
    var cacheResetSuccessPublisher: AnyPublisher<Void, Never> {
        cacheResetSuccessSubject.eraseToAnyPublisher()
    }

    private let sliderValueSubject = CurrentValueSubject<Int, Never>(
        UserDefaults.standard.refreshNewsTimerDuration == 0
            ? AppConstants.defaultTimerDuration
            : UserDefaults.standard.refreshNewsTimerDuration
    )
    var sliderValuePublisher: AnyPublisher<Int, Never> {
        sliderValueSubject.eraseToAnyPublisher()
    }

    private(set) var sources: [NewsSource] = []

    init(imageCache: ImageCache) {
        model = SettingsModel(
            sources: [
                NewsSource(name: "Rbc", url: "https://rssexport.rbc.ru/rbcnews/news/30/full.rss", show: true),
                NewsSource(name: "Vedomosti", url: "https://www.vedomosti.ru/rss/news.xml", show: true),
            ],
            appTheme: .system,
            refreshInterval: initialTimerValue
        )
        self.imageCache = imageCache
        reloadTimerDuration = initialTimerValue
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
        reloadTimerDuration = duration
        model.refreshInterval = duration
        UserDefaults.standard.refreshNewsTimerDuration = duration
    }

    func selectSource(_ source: NewsSource?) {
        selectedSource = source
    }

    func deselectSource() {
        selectedSource = nil
    }
}
