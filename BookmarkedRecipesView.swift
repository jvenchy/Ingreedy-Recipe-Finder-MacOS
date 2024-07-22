import SwiftUI

struct BookmarkedRecipesView: View {
    @Binding var bookmarkedRecipes: [Recipe]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                
                Text("Your Bookmarks")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                
                List(bookmarkedRecipes, id: \.id) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                        HStack {
                            if let imageUrl = recipe.image, let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } else if phase.error != nil {
                                        Color.red // indicate an error retrieving the image
                                            .frame(width: 50, height: 50)
                                    } else {
                                        Color.gray // Placeholder
                                            .frame(width: 50, height: 50)
                                    }
                                }
                            } else {
                                Color.gray // placeholder for any missing image
                                    .frame(width: 50, height: 50)
                            }
                            Text(recipe.title)
                                .font(.headline)
                                .padding(.leading, 10)
                        }
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity, alignment: .leading) // This ensures the HStack takes up the full width
                        .background(Color(red: 0.1216, green: 0.1216, blue: 0.1373))
                        .foregroundColor(Color.white)
                        .cornerRadius(8)
                    }
                }
                .listStyle(PlainListStyle())
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Bookmarked Recipes")
        }
    }
}

struct BookmarkedRecipesView_Previews: PreviewProvider {
    @State static var bookmarkedRecipes: [Recipe] = [
        Recipe(id: 1, title: "Sample Recipe", image: nil)
    ]
    
    static var previews: some View {
        BookmarkedRecipesView(bookmarkedRecipes: $bookmarkedRecipes)
    }
}
