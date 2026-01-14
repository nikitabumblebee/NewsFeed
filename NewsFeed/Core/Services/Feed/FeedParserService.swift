//
//  FeedParserService.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation
import Combine

class FeedParserService {
    static let shared = FeedParserService()
    
    private var cancellables: Set<AnyCancellable> = []
    private var news: [News] = []
    
    private init() {}
    
    func parceFeed(from url: URL) -> AnyPublisher<[News], Error> {
        Future<[News], Error> { promise in
            
        }
        .eraseToAnyPublisher()
    }
    
    func fetchFeed(fromBeginning: Bool, limit: Int) -> AnyPublisher<[News], Never> {
        Future<[News], Never> { promise in
            
        }
        .eraseToAnyPublisher()
    }
}
