//
//  FeedViewModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation
import Combine

final class FeedViewModel: ObservableObject {
    typealias SectionType = FeedViewController.SectionType
    
    private var news = [News]()
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var newsModels: [(SectionType, [AnyHashable])] = []
    
    func clearModels() {
        news.removeAll()
    }
    
    func buildViewModels(from newNews: [News]) {
        news.append(contentsOf: newNews)
        
    }
}
