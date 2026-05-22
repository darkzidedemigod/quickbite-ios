import Foundation

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

protocol AuthServiceProtocol {
    func login(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void)
    func register(
        email: String,
        firstName: String,
        lastName: String,
        password: String,
        completion: @escaping (Result<User, AuthError>) -> Void
    )
    func logout()
    func getCurrentUser() -> User?
}

enum AuthError: LocalizedError {
    case invalidEmail
    case invalidPassword
    case invalidName
    case invalidCredentials
    case emailAlreadyInUse
    case firebaseNotConfigured
    case networkUnavailable
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .invalidPassword:
            return "Password must be at least 6 characters."
        case .invalidName:
            return "Please enter your first and last name."
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .emailAlreadyInUse:
            return "An account already exists for this email address."
        case .firebaseNotConfigured:
            return "Firebase is not configured. Add GoogleService-Info.plist and install FirebaseAuth and FirebaseFirestore."
        case .networkUnavailable:
            return "Network unavailable. Please check your connection and try again."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}

final class AuthService: AuthServiceProtocol {

    static let shared = AuthService()

    private let userDefaultsKey = "com.quickbite.currentUser"
    private let usersCollection = "users"

    private init() {}

    func login(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
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

        #if canImport(FirebaseAuth) && canImport(FirebaseCore) && canImport(FirebaseFirestore)
        guard FirebaseApp.app() != nil else {
            completion(.failure(.firebaseNotConfigured))
            return
        }

        Auth.auth().signIn(withEmail: trimmedEmail, password: trimmedPassword) { [weak self] result, error in
            guard let self = self else {
                completion(.failure(.unknown))
                return
            }

            if let error = error {
                completion(.failure(self.mapFirebaseAuthError(error)))
                return
            }

            guard let firebaseUser = result?.user else {
                completion(.failure(.unknown))
                return
            }

            self.loadUserProfile(firebaseUser: firebaseUser, fallbackEmail: trimmedEmail) { result in
                if case .success(let user) = result {
                    self.saveUser(user)
                }
                completion(result)
            }
        }
        #else
        completion(.failure(.firebaseNotConfigured))
        #endif
    }

    func register(
        email: String,
        firstName: String,
        lastName: String,
        password: String,
        completion: @escaping (Result<User, AuthError>) -> Void
    ) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            completion(.failure(.invalidEmail))
            return
        }

        guard !trimmedFirstName.isEmpty, !trimmedLastName.isEmpty else {
            completion(.failure(.invalidName))
            return
        }

        guard !trimmedPassword.isEmpty, trimmedPassword.count >= 6 else {
            completion(.failure(.invalidPassword))
            return
        }

        #if canImport(FirebaseAuth) && canImport(FirebaseCore) && canImport(FirebaseFirestore)
        guard FirebaseApp.app() != nil else {
            completion(.failure(.firebaseNotConfigured))
            return
        }

        Auth.auth().createUser(withEmail: trimmedEmail, password: trimmedPassword) { [weak self] result, error in
            guard let self = self else {
                completion(.failure(.unknown))
                return
            }

            if let error = error {
                completion(.failure(self.mapFirebaseAuthError(error)))
                return
            }

            guard let firebaseUser = result?.user else {
                completion(.failure(.unknown))
                return
            }

            self.saveRegisteredUserProfile(
                firebaseUser: firebaseUser,
                email: trimmedEmail,
                firstName: trimmedFirstName,
                lastName: trimmedLastName
            ) { result in
                if case .success(let user) = result {
                    self.saveUser(user)
                }
                completion(result)
            }
        }
        #else
        completion(.failure(.firebaseNotConfigured))
        #endif
    }

    func logout() {
        #if canImport(FirebaseAuth) && canImport(FirebaseCore)
        if FirebaseApp.app() != nil {
            try? Auth.auth().signOut()
        }
        #endif

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

    #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
    private func saveRegisteredUserProfile(
        firebaseUser: FirebaseAuth.User,
        email: String,
        firstName: String,
        lastName: String,
        completion: @escaping (Result<User, AuthError>) -> Void
    ) {
        let name = "\(firstName) \(lastName)"
        let user = User(email: email, name: name)
        let document = Firestore.firestore()
            .collection(usersCollection)
            .document(firebaseUser.uid)
        let data: [String: Any] = [
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "name": name,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        let changeRequest = firebaseUser.createProfileChangeRequest()
        changeRequest.displayName = name
        changeRequest.commitChanges { _ in }

        document.setData(data, merge: true) { error in
            if error != nil {
                completion(.failure(.unknown))
                return
            }
            completion(.success(user))
        }
    }

    private func loadUserProfile(
        firebaseUser: FirebaseAuth.User,
        fallbackEmail: String,
        completion: @escaping (Result<User, AuthError>) -> Void
    ) {
        let document = Firestore.firestore()
            .collection(usersCollection)
            .document(firebaseUser.uid)

        document.getDocument { snapshot, error in
            if error != nil {
                completion(.failure(.unknown))
                return
            }

            if let data = snapshot?.data() {
                let email = data["email"] as? String ?? firebaseUser.email ?? fallbackEmail
                let name = data["name"] as? String ?? firebaseUser.displayName ?? "QuickBite User"
                completion(.success(User(email: email, name: name)))
                return
            }

            let email = firebaseUser.email ?? fallbackEmail
            let name = firebaseUser.displayName ?? "QuickBite User"
            let user = User(email: email, name: name)
            let data: [String: Any] = [
                "email": email,
                "name": name,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ]

            document.setData(data, merge: true) { error in
                if error != nil {
                    completion(.failure(.unknown))
                    return
                }
                completion(.success(user))
            }
        }
    }

    private func mapFirebaseAuthError(_ error: Error) -> AuthError {
        let code = AuthErrorCode(rawValue: (error as NSError).code)

        switch code {
        case .invalidEmail:
            return .invalidEmail
        case .wrongPassword, .userNotFound, .invalidCredential:
            return .invalidCredentials
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .networkError:
            return .networkUnavailable
        default:
            return .unknown
        }
    }
    #endif
}
