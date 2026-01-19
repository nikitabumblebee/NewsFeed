//
//  NewsDataBaseService.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 15.01.2026.
//

import Foundation

class NewsDatabaseService: DatabaseRepository {
    static let shared = NewsDatabaseService()
    private let repo: RealmDatabaseRepository<NewsDB>

    private init() {
        self.repo = RealmDatabaseRepository<NewsDB>()
    }

    func save(_ newsDB: NewsDB) async throws {
        try await repo.save(newsDB)
    }

    func getAll() throws -> [NewsDB] {
        try repo.getAll()
    }

    func get(by id: String) throws -> NewsDB? {
        try repo.get(by: id)
    }

    func delete(by id: String) throws {
        try repo.delete(by: id)
    }

    @MainActor func update(by id: String, updateBlock: (NewsDB) throws -> Void) throws {
        try repo.update(by: id, updateBlock: updateBlock)
    }
}
