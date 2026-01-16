//
//  SettingsModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 16.01.2026.
//

import Foundation

struct SettingsModel {
    var sources: [NewsResource]
    var appTheme: AppTheme.Theme
    var refreshInterval: Int

    mutating func addSource(_ source: NewsResource) {
        sources.append(source)
    }

    mutating func deleteSource(_ source: NewsResource) {
        sources.removeAll(where: { $0.name == source.name })
    }

    mutating func disableSource(_ source: NewsResource) {
        guard var selectedSource = sources.first(where: { $0.name == source.name }),
              let selectedSourceIndex = sources.firstIndex(of: selectedSource)
        else { return }
        selectedSource.disableSource()
        sources[selectedSourceIndex] = selectedSource
    }

    mutating func enableSource(_ source: NewsResource) {
        guard var selectedSource = sources.first(where: { $0.name == source.name }),
              let selectedSourceIndex = sources.firstIndex(of: selectedSource)
        else { return }
        selectedSource.enableSource()
        sources[selectedSourceIndex] = selectedSource
    }
}
