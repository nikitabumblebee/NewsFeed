//
//  TabDelegate.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation

// MARK: - TabDelegate

protocol TabDelegate {
    func tabWillAppear(_ tab: TabBarItem)
    func tabWillDisappear()
}

extension TabDelegate {
    func tabWillAppear(_ tab: TabBarItem) {}
    func tabWillDisappear() {}
}
