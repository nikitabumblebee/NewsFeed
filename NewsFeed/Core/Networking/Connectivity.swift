//
//  Connectivity.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 18.01.2026.
//

import Alamofire
import Combine
import Foundation

class Connectivity {
    static var isConnectedToInternet: Bool {
        NetworkReachabilityManager()?.isReachable ?? false
    }

    static let internetConnectionFailedSubject: PassthroughSubject<Void, Never> = .init()
}
