//
//  FeedConstants.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 17.01.2026.
//

import Foundation

enum FeedConstants {
    static let defaultTimerDuration: Int = 5
    static let initialNewsForLoad: [any NewsProtocol] = [
        BaseNews(id: "123", title: "Some title", description: "", link: nil, image: nil, date: Date(), author: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "234", title: "Some title", description: "", link: nil, image: nil, date: Date(), author: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "345", title: "Some title", description: "", link: nil, image: nil, date: Date(), author: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "456", title: "Some title", description: "", link: nil, image: nil, date: Date(), author: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "567", title: "Some title", description: "", link: nil, image: nil, date: Date(), author: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "678", title: "Some title", description: "", link: nil, image: nil, date: Date(), author: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "789", title: "Some title", description: "", link: nil, image: nil, date: Date(), author: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "890", title: "Some title", description: "", link: nil, image: nil, date: Date(), author: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "901", title: "Some title", description: "", link: nil, image: nil, date: Date(), author: "Some source", resource: nil, isViewed: false),
        BaseNews(id: "012", title: "Some title", description: "", link: nil, image: nil, date: Date(), author: "Some source", resource: nil, isViewed: false),
    ]
}
