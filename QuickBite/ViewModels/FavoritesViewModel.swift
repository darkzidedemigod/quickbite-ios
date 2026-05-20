import Foundation

enum FavoritesState {
    case loading
    case success([Meal])
    case empty
}

final class FavoritesViewModel {

    private let mealRepository: MealRepositoryProtocol

    let state: Observable<FavoritesState> = Observable(.empty)

    init(mealRepository: MealRepositoryProtocol = MealRepository.shared) {
        self.mealRepository = mealRepository
    }

    func fetchFavorites() {
        let favorites = mealRepository.getFavorites()
        if favorites.isEmpty {
            state.value = .empty
        } else {
            state.value = .success(favorites)
        }
    }

    func removeFavorite(mealID: String) {
        mealRepository.removeFavorite(mealID: mealID)
        fetchFavorites()
    }

    func toggleFavorite(meal: Meal) {
        mealRepository.toggleFavorite(meal: meal)
        fetchFavorites()
    }
}