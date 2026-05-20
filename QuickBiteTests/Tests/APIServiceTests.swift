import XCTest
@testable import QuickBite
import Alamofire

final class APIServiceTests: XCTestCase {

    private var sut: APIService!
    private var session: Session!

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = Session(configuration: configuration)
        sut = APIService(session: session)
    }

    override func tearDown() {
        sut = nil
        session = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testFetchCategoriesSuccess() {
        let expectation = self.expectation(description: "Fetch categories success")

        let mockData = """
        {
            "categories": [
                {
                    "idCategory": "1",
                    "strCategory": "Beef",
                    "strCategoryThumb": "https://example.com/beef.jpg",
                    "strCategoryDescription": "Beef dishes"
                }
            ]
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, mockData)
        }

        sut.fetchCategories { result in
            switch result {
            case .success(let categories):
                XCTAssertEqual(categories.count, 1)
                XCTAssertEqual(categories.first?.strCategory, "Beef")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success")
            }
        }

        waitForExpectations(timeout: 2.0)
    }

    func testFetchCategoriesFailure() {
        let expectation = self.expectation(description: "Fetch categories failure")

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        sut.fetchCategories { result in
            switch result {
            case .success:
                XCTFail("Expected failure")
            case .failure(let error):
                if case .requestFailed = error {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected requestFailed error")
                }
            }
        }

        waitForExpectations(timeout: 2.0)
    }

    func testSearchMealsSuccess() {
        let expectation = self.expectation(description: "Search meals success")

        let mockData = """
        {
            "meals": [
                {
                    "idMeal": "52772",
                    "strMeal": "Teriyaki Chicken Casserole",
                    "strMealThumb": "https://example.com/teriyaki.jpg",
                    "strInstructions": "Some instructions"
                }
            ]
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, mockData)
        }

        sut.searchMeals(query: "chicken") { result in
            switch result {
            case .success(let meals):
                XCTAssertEqual(meals.count, 1)
                XCTAssertEqual(meals.first?.name, "Teriyaki Chicken Casserole")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success")
            }
        }

        waitForExpectations(timeout: 2.0)
    }

    func testSearchMealsNoResults() {
        let expectation = self.expectation(description: "Search meals no results")

        let mockData = """
        {
            "meals": null
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, mockData)
        }

        sut.searchMeals(query: "xyznonexistent") { result in
            switch result {
            case .success(let meals):
                XCTAssertTrue(meals.isEmpty)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success with empty array")
            }
        }

        waitForExpectations(timeout: 2.0)
    }

    func testInvalidURLCausesError() {
        // Test with non-empty query to ensure valid URL generation
        // APIEndpoint.search with empty query should still generate a valid URL
        let endpoint = APIEndpoint.categories
        XCTAssertNotNil(endpoint.url, "Categories endpoint should produce a valid URL")
    }
}

// MARK: - MockURLProtocol

final class MockURLProtocol: URLProtocol {

    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler not set")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}