//
//  Array+Extensions.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation

extension Array {
    subscript(safe range: Range<Index>) -> ArraySlice<Element>? {
        if range.endIndex > endIndex {
            if range.startIndex >= endIndex { nil } else { self[range.startIndex ..< endIndex] }
        } else {
            self[range]
        }
    }

    func contains<T>(_ element: T) -> Bool where T: Equatable {
        !filter { $0 as? T == element }.isEmpty
    }

    func uniques(by keyPath: KeyPath<Element, some Hashable>) -> [Element] {
        reduce([]) { result, element in
            let alreadyExists = (result.contains(where: { $0[keyPath: keyPath] == element[keyPath: keyPath] }))
            return alreadyExists ? result : result + [element]
        }
    }

    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Array where Element: Hashable {
    func toSet() -> Set<Element> {
        Set(self)
    }
}
