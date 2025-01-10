//
//  Recipe.swift
//  RecipeApp
//
//  Created by Puppy on 1/6/25.
//

import Foundation

struct Recipe: Identifiable, Decodable {
    let id: String   // Use `uuid` as `id`
    let name: String
    let cuisine: String
    let photoUrlLarge: URL?
    let photoUrlSmall: URL?
    let sourceUrl: URL?
    let youtubeUrl: URL?
    
    // Custom CodingKeys to map JSON keys to model properties
    enum CodingKeys: String, CodingKey {
        case id = "uuid"  // Map `uuid` from JSON to `id`
        case name
        case cuisine
        case photoUrlLarge = "photo_url_large"
        case photoUrlSmall = "photo_url_small"
        case sourceUrl = "source_url"
        case youtubeUrl = "youtube_url"
    }
}


