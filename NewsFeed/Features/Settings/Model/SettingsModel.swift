//
//  SettingsModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 16.01.2026.
//

import Foundation

struct SettingsModel {
    var sources: [NewsSource]
    var appTheme: AppTheme.Theme
    var refreshInterval: Int

    mutating func addSource(_ source: NewsSource) {
        sources.append(source)
    }

    mutating func deleteSource(_ source: NewsSource) {
        sources.removeAll(where: { $0.name == source.name })
    }

    mutating func disableSource(_ source: NewsSource) {
        var selectedSource = sources.first(where: { $0.name == source.name })
        selectedSource?.disableSource()
    }

    mutating func enableSource(_ source: NewsSource) {
        var selectedSource = sources.first(where: { $0.name == source.name })
        selectedSource?.enableSource()
    }
}
