import Foundation

protocol AuthServiceProtocol {
    func login(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void)
    func logout()
    func getCurrentUser() -> User?
}

enum AuthError: LocalizedError {
    case invalidEmail
    case invalidPassword
    case invalidCredentials
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .invalidPassword:
            return "Password must be at least 6 characters."
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}

final class AuthService: AuthServiceProtocol {

    static let shared = AuthService()

    private let userDefaultsKey = "com.quickbite.currentUser"
    private let validEmail = "test@quickbite.com"
    private let validPassword = "password123"

    private init() {}

    func login(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                completion(.failure(.unknown))
                return
            }

            let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !trimmedEmail.isEmpty, trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
                completion(.failure(.invalidEmail))
                return
            }

            guard !trimmedPassword.isEmpty, trimmedPassword.count >= 6 else {
                completion(.failure(.invalidPassword))
                return
            }

            guard trimmedEmail == self.validEmail, trimmedPassword == self.validPassword else {
                completion(.failure(.invalidCredentials))
                return
            }

            let user = User(email: trimmedEmail, name: "QuickBite User")
            self.saveUser(user)
            completion(.success(user))
        }
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    func getCurrentUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    private func saveUser(_ user: User) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
}