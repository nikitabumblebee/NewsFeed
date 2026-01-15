//
//  Date+Extensions.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation

extension Date {
    nonisolated func startOfDay() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.startOfDay(for: self)
    }

    nonisolated func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay()) ?? Date()
    }

    nonisolated func changeDays(by days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? Date()
    }

    nonisolated func eraseNanoseconds() -> Date {
        let zeroNanoseconds = Calendar.current.date(bySetting: .nanosecond, value: 0, of: self) ?? Date()
        return Calendar.current.date(byAdding: .nanosecond, value: -1, to: zeroNanoseconds) ?? Date()
    }

    nonisolated func getLongDateTime() -> String {
        DateFormatter.string(from: self, format: .dateFormat("d MMM yy 'at' HH:mm"))
    }
}
