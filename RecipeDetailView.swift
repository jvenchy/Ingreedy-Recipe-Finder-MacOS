import SwiftUI

struct RecipeDetailView: View {
    let recipeId: Int
    @State private var recipeDetails: RecipeDetails? = nil
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            if let recipeDetails = recipeDetails {
                ScrollView {
                    if let imageUrl = recipeDetails.image, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                            } else if phase.error != nil {
                                Color.red // indicate an error retrieving the image
                                    .frame(maxWidth: .infinity)
                            } else {
                                Color.gray // placeholder
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    Text(recipeDetails.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()

                    Text(stripHTML(from: recipeDetails.summary))
                        .padding()
                    
                    Text("Ingredients")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(recipeDetails.extendedIngredients, id: \.id) { ingredient in
                        Text(ingredient.original)
                            .padding(.horizontal)
                    }
                    
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
        }
    }

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

    private func stripHTML(from string: String) -> String {
        guard let data = string.data(using: .utf8) else { return string }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
        return attributedString?.string ?? string
    }
}

struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetailView(recipeId: 636589)
    }
}
