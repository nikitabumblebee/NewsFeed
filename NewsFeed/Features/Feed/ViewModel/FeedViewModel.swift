//
//  FeedViewModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import Foundation

final class FeedViewModel: ObservableObject {
    typealias SectionType = FeedViewController.SectionType

    private var news = [News]()
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var newsModels: [News] = []

    func clearModels() {
        news.removeAll()
    }

    func buildViewModels(from newNews: [News]) {
        news.append(contentsOf: newNews)
//        let adapted = NewsModelsAdapter().adapt(news: news)

//        let newGroupedNotifications = adapted.viewModels
//        adaptedNotifications.formUnion(newGroupedNotifications)
//        var sortedNotificationModels: [(SectionType, [News])] = []
//
//        let notificationsArray = Array(adaptedNotifications)
//        for section in SectionType.allCases {
//            let rangedNotifications = notificationsArray.filter {
//                let viewModelDate = ($0 as? News)?.date ?? Date()
//                return section.dateRange.contains(viewModelDate.eraseNanoseconds())
//            }
//
//            if !rangedNotifications.isEmpty {
//                let sortedRangedNotifications = rangedNotifications.sorted {
//                    ($0 as? News)?.date ?? Date() > ($1 as? News)?.date ?? Date()
//                }.compactMap { $0 as? News }
//                sortedNotificationModels.append((section, sortedRangedNotifications))
//            }
//        }

        newsModels = newNews
    }
}
