//
//  NewsViewModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation

nonisolated struct NewsViewModel: Sendable, Hashable {
    let news: News
}

//extension NewsViewModel: Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(news.id)
//    }
//    
//    static func == (lhs: NewsViewModel, rhs: NewsViewModel) -> Bool {
//        lhs.news.id == rhs.news.id
//    }
//}

