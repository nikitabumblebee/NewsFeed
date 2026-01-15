//
//  NewsDB.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 15.01.2026.
//

import Foundation
import RealmSwift
internal import Realm

class NewsDB: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String
    @Persisted var newsDescription: String
    @Persisted var linkString: String?
    @Persisted var image: String?
    @Persisted var date: Date
    @Persisted var source: String?
    @Persisted var isViewed: Bool

    var link: URL? {
        guard let linkString else { return nil }
        return URL(string: linkString)
    }

    override nonisolated init() {
        super.init()
    }
}
