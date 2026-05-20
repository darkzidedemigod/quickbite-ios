import Foundation

enum ProfileState {
    case loggedIn(User)
    case loggedOut
}

final class ProfileViewModel {

    private let authService: AuthServiceProtocol

    let state: Observable<ProfileState> = Observable(.loggedOut)

    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
        checkUser()
    }

    func checkUser() {
        if let user = authService.getCurrentUser() {
            state.value = .loggedIn(user)
        } else {
            state.value = .loggedOut
        }
    }

    func logout() {
        authService.logout()
        state.value = .loggedOut
    }
}