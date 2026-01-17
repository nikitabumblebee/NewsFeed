//
//  SettingsModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 16.01.2026.
//

import Foundation

struct SettingsModel {
    var resources: [NewsResource]
    var appTheme: AppTheme.Theme
    var refreshInterval: Int

    mutating func addSource(_ source: NewsResource) {
        resources.append(source)
    }

    mutating func deleteSource(_ source: NewsResource) {
        resources.removeAll(where: { $0.name == source.name })
    }

    mutating func disableSource(_ source: NewsResource) {
        guard var selectedSource = resources.first(where: { $0.name == source.name }),
              let selectedSourceIndex = resources.firstIndex(of: selectedSource)
        else { return }
        selectedSource.disableSource()
        resources[selectedSourceIndex] = selectedSource
    }

    mutating func enableSource(_ source: NewsResource) {
        guard var selectedSource = resources.first(where: { $0.name == source.name }),
              let selectedSourceIndex = resources.firstIndex(of: selectedSource)
        else { return }
        selectedSource.enableSource()
        resources[selectedSourceIndex] = selectedSource
    }

    mutating func editResource(originalResource: NewsResource, newResource: NewsResource) {
        guard let selectedSource = resources.first(where: { $0.name == originalResource.name }),
              let selectedSourceIndex = resources.firstIndex(of: selectedSource)
        else { return }
        resources[selectedSourceIndex] = newResource
    }
}
