//
//  DatabaseRepository.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 15.01.2026.
//

import Foundation
import RealmSwift

protocol DatabaseRepository {
    associatedtype Entity: Object

    func save(_ entity: Entity) async throws
    func getAll() throws -> [Entity]
    func get(by id: String) throws -> Entity?
    func delete(by id: String) throws
    func update(by id: String, updateBlock: (Entity) throws -> Void) throws
}
