//
//  ContentView.swift
//  RecipeApp
//
//  Created by Puppy on 1/6/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = RecipeViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.title2)
                        .padding()
                } else if viewModel.recipes.isEmpty {
                    Text("No recipes available.")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.recipes) { recipe in
                        RecipeRow(recipe: recipe, viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("Recipes")
            .onAppear {
                Task {
                    await viewModel.fetchRecipes()
                }
            }
            .refreshable {
                await viewModel.fetchRecipes()
            }
        }
    }
}

struct RecipeRow: View {
    let recipe: Recipe
    @StateObject var viewModel: RecipeViewModel
    
    @State private var recipeImage: UIImage? = nil
    
    var body: some View {
        HStack {
            if let image = recipeImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            } else {
                Color.gray.frame(width: 100, height: 100)
            }
            
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.headline)
                Text(recipe.cuisine)
                    .font(.subheadline)
            }
        }
        .task {
            if let imageUrl = recipe.photoUrlSmall {
                // Load image asynchronously using the view model
                recipeImage = await viewModel.loadImage(for: imageUrl)
            }
        }
    }
}
#Preview {
    ContentView()
}
