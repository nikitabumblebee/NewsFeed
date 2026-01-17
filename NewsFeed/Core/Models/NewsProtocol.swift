//
//  NewsProtocol.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 16.01.2026.
//

import Foundation

protocol NewsProtocol: Sendable, Equatable {
    var id: String { get }
    var title: String { get }
    var description: String { get }
    var link: URL? { get }
    var image: String? { get }
    var date: Date { get }
    var author: String? { get }
    var resource: String? { get }
    var isViewed: Bool { get set }

    func toNewsDB() -> NewsDB
}
