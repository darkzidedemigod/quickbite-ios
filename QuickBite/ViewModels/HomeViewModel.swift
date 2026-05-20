import Foundation

enum HomeState {
    case loading
    case success(categories: [MealCategory], meals: [Meal])
    case error(String)
    case empty
}

final class HomeViewModel {

    private let mealRepository: MealRepositoryProtocol

    let state: Observable<HomeState> = Observable(.loading)
    let searchQuery: Observable<String> = Observable("")

    private var allCategories: [MealCategory] = []
    private var allMeals: [Meal] = []

    init(mealRepository: MealRepositoryProtocol = MealRepository.shared) {
        self.mealRepository = mealRepository
        setupSearch()
    }

    private func setupSearch() {
        searchQuery.bind { [weak self] query in
            guard let self = self else { return }

            if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.state.value = .success(categories: self.allCategories, meals: self.allMeals)
            } else {
                self.searchMeals(query: query)
            }
        }
    }

    func fetchCategories() {
        state.value = .loading

        mealRepository.fetchCategories { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self.allCategories = categories
                    self.updateState()
                case .failure(let error):
                    self.state.value = .error(error.localizedDescription)
                }
            }
        }
    }

    private func searchMeals(query: String) {
        state.value = .loading

        mealRepository.searchMeals(query: query) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let meals):
                    self.allMeals = meals
                    if meals.isEmpty {
                        self.state.value = .empty
                    } else {
                        self.state.value = .success(categories: self.allCategories, meals: meals)
                    }
                case .failure(let error):
                    self.state.value = .error(error.localizedDescription)
                }
            }
        }
    }

    func updateSearchQuery(_ query: String) {
        searchQuery.value = query
    }

    private func updateState() {
        if allCategories.isEmpty {
            state.value = .empty
        } else {
            state.value = .success(categories: allCategories, meals: allMeals)
        }
    }
}