import Foundation
import UIKit

@MainActor // Ensures all updates happen on the main thread
class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Fetch recipes from the API
    func fetchRecipes() async {
        guard let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json") else {
            self.errorMessage = "Invalid URL"
            return
        }
        // Set loading state and clear previous errors
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode([String: [Recipe]].self, from: data)
            if let fetchedRecipes = decodedResponse["recipes"] {
                self.recipes = fetchedRecipes
            } else {
                self.errorMessage = "No recipes found"
            }
        } catch {
            self.errorMessage = "Failed to load recipes: \(error.localizedDescription)"
        }
        // Set loading state to false
        self.isLoading = false
    }
    
    func loadImage(for url: URL) async -> UIImage? {
        // First, check the memory cache
        if let cachedImage = ImageCache.shared.getImageFromMemory(for: url) {
            print("Returning cached image from memory: \(url)")
            return cachedImage
        }
        // Check the disk cache if not in memory
        if ImageCache.shared.imageExistsOnDisk(for: url) {
            if let imageFromDisk = ImageCache.shared.getImageFromDisk(for: url) {
                // Store the disk image in memory cache as well
                ImageCache.shared.setImageInMemory(imageFromDisk, for: url)
                print("Returning cached image from disk: \(url)")
                return imageFromDisk
            }
        }
        // If image is not in cache, fetch it from the network
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                // Save the image to both memory and disk caches
                ImageCache.shared.setImageInMemory(image, for: url)
                ImageCache.shared.saveImageToDisk(image, for: url)
                print("Fetched and cached image from network: \(url)")
                return image
            }
        } catch {
            print("Failed to load image from URL: \(url), error: \(error)")
        }
        return nil
    }
}
