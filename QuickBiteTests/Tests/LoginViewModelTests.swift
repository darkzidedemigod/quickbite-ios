import XCTest
@testable import QuickBite

final class LoginViewModelTests: XCTestCase {

    private var sut: LoginViewModel!
    private var mockAuthService: MockAuthService!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        sut = LoginViewModel(authService: mockAuthService)
    }

    override func tearDown() {
        sut = nil
        mockAuthService = nil
        super.tearDown()
    }

    func testInitialStateIsIdle() {
        if case .idle = sut.state.value {
            XCTAssertTrue(true)
        } else {
            XCTFail("Initial state should be idle")
        }
    }

    func testInitialIsValidIsFalse() {
        XCTAssertFalse(sut.isValid.value)
    }

    func testValidationWithValidEmailAndPassword() {
        sut.updateEmail("test@quickbite.com")
        sut.updatePassword("password123")
        XCTAssertTrue(sut.isValid.value)
    }

    func testValidationWithInvalidEmail() {
        sut.updateEmail("invalid")
        sut.updatePassword("password123")
        XCTAssertFalse(sut.isValid.value)
    }

    func testValidationWithShortPassword() {
        sut.updateEmail("test@quickbite.com")
        sut.updatePassword("12345")
        XCTAssertFalse(sut.isValid.value)
    }

    func testValidationWithEmptyEmail() {
        sut.updateEmail("")
        sut.updatePassword("password123")
        XCTAssertFalse(sut.isValid.value)
    }

    func testValidationWithEmptyPassword() {
        sut.updateEmail("test@quickbite.com")
        sut.updatePassword("")
        XCTAssertFalse(sut.isValid.value)
    }

    func testLoginSuccess() {
        let expectation = self.expectation(description: "Login succeeds")
        mockAuthService.shouldSucceed = true

        sut.updateEmail("test@quickbite.com")
        sut.updatePassword("password123")
        sut.login()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if case .success = self.sut.state.value {
                expectation.fulfill()
            } else {
                XCTFail("Expected success state")
            }
        }

        waitForExpectations(timeout: 3.0)
    }

    func testLoginFailure() {
        let expectation = self.expectation(description: "Login fails")
        mockAuthService.shouldSucceed = false

        sut.updateEmail("test@quickbite.com")
        sut.updatePassword("password123")
        sut.login()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if case .error = self.sut.state.value {
                expectation.fulfill()
            } else {
                XCTFail("Expected error state")
            }
        }

        waitForExpectations(timeout: 3.0)
    }

    func testLoginLoadingState() {
        mockAuthService.shouldSucceed = true

        sut.updateEmail("test@quickbite.com")
        sut.updatePassword("password123")
        sut.login()

        if case .loading = sut.state.value {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected loading state")
        }
    }
}

// MARK: - MockAuthService

final class MockAuthService: AuthServiceProtocol {

    var shouldSucceed: Bool = true

    func login(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            if self.shouldSucceed {
                let user = User(email: email, name: "Test User")
                completion(.success(user))
            } else {
                completion(.failure(.invalidCredentials))
            }
        }
    }

    func logout() {}

    func getCurrentUser() -> User? {
        return shouldSucceed ? User(email: "test@quickbite.com", name: "Test User") : nil
    }
}