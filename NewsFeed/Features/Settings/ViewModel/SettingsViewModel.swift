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
    private(set) var selectedSource: NewsResource?

    private var model: SettingsModel
    private let imageCache: ImageCache
    private let newsStorage: NewsStorage
    private let initialTimerValue: Int = UserDefaults.standard.refreshNewsTimerDuration == 0
        ? AppConstants.defaultTimerDuration
        : UserDefaults.standard.refreshNewsTimerDuration

    private let sourcesListSubject = CurrentValueSubject<[NewsResource], Never>([])
    var sourcesListPublisher: AnyPublisher<[NewsResource], Never> {
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

    private(set) var sources: [NewsResource] = []

    init(imageCache: ImageCache, newsStorage: NewsStorage) {
        let initialNewsResources: [NewsResource] = UserDefaults.standard.newsResources ?? AppConstants.defaultNewsResources
        model = SettingsModel(
            sources: initialNewsResources,
            appTheme: .system,
            refreshInterval: initialTimerValue
        )
        self.imageCache = imageCache
        self.newsStorage = newsStorage
        reloadTimerDuration = initialTimerValue
        sources = model.sources
        sourcesListSubject.send(model.sources)
    }

    func resetImagesCache() {
        imageCache.clearCache()
        cacheResetSuccessSubject.send(())
    }

    func addSource(_ source: NewsResource) {
        model.addSource(source)
        sources = model.sources
        sourcesListSubject.send(model.sources)
    }

    func deleteSource(_ source: NewsResource) {
        model.deleteSource(source)
        sources = model.sources
        sourcesListSubject.send(model.sources)
    }

    func disableSource(_ source: NewsResource) {
        model.disableSource(source)
        UserDefaults.standard.newsResources = model.sources
        newsStorage.applyResourcesFilter(model.sources)
    }

    func enableSource(_ source: NewsResource) {
        model.enableSource(source)
        UserDefaults.standard.newsResources = model.sources
        newsStorage.applyResourcesFilter(model.sources)
    }

    func changeRefreshTimerDuration(_ duration: Int) {
        reloadTimerDuration = duration
        model.refreshInterval = duration
        UserDefaults.standard.refreshNewsTimerDuration = duration
    }

    func selectSource(_ source: NewsResource?) {
        selectedSource = source
    }

    func deselectSource() {
        selectedSource = nil
    }
}
