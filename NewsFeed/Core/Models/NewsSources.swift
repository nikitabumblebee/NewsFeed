//
//  NewsSources.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 15.01.2026.
//

import Foundation

enum NewsSources: String, CaseIterable {
    case vedomosti = "https://www.vedomosti.ru/rss/news.xml"
    case rbc = "https://rssexport.rbc.ru/rbcnews/news/30/full.rss"
}
