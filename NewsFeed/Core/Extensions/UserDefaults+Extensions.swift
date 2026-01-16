//
//  UserDefaults+Extensions.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 15.01.2026.
//

import Foundation

// MARK: - UserDefaultsSaveable

protocol UserDefaultsSaveable {
    func setObject(_ object: some Encodable, forKey: String) throws
    func getObject<T>(forKey: String, castTo type: T.Type) throws -> T where T: Decodable
}

// MARK: - UserDefaultsSaveableError

enum UserDefaultsSaveableError: String, LocalizedError {
    case unableToEncode
    case unableToDecode
    case noValue

    var errorDescription: String? {
        rawValue
    }
}

// MARK: - UserDefaults + UserDefaultsSaveable

extension UserDefaults: UserDefaultsSaveable {
    func setObject(_ object: some Encodable, forKey: String) throws {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw UserDefaultsSaveableError.unableToEncode
        }
    }

    func getObject<T>(forKey: String, castTo type: T.Type) throws -> T where T: Decodable {
        guard let data = data(forKey: forKey) else { throw UserDefaultsSaveableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw UserDefaultsSaveableError.unableToDecode
        }
    }
}

extension UserDefaults {
    @objc var refreshNewsTimerDuration: Int {
        get {
            integer(forKey: "refreshNewsTimerDuration")
        }
        set {
            set(newValue, forKey: "refreshNewsTimerDuration")
        }
    }

    var newsResources: [NewsResource]? {
        get {
            try? getObject(forKey: "newsResources", castTo: [NewsResource].self)
        }
        set {
            try? setObject(newValue, forKey: "newsResources")
        }
    }
}
