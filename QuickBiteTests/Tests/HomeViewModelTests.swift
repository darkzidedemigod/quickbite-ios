import XCTest
@testable import QuickBite

final class HomeViewModelTests: XCTestCase {

    private var sut: HomeViewModel!
    private var mockRepository: MockMealRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockMealRepository()
        sut = HomeViewModel(mealRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testInitialStateIsLoading() {
        if case .loading = sut.state.value {
            XCTAssertTrue(true)
        } else {
            XCTFail("Initial state should be loading")
        }
    }

    func testFetchCategoriesSuccess() {
        let expectation = self.expectation(description: "Fetch categories succeeds")
        mockRepository.shouldSucceed = true

        sut.fetchCategories()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if case .success(let categories, _) = self.sut.state.value {
                XCTAssertFalse(categories.isEmpty)
                expectation.fulfill()
            } else {
                XCTFail("Expected success state")
            }
        }

        waitForExpectations(timeout: 2.0)
    }

    func testFetchCategoriesFailure() {
        let expectation = self.expectation(description: "Fetch categories fails")
        mockRepository.shouldSucceed = false

        sut.fetchCategories()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if case .error = self.sut.state.value {
                expectation.fulfill()
            } else {
                XCTFail("Expected error state")
            }
        }

        waitForExpectations(timeout: 2.0)
    }

    func testSearchQueryUpdateTriggersSearch() {
        let expectation = self.expectation(description: "Search triggered by query update")
        mockRepository.shouldSucceed = true

        sut.fetchCategories()
        sut.updateSearchQuery("chicken")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if case .success = self.sut.state.value {
                expectation.fulfill()
            } else {
                XCTFail("Expected success state after search")
            }
        }

        waitForExpectations(timeout: 2.0)
    }

    func testEmptySearchQueryShowsCategories() {
        let expectation = self.expectation(description: "Empty search shows categories")
        mockRepository.shouldSucceed = true

        sut.fetchCategories()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.sut.updateSearchQuery("")

            if case .success(let categories, _) = self.sut.state.value {
                XCTAssertFalse(categories.isEmpty)
                expectation.fulfill()
            } else {
                XCTFail("Expected success state with categories")
            }
        }

        waitForExpectations(timeout: 2.0)
    }

    func testSearchWithNoResultsShowsEmpty() {
        let expectation = self.expectation(description: "Search with no results")
        mockRepository.shouldSucceed = true
        mockRepository.searchResultIsEmpty = true

        sut.updateSearchQuery("xyznonexistent")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if case .empty = self.sut.state.value {
                expectation.fulfill()
            } else {
                XCTFail("Expected empty state")
            }
        }

        waitForExpectations(timeout: 3.0)
    }
}

// MARK: - MockMealRepository

final class MockMealRepository: MealRepositoryProtocol {

    var shouldSucceed: Bool = true
    var searchResultIsEmpty: Bool = false

    private let mockCategories: [MealCategory] = [
        MealCategory(
            idCategory: "1",
            strCategory: "Beef",
            strCategoryThumb: "https://example.com/beef.jpg",
            strCategoryDescription: "Beef dishes"
        ),
        MealCategory(
            idCategory: "2",
            strCategory: "Chicken",
            strCategoryThumb: "https://example.com/chicken.jpg",
            strCategoryDescription: "Chicken dishes"
        )
    ]

    private let mockMeals: [Meal] = []

    func fetchCategories(completion: @escaping (Result<[MealCategory], NetworkError>) -> Void) {
        DispatchQueue.global().async {
            if self.shouldSucceed {
                completion(.success(self.mockCategories))
            } else {
                completion(.failure(.requestFailed(NSError(domain: "test", code: -1))))
            }
        }
    }

    func searchMeals(query: String, completion: @escaping (Result<[Meal], NetworkError>) -> Void) {
        DispatchQueue.global().async {
            if self.shouldSucceed {
                if self.searchResultIsEmpty {
                    completion(.success([]))
                } else {
                    completion(.success(self.mockMeals))
                }
            } else {
                completion(.failure(.requestFailed(NSError(domain: "test", code: -1))))
            }
        }
    }

    func getFavorites() -> [Meal] { return [] }
    func toggleFavorite(meal: Meal) {}
    func isFavorite(mealID: String) -> Bool { return false }
    func removeFavorite(mealID: String) {}
}