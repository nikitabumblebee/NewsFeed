//
//  UserDefaults+Extensions.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 15.01.2026.
//

import Foundation

extension UserDefaults {
    @objc var selectedNewsPresentationType: Int {
        get {
            integer(forKey: "selectedCounselorChatType")
        }
        set {
            set(newValue, forKey: "selectedCounselorChatType")
        }
    }
}
