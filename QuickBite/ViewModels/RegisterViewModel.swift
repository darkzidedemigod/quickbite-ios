import Foundation

enum RegisterState {
    case idle
    case loading
    case success(User)
    case error(String)
}

final class RegisterViewModel {

    private let authService: AuthServiceProtocol

    let state: Observable<RegisterState> = Observable(.idle)
    let email: Observable<String> = Observable("")
    let firstName: Observable<String> = Observable("")
    let lastName: Observable<String> = Observable("")
    let password: Observable<String> = Observable("")
    let isValid: Observable<Bool> = Observable(false)

    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        setupValidation()
    }

    private func setupValidation() {
        email.bind { [weak self] _ in self?.validate() }
        firstName.bind { [weak self] _ in self?.validate() }
        lastName.bind { [weak self] _ in self?.validate() }
        password.bind { [weak self] _ in self?.validate() }
    }

    private func validate() {
        let trimmedEmail = email.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFirstName = firstName.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmailValid = !trimmedEmail.isEmpty && trimmedEmail.contains("@") && trimmedEmail.contains(".")
        let isNameValid = !trimmedFirstName.isEmpty && !trimmedLastName.isEmpty
        let isPasswordValid = !trimmedPassword.isEmpty && trimmedPassword.count >= 6
        isValid.value = isEmailValid && isNameValid && isPasswordValid
    }

    func register() {
        guard isValid.value else {
            state.value = .error("Please complete all fields with valid information.")
            return
        }

        state.value = .loading

        authService.register(
            email: email.value,
            firstName: firstName.value,
            lastName: lastName.value,
            password: password.value
        ) { [weak self] result in
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

    func updateFirstName(_ firstName: String) {
        self.firstName.value = firstName
    }

    func updateLastName(_ lastName: String) {
        self.lastName.value = lastName
    }

    func updatePassword(_ password: String) {
        self.password.value = password
    }
}
