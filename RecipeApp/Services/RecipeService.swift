//
//  RecipeService.swift
//  RecipeApp
//
//  Created by Puppy on 1/6/25.
//

import Foundation

class RecipeService {
    
    private let baseURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
    
    func fetchRecipes() async throws -> [Recipe] {
        let (data, _) = try await URLSession.shared.data(from: baseURL)
        
        // Decode the JSON response
        let decoder = JSONDecoder()
        
        // Attempt to decode the response into the expected format
        do {
            let response = try decoder.decode([String: [Recipe]].self, from: data)
            return response["recipes"] ?? []
        } catch {
            throw RecipeServiceError.malformedData
        }
    }
    
    enum RecipeServiceError: Error {
        case malformedData
    }
}

