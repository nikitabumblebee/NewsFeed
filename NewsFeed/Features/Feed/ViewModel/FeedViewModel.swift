//
//  FeedViewModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Combine
import Foundation

final class FeedViewModel: ObservableObject {
//    typealias SectionType = FeedViewController.SectionType

    private var news = [News]()
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var newsModels: [News] = [
        News(id: "123", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", isViewed: false),
        News(id: "234", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", isViewed: false),
        News(id: "345", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", isViewed: false),
        News(id: "456", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", isViewed: false),
        News(id: "567", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", isViewed: false),
        News(id: "678", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", isViewed: false),
        News(id: "789", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", isViewed: false),
        News(id: "890", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", isViewed: false),
        News(id: "901", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", isViewed: false),
        News(id: "012", title: "Some title", description: "", link: nil, image: nil, date: Date(), source: "Some source", isViewed: false),
    ]

    private(set) var contentLoadState: ContentLoadState = .loading

    func changeViewState(to newState: ContentLoadState) {
        contentLoadState = newState
        switch newState {
        case .loaded, .noData:
            clearModels()
        case .loading:
            break
        }
    }

    func clearModels() {
        news.removeAll()
    }

    func buildViewModels(from newNews: [News]) {
        guard contentLoadState != .loading else { return }
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
