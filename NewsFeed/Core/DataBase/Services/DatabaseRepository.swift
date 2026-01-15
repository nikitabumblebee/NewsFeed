//
//  DatabaseRepository.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 15.01.2026.
//

import Foundation

protocol DatabaseRepository {
    associatedtype Entity

    func save(_ entity: Entity) async throws
    func getAll() async throws -> [Entity]
    func get(by id: String) async throws -> Entity?
    func delete(by id: String) async throws
}
