import Foundation

struct User: Codable, Equatable {
    let email: String
    let name: String
    let isLoggedIn: Bool

    init(email: String, name: String, isLoggedIn: Bool = true) {
        self.email = email
        self.name = name
        self.isLoggedIn = isLoggedIn
    }
}