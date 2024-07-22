import SwiftUI

// A view that displays detailed information about a specific recipe
struct RecipeDetailView: View {
    // The ID of the recipe to be displayed
    let recipeId: Int
    // The details of the recipe fetched from the network
    @State private var recipeDetails: RecipeDetails? = nil
    @Environment(\.presentationMode) var presentationMode
    @State private var isBookmarked: Bool = false
    @State private var showBookmarkConfirmation: Bool = false
    @State private var bookmarkMessage: String = ""

    var body: some View {
        VStack {
            if let recipeDetails = recipeDetails {
                ScrollView {
                    // Display recipe image if available
                    if let imageUrl = recipeDetails.image, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                            } else if phase.error != nil {
                                Color.red
                                    .frame(maxWidth: .infinity)
                            } else {
                                Color.gray
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    // Display recipe title
                    Text(recipeDetails.title)
                        .font(.largeTitle)
                        .padding()
                    // Display recipe summary, stripped of HTML tags
                    Text(stripHTML(from: recipeDetails.summary))
                        .padding()
                    // Display list of ingredients
                    Text("Ingredients")
                        .font(.headline)
                        .padding(.top)
                    ForEach(recipeDetails.extendedIngredients, id: \.id) { ingredient in
                        Text(ingredient.original)
                            .padding(.horizontal)
                    }
                    // Display instructions
                    Text("Instructions")
                        .font(.headline)
                        .padding(.top)
                    Text(recipeDetails.instructions)
                        .padding()
                }
                .padding()
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            fetchRecipeDetails()
            checkIfBookmarked()
        }
        .navigationTitle("Recipe Details")
        .background(Color.white)
        .foregroundColor(Color.brown)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.blue)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    toggleBookmark()
                }) {
                    Image(systemName: isBookmarked ? "star.fill" : "star")
                        .foregroundColor(isBookmarked ? .green : .gray)
                }
            }
        }
        .overlay(
            VStack {
                if showBookmarkConfirmation {
                    Text(bookmarkMessage)
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .transition(.scale)
                }
                Spacer()
            }
        )
    }

    // Fetches details of the recipe from network
    private func fetchRecipeDetails() {
        NetworkManager.shared.fetchRecipeDetails(recipeId: recipeId) { result in
            switch result {
            case .success(let details):
                self.recipeDetails = details
            case .failure(let error):
                print("Error fetching recipe details: \(error)")
            }
        }
    }

    // Strips HTML tags from a given string
    // - Parameter string: The string containing HTML tags
    // - Returns: A string without HTML tags
    private func stripHTML(from string: String) -> String {
        guard let data = string.data(using: .utf8) else { return string }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ]
        let attributedString = try? NSAttributedString(
            data: data, options: options, documentAttributes: nil)
        return attributedString?.string ?? string
    }

    private func toggleBookmark() {
        if isBookmarked {
            removeBookmark()
            bookmarkMessage = "Recipe is no longer bookmarked."
        } else {
            addBookmark()
            bookmarkMessage = "Recipe Bookmarked!"
        }
        isBookmarked.toggle()
        withAnimation {
            showBookmarkConfirmation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showBookmarkConfirmation = false
            }
        }
    }

    private func addBookmark() {
        var bookmarks = fetchBookmarkedRecipes()
        if let recipeDetails = recipeDetails {
            let recipe = Recipe(id: recipeDetails.id, title: recipeDetails.title, image: recipeDetails.image)
            bookmarks.append(recipe)
            saveBookmarkedRecipes(bookmarks)
        }
    }

    private func removeBookmark() {
        var bookmarks = fetchBookmarkedRecipes()
        bookmarks.removeAll { $0.id == recipeId }
        saveBookmarkedRecipes(bookmarks)
    }

    private func checkIfBookmarked() {
        let bookmarks = fetchBookmarkedRecipes()
        isBookmarked = bookmarks.contains { $0.id == recipeId }
    }

    private func fetchBookmarkedRecipes() -> [Recipe] {
        if let data = UserDefaults.standard.data(forKey: "bookmarkedRecipes"),
           let decodedRecipes = try? JSONDecoder().decode([Recipe].self, from: data) {
            return decodedRecipes
        }
        return []
    }

    private func saveBookmarkedRecipes(_ recipes: [Recipe]) {
        if let encodedData = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(encodedData, forKey: "bookmarkedRecipes")
        }
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetailView(recipeId: 636589)
    }
}
