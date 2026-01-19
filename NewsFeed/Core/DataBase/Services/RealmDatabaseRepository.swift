//
//  RealmDatabaseRepository.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 15.01.2026.
//

import Foundation
import RealmSwift

class RealmDatabaseRepository<EntityType: Object>: DatabaseRepository {
    typealias Entity = EntityType

    private let realm: Realm

    init(configuration: Realm.Configuration = .defaultConfiguration) {
        do {
            self.realm = try Realm(configuration: configuration)
        } catch {
            fatalError("Realm failed: \(error)")
        }
    }

    @MainActor func save(_ entity: Entity) async throws {
        try await Task { @MainActor in
            try realm.write {
                realm.add(entity, update: .modified)
            }
        }.value
    }

    @MainActor func getAll() throws -> [Entity] {
        let results = realm.objects(Entity.self)
        return Array(results)
    }

    @MainActor func get(by id: String) throws -> Entity? {
        realm.object(ofType: Entity.self, forPrimaryKey: id)
    }

    @MainActor func delete(by id: String) throws {
        guard let object = realm.object(ofType: Entity.self, forPrimaryKey: id) else { return }
        try realm.write {
            realm.delete(object)
        }
    }

    @MainActor func update(by id: String, updateBlock: (Entity) throws -> Void) throws {
        guard let entity = realm.object(ofType: Entity.self, forPrimaryKey: id) else { return }

        try realm.write {
            try updateBlock(entity)
        }
    }
}
