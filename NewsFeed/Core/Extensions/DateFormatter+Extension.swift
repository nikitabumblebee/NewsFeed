//
//  DateFormatter+Extension.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation

extension DateFormatter {
    nonisolated static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        return dateFormatter
    }()

    nonisolated static func get(
        with locale: Locale = Locale.current,
        timeZone: TimeZone = .current,
        dateStyle: Style = .none,
        timeStyle: Style = .none,
        format: DateFormat
    )
        -> DateFormatter
    {
        dateFormatter.locale = locale
        dateFormatter.timeZone = timeZone
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        switch format {
        case let .localizedFromTemplate(template):
            dateFormatter.setLocalizedDateFormatFromTemplate(template)
        case let .dateFormat(template):
            dateFormatter.dateFormat = template
        }
        return dateFormatter
    }

    nonisolated static func string(
        from date: Date,
        with locale: Locale = Locale.current,
        timeZone: TimeZone = TimeZone.current,
        dateStyle: Style = .none,
        timeStyle: Style = .none,
        format: DateFormat
    )
        -> String
    {
        get(with: locale, timeZone: timeZone, dateStyle: dateStyle, timeStyle: timeStyle, format: format).string(from: date)
    }
}

enum DateFormat {
    case localizedFromTemplate(String)
    case dateFormat(String)
}
