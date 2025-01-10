import UIKit
import Foundation

class ImageCache {
    static let shared = ImageCache()
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private lazy var diskCacheDirectory: URL = {
        // Creates a directory for disk caching
        let directory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("ImageCache", isDirectory: true)
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }()
    
    // Get cached image from memory cache
    func getImageFromMemory(for url: URL) -> UIImage? {
        print("Checking memory cache for \(url.absoluteString)")
        return memoryCache.object(forKey: url.absoluteString as NSString)
    }
    
    // Set image in memory cache
    func setImageInMemory(_ image: UIImage, for url: URL) {
        print("Setting image in memory cache for \(url.absoluteString)")
        memoryCache.setObject(image, forKey: url.absoluteString as NSString)
    }
    
    // Get cached image from disk
    func getImageFromDisk(for url: URL) -> UIImage? {
        let fileURL = diskCacheDirectory.appendingPathComponent(fileName(for: url))
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else { return nil }
        return image
    }
    
    // Save image to disk
    func saveImageToDisk(_ image: UIImage, for url: URL) {
        let fileURL = diskCacheDirectory.appendingPathComponent(fileName(for: url))
        guard let data = image.jpegData(compressionQuality: 0.8) ?? image.pngData() else { return }
        print("Saving image to disk cache at \(fileURL.path)")
        try? data.write(to: fileURL)
    }
    
    // Check if image exists in disk cache
    func imageExistsOnDisk(for url: URL) -> Bool {
        let fileURL = diskCacheDirectory.appendingPathComponent(fileName(for: url))
        print("Checking if image exists on disk at \(fileURL.path)")
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    // Helper method to generate a unique filename for each URL
    private func fileName(for url: URL) -> String {
        // Uses a hash of the URL to ensure uniqueness and prevent issues with dynamic query parameters
        let urlString = url.absoluteString
        let hash = urlString.hashValue
        return "\(hash).jpg" // Save as JPG format, or adjust based on original format
    }
}
