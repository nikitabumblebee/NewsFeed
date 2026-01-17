//
//  SettingsViewModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import Foundation

final class SettingsViewModel {
    private(set) var reloadTimerDuration: Int = SettingsConstants.defaultTimerDuration

    private var model: SettingsModel
    private let imageCache: ImageCache
    private let newsStorage: NewsStorage
    private let parserService: FeedParserService
    private let initialTimerValue: Int = UserDefaults.standard.refreshNewsTimerDuration == 0
        ? SettingsConstants.defaultTimerDuration
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
            ? SettingsConstants.defaultTimerDuration
            : UserDefaults.standard.refreshNewsTimerDuration
    )
    var sliderValuePublisher: AnyPublisher<Int, Never> {
        sliderValueSubject.eraseToAnyPublisher()
    }

    private(set) var resources: [NewsResource] = []

    init(
        imageCache: ImageCache,
        newsStorage: NewsStorage,
        parserService: FeedParserService
    ) {
        let initialNewsResources: [NewsResource] = newsStorage.allNewsResources
        model = SettingsModel(
            resources: initialNewsResources,
            appTheme: .system,
            refreshInterval: initialTimerValue
        )
        self.imageCache = imageCache
        self.newsStorage = newsStorage
        self.parserService = parserService
        reloadTimerDuration = initialTimerValue
        resources = model.resources
        sourcesListSubject.send(model.resources)
    }

    func resetImagesCache() {
        imageCache.clearCache()
        cacheResetSuccessSubject.send(())
    }

    func addResource(_ resource: NewsResource) {
        model.addSource(resource)
        resources = model.resources
        UserDefaults.standard.newsResources = model.resources
        sourcesListSubject.send(model.resources)
        newsStorage.applyResourcesFilter(model.resources)
        Task {
            await self.parserService.parseNewNews()
        }
    }

    func deleteResource(_ resource: NewsResource) {
        model.deleteSource(resource)
        resources = model.resources
        UserDefaults.standard.newsResources = model.resources
        sourcesListSubject.send(model.resources)
        newsStorage.applyResourcesFilter(model.resources)
        Task {
            await self.parserService.parseNewNews()
        }
    }

    func editResource(resource: NewsResource, to newResource: NewsResource) {
        model.editResource(originalResource: resource, newResource: newResource)
        resources = model.resources
        UserDefaults.standard.newsResources = model.resources
        sourcesListSubject.send(model.resources)
        newsStorage.applyResourcesFilter(model.resources)
        Task {
            await self.parserService.parseNewNews()
        }
    }

    func disableResource(_ resource: NewsResource) {
        model.disableSource(resource)
        UserDefaults.standard.newsResources = model.resources
        newsStorage.applyResourcesFilter(model.resources)
    }

    func enableResource(_ resource: NewsResource) {
        model.enableSource(resource)
        UserDefaults.standard.newsResources = model.resources
        newsStorage.applyResourcesFilter(model.resources)
    }

    func changeRefreshTimerDuration(_ duration: Int) {
        reloadTimerDuration = duration
        model.refreshInterval = duration
        UserDefaults.standard.refreshNewsTimerDuration = duration
    }
}
