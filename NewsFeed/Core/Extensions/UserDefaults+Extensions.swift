//
//  UserDefaults+Extensions.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 15.01.2026.
//

import Foundation

extension UserDefaults {
    @objc var refreshNewsTimerDuration: Int {
        get {
            integer(forKey: "refreshNewsTimerDuration")
        }
        set {
            set(newValue, forKey: "refreshNewsTimerDuration")
        }
    }
}
