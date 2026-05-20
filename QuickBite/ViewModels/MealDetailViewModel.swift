import Foundation

final class MealDetailViewModel {

    private let mealRepository: MealRepositoryProtocol

    let meal: Observable<Meal?> = Observable(nil)
    let isFavorite: Observable<Bool> = Observable(false)
    let state: Observable<String?> = Observable(nil)

    private var mealID: String = ""

    init(mealRepository: MealRepositoryProtocol = MealRepository.shared) {
        self.mealRepository = mealRepository
    }

    func configure(with meal: Meal) {
        self.meal.value = meal
        self.mealID = meal.id
        self.isFavorite.value = mealRepository.isFavorite(mealID: meal.id)
    }

    func toggleFavorite() {
        guard let currentMeal = meal.value else { return }

        mealRepository.toggleFavorite(meal: currentMeal)
        isFavorite.value = mealRepository.isFavorite(mealID: mealID)
    }
}