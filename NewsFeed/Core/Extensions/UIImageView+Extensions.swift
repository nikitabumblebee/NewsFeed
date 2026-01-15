//
//  UIImageView+Extensions.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import Foundation
import UIKit

extension UIImageView {
    func loadImage(from url: URL?, placeholder: UIImage? = nil) async {
        image = placeholder
        guard let url else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else { return }
            await MainActor.run { image = uiImage }
        } catch {
            print("Load error: \(error)")
        }
    }
}
