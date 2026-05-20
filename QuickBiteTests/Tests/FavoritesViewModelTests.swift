import XCTest
@testable import QuickBite

final class FavoritesViewModelTests: XCTestCase {

    private var sut: FavoritesViewModel!
    private var mockRepository: MockFavoritesMealRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockFavoritesMealRepository()
        sut = FavoritesViewModel(mealRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    func testInitialStateIsEmpty() {
        if case .empty = sut.state.value {
            XCTAssertTrue(true)
        } else {
            XCTFail("Initial state should be empty")
        }
    }

    func testFetchFavoritesReturnsMeals() {
        let expectation = self.expectation(description: "Fetch favorites")
        mockRepository.shouldReturnData = true

        sut.fetchFavorites()

        DispatchQueue.main.async {
            if case .success(let meals) = self.sut.state.value {
                XCTAssertEqual(meals.count, 2)
                expectation.fulfill()
            } else {
                XCTFail("Expected success state")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testFetchFavoritesEmpty() {
        let expectation = self.expectation(description: "Fetch favorites empty")
        mockRepository.shouldReturnData = false

        sut.fetchFavorites()

        DispatchQueue.main.async {
            if case .empty = self.sut.state.value {
                expectation.fulfill()
            } else {
                XCTFail("Expected empty state")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testRemoveFavoriteUpdatesState() {
        let expectation = self.expectation(description: "Remove favorite")
        mockRepository.shouldReturnData = true

        sut.fetchFavorites()
        sut.removeFavorite(mealID: "52772")

        DispatchQueue.main.async {
            if case .success(let meals) = self.sut.state.value {
                XCTAssertEqual(meals.count, 1)
                expectation.fulfill()
            } else {
                XCTFail("Expected success state after remove")
            }
        }

        waitForExpectations(timeout: 1.0)
    }

    func testToggleFavoriteAddsAndRemoves() {
        let expectation = self.expectation(description: "Toggle favorite")
        mockRepository.shouldReturnData = false

        sut.fetchFavorites()

        DispatchQueue.main.async {
            if case .empty = self.sut.state.value {
                // Add a meal
                let meal = Meal(
                    id: "52772",
                    name: "Test Meal",
                    thumbnailURL: "https://example.com/image.jpg",
                    instructions: "Test",
                    ingredients: nil
                )
                self.mockRepository.shouldReturnData = true
                self.sut.toggleFavorite(meal: meal)

                DispatchQueue.main.async {
                    if case .success(let meals) = self.sut.state.value {
                        XCTAssertEqual(meals.count, 2)
                        expectation.fulfill()
                    } else {
                        XCTFail("Expected success after adding favorite")
                    }
                }
            }
        }

        waitForExpectations(timeout: 3.0)
    }
}

// MARK: - MockFavoritesMealRepository

final class MockFavoritesMealRepository: MealRepositoryProtocol {

    var shouldReturnData: Bool = false

    private let mockMeals: [Meal] = [
        Meal(
            id: "52772",
            name: "Teriyaki Chicken Casserole",
            thumbnailURL: "https://example.com/teriyaki.jpg",
            instructions: "Test instructions",
            ingredients: nil
        ),
        Meal(
            id: "52773",
            name: "Test Meal 2",
            thumbnailURL: "https://example.com/meal2.jpg",
            instructions: "Test instructions 2",
            ingredients: nil
        )
    ]

    func fetchCategories(completion: @escaping (Result<[MealCategory], NetworkError>) -> Void) {}
    func searchMeals(query: String, completion: @escaping (Result<[Meal], NetworkError>) -> Void) {}

    func getFavorites() -> [Meal] {
        return shouldReturnData ? mockMeals : []
    }

    func toggleFavorite(meal: Meal) {
        shouldReturnData = !shouldReturnData
    }

    func isFavorite(mealID: String) -> Bool {
        return shouldReturnData
    }

    func removeFavorite(mealID: String) {
        // Simulate removing one item - return only the second meal
        shouldReturnData = true
    }
}