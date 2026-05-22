import Foundation


protocol MealRepositoryProtocol {
    func fetchCategories(completion: @escaping (Result<[MealCategory], NetworkError>) -> Void)
    func searchMeals(query: String, completion: @escaping (Result<[Meal], NetworkError>) -> Void)
    func getFavorites() -> [Meal]
    func toggleFavorite(meal: Meal)
    func isFavorite(mealID: String) -> Bool
    func removeFavorite(mealID: String)
}

final class MealRepository: MealRepositoryProtocol {

    static let shared = MealRepository()

    private let apiService: APIServiceProtocol
    private let userDefaultsKey = "com.quickbite.favorites"

    private init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    func fetchCategories(completion: @escaping (Result<[MealCategory], NetworkError>) -> Void) {
        apiService.fetchCategories(completion: completion)
    }

    func searchMeals(query: String, completion: @escaping (Result<[Meal], NetworkError>) -> Void) {
        apiService.searchMeals(query: query, completion: completion)
    }

    func getFavorites() -> [Meal] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return [] }
        guard let meals = try? JSONDecoder().decode([Meal].self, from: data) else { return [] }
        return meals
    }

    func toggleFavorite(meal: Meal) {
        var favorites = getFavorites()
        if let index = favorites.firstIndex(where: { $0.id == meal.id }) {
            favorites.remove(at: index)
        } else {
            var mutableMeal = meal
            mutableMeal.isFavorite = true
            favorites.append(mutableMeal)
        }
        saveFavorites(favorites)
    }

    func isFavorite(mealID: String) -> Bool {
        let favorites = getFavorites()
        return favorites.contains(where: { $0.id == mealID })
    }

    func removeFavorite(mealID: String) {
        var favorites = getFavorites()
        favorites.removeAll { $0.id == mealID }
        saveFavorites(favorites)
    }

    private func saveFavorites(_ meals: [Meal]) {
        guard let data = try? JSONEncoder().encode(meals) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
}
