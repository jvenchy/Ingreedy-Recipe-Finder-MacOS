import SwiftUI
import Alamofire

struct RecipeFinderApp: App {
    var body: some Scene {
        WindowGroup {
            RecipeSearchView()
        }
    }
}

struct RecipeSearchView: View {
    @State private var ingredients: String = ""
    @State private var selectedDietaryPreference: String = "None"
    @State private var recipes: [Recipe] = []
    @State private var hasSearched: Bool = false
    @State private var showBookmarks: Bool = false
    @State private var bookmarkedRecipes: [Recipe] = []

    let dietaryPreferences = ["None", "Gluten Free", "Ketogenic", "Vegetarian", "Vegan", "Pescetarian", "Paleo"]

    var body: some View {
        NavigationView {
            ZStack {
                Color(.white)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Text("Ingreedy 👨🏽‍🍳")
                        .font(.largeTitle)
                        .padding(.top, 40)
                        .foregroundColor(.brown)
                    
                    Text("A Cookbook Recipe Finder")
                        .foregroundColor(.brown)
                        .padding()

                    TextField("Enter ingredients (comma separated)", text: $ingredients)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.brown)
                        .cornerRadius(8)
                        .padding(.horizontal)

                    Picker("Select dietary preference", selection: $selectedDietaryPreference) {
                        ForEach(dietaryPreferences, id: \.self) { preference in
                            Text(preference)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.brown)
                    .cornerRadius(8)
                    .padding(.horizontal)

                    Button(action: {
                        searchRecipes()
                    }) {
                        Text("Search Recipes")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    Button(action: {
                        showBookmarks.toggle()
                        loadBookmarkedRecipes()
                    }) {
                        Text("View Bookmarks")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .background(Color.green)
                    .cornerRadius(8)
                    .padding(.horizontal)

                    if hasSearched && recipes.isEmpty {
                        Text("It's pretty empty here...")
                            .font(.headline)
                            .foregroundColor(Color.brown)
                            .padding()
                    } else {
                        List(recipes, id: \.id) { recipe in
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
                }
                .cornerRadius(15)
                .padding()
                .sheet(isPresented: $showBookmarks) {
                    BookmarkedRecipesView(bookmarkedRecipes: $bookmarkedRecipes)
                }
            }
        }
    }

    private func searchRecipes() {
        hasSearched = true
        let ingredientArray = ingredients.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
        let dietaryPreferenceArray = selectedDietaryPreference == "None" ? [] : [selectedDietaryPreference]

        NetworkManager.shared.fetchRecipes(ingredients: ingredientArray, dietaryPreferences: dietaryPreferenceArray) { result in
            switch result {
            case .success(let recipes):
                self.recipes = recipes
            case .failure(let error):
                print("Error fetching recipes: \(error)")
            }
        }
    }

    private func loadBookmarkedRecipes() {
        if let data = UserDefaults.standard.data(forKey: "bookmarkedRecipes"),
           let decodedRecipes = try? JSONDecoder().decode([Recipe].self, from: data) {
            self.bookmarkedRecipes = decodedRecipes
        }
    }
}
