//
//  ImageCache.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 15.01.2026.
//

import CommonCrypto
import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskURL: URL

    private init() {
        memoryCache.countLimit = 400 // 400 изображений
        memoryCache.totalCostLimit = 100 * 1024 * 1024 // 100MB

        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskURL = cachesDir.appendingPathComponent("ImageCache")
        try? FileManager.default.createDirectory(at: diskURL, withIntermediateDirectories: true)
    }

    func image(for url: URL) async throws -> UIImage {
        let key = url.absoluteString

        if let cached = memoryCache.object(forKey: key as NSString) {
            return cached
        }

        if let diskImage = try? loadFromDisk(key: key) {
            memoryCache.setObject(diskImage, forKey: key as NSString, cost: diskImage.jpegData(compressionQuality: 0.8)?.count ?? 0)
            return diskImage
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageCacheError.invalidImage
        }

        memoryCache.setObject(image, forKey: key as NSString, cost: data.count)
        try saveToDisk(image: image, key: key)

        return image
    }

    func clearCache() {
        memoryCache.removeAllObjects()
        try? FileManager.default.removeItem(at: diskURL)
        try? FileManager.default.createDirectory(at: diskURL, withIntermediateDirectories: true)
    }

    private func saveToDisk(image: UIImage, key: String) throws {
        guard let data = image.jpegData(compressionQuality: 0.8) ?? image.pngData() else { throw ImageCacheError.invalidImage }
        let fileURL = diskURL.appendingPathComponent(key.sha256())
        try data.write(to: fileURL)
    }

    private func loadFromDisk(key: String) throws -> UIImage {
        let fileURL = diskURL.appendingPathComponent(key.sha256())
        let data = try Data(contentsOf: fileURL)
        guard let image = UIImage(data: data) else { throw ImageCacheError.invalidImage }
        return image
    }
}

enum ImageCacheError: Error {
    case invalidImage
}

private extension String {
    func sha256() -> String {
        let data = Data(utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
