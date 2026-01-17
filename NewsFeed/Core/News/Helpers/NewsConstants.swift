//
//  NewsConstants.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 17.01.2026.
//

import Foundation

enum NewsConstants {
    static let defaultNewsResources: [NewsResource] = [
        NewsResource(name: "Rbc", url: "https://rssexport.rbc.ru/rbcnews/news/30/full.rss", show: true),
        NewsResource(name: "Vedomosti", url: "https://www.vedomosti.ru/rss/news.xml", show: true),
    ]
}
