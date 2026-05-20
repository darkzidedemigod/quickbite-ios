import Foundation

enum LoginState {
    case idle
    case loading
    case success(User)
    case error(String)
}

final class LoginViewModel {

    private let authService: AuthServiceProtocol

    let state: Observable<LoginState> = Observable(.idle)
    let email: Observable<String> = Observable("")
    let password: Observable<String> = Observable("")
    let isValid: Observable<Bool> = Observable(false)

    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        setupValidation()
    }

    private func setupValidation() {
        email.bind { [weak self] _ in self?.validate() }
        password.bind { [weak self] _ in self?.validate() }
    }

    private func validate() {
        let isEmailValid = !email.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                           email.value.contains("@") &&
                           email.value.contains(".")
        let isPasswordValid = !password.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                              password.value.count >= 6
        isValid.value = isEmailValid && isPasswordValid
    }

    func login() {
        guard isValid.value else {
            state.value = .error("Please check your email and password.")
            return
        }

        state.value = .loading

        authService.login(email: email.value, password: password.value) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.state.value = .success(user)
                case .failure(let error):
                    self.state.value = .error(error.localizedDescription)
                }
            }
        }
    }

    func updateEmail(_ email: String) {
        self.email.value = email
    }

    func updatePassword(_ password: String) {
        self.password.value = password
    }
}