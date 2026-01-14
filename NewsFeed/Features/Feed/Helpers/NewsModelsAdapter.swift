//
//  NewsModelsAdapter.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation

struct NewsModelsAdapter {
    func adapt(news: [News]) -> (viewModels: [News], removedNotifications: [News]) {
        let dayDateRange = FeedViewController.SectionType.day.dateRange
        let weekDateRange = FeedViewController.SectionType.week.dateRange
        let monthDateRange = FeedViewController.SectionType.month.dateRange

        let groupedByDateRangesNotifications = Dictionary(grouping: news) { news -> FeedViewController.SectionType in
            let sectionType: FeedViewController.SectionType
            let fixedNanosecondsDate = news.date.eraseNanoseconds()
            if dayDateRange.contains(fixedNanosecondsDate) {
                sectionType = .day
            } else if weekDateRange.contains(fixedNanosecondsDate) {
                sectionType = .week
            } else if monthDateRange.contains(fixedNanosecondsDate) {
                sectionType = .month
            } else {
                sectionType = .other
            }

            return sectionType
        }

        var notificationViewModels: [News] = []

        var removedNotifications: [News] = []

        for (groupKey, groupNotifications) in groupedByDateRangesNotifications {
            let processingResult = groupNotifications
                .sorted { $0.date > $1.date }
                .removedDuplicatesIfNeeded(key: groupKey)
            if processingResult.removedNotifications.isEmpty == false {
                removedNotifications.append(contentsOf: processingResult.removedNotifications)
            }
//            let groupingCount = groupKey.type == .missedCall ? 1 : 2
            processingResult.notifications.forEach {
                //let viewModel = NotificationModel(notification: $0)
                notificationViewModels.append($0/*viewModel*/)
            }
        }

        return (notificationViewModels, removedNotifications)
        
//        let transformedNews: [FeedViewController.SectionType: [NewsViewModel]] = groupedByDateRangesNotifications.mapValues { news in
//            return news.map { NewsViewModel(news: $0) }
//        }
//        return transformedNews
    }
}

private extension [News] {
    func removedDuplicatesIfNeeded(key: FeedViewController.SectionType) -> (notifications: [News], removedNotifications: [News], canGroup: Bool) {
        var needRemoveDuplicates = true
        var canGroup = true

//        switch key.type {
//        case .callRequestAccept, .newPendingCallRequest:
//            needRemoveDuplicates = false
//            canGroup = false
//        default:
//            break
//        }
        let removed = removedDuplicates()
        return needRemoveDuplicates ? (removed.0, removed.1, canGroup) : (self, [], canGroup)
    }

    private func removedDuplicates() -> ([News], [News]) {
        var uniqueNotifications: [News] = []
        var removedNotifications: [News] = []
        forEach { notification in
//            if !uniqueNotifications.contains(where: {
//                if $0.type == .missedCall {
//                    $0.id == notification.id
//                } else {
//                    $0.sender?.id == notification.sender?.id
//                }
//            }) {
//                uniqueNotifications.append(notification)
//            } else {
                removedNotifications.append(notification)
//            }
        }
        return (uniqueNotifications, removedNotifications)
    }
}

