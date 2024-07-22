import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.spoonacular.com/recipes/complexSearch"
    private let apiKey = Config.spoonacularAPIKey

    // in the case the API request fails, call a few default recipies to fall back on.
    private let defaultRecipes: [Recipe] = [
        Recipe(id: 716432, title: "Finger Foods: Frittata Muffins", image: "https://img.spoonacular.com/recipes/716432-312x231.jpg"),
        Recipe(id: 662087, title: "Stuffed Salmon With Tomato-Olive Tapenade", image: "https://img.spoonacular.com/recipes/662087-312x231.jpg"),
        Recipe(id: 661948, title: "Strip steak with roasted cherry tomatoes and vegetable mash", image: "https://img.spoonacular.com/recipes/661948-312x231.jpg")
    ]

    func fetchRecipes(ingredients: [String], dietaryPreferences: [String], completion: @escaping (Result<[Recipe], Error>) -> Void) {
        var parameters: [String: Any] = [
            "apiKey": apiKey,
            "includeIngredients": ingredients.joined(separator: ",")
        ]
        
        if !dietaryPreferences.isEmpty {
            parameters["diet"] = dietaryPreferences.joined(separator: ",")
        }

        AF.request(baseURL, parameters: parameters).responseDecodable(of: RecipeResponse.self) { response in
            switch response.result {
            case .success(let recipeResponse):
                completion(.success(recipeResponse.results))
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion(.success(self.defaultRecipes))
            }
        }
    }
}

extension NetworkManager {
    func fetchRecipeDetails(recipeId: Int, completion: @escaping (Result<RecipeDetails, Error>) -> Void) {
        let url = "https://api.spoonacular.com/recipes/\(recipeId)/information"
        let parameters: [String: Any] = ["apiKey": apiKey]

        AF.request(url, parameters: parameters).responseString { response in
            switch response.result {
            case .success(let responseString):
                print("Response String: \(responseString)") // Print the raw response string
                if let data = responseString.data(using: .utf8) {
                    do {
                        let details = try JSONDecoder().decode(RecipeDetails.self, from: data)
                        completion(.success(details))
                    } catch {
                        print("Decoding Error: \(error)")
                        completion(.failure(error))
                    }
                } else {
                    print("Error: Unable to convert response string to data")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert response string to data"])))
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion(.failure(error))
            }
        }
    }
}

// RecipeDetails model
struct RecipeDetails: Decodable {
    let id: Int
    let title: String
    let image: String?
    let summary: String
    let readyInMinutes: Int
    let servings: Int
    let sourceUrl: String
    let extendedIngredients: [Ingredient]
    let instructions: String
    
    struct Ingredient: Decodable {
        let id: Int
        let name: String
        let amount: Double
        let unit: String
        let original: String
    }
}

// Models
struct RecipeResponse: Decodable {
    let results: [Recipe]
}

struct Recipe: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String?
}
