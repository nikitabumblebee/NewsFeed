//
//  BaseTabBar.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 17.01.2026.
//

import Foundation
import UIKit

protocol BaseTabBar {
    var rootView: UIView? { get set }
    var basePresentedViewController: UIViewController? { get set }

    func getCurrentViewController() -> UINavigationController?
    func getViewController(at tabItem: TabBarItemType) -> UIViewController?
}
