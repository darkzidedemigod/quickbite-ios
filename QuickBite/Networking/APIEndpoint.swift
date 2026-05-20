import Foundation
import Alamofire

enum APIEndpoint {
    case categories
    case search(query: String)

    private var baseURL: String {
        return "https://www.themealdb.com/api/json/v1/1"
    }

    var path: String {
        switch self {
        case .categories:
            return "/categories.php"
        case .search:
            return "/search.php"
        }
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: [String: String]? {
        switch self {
        case .categories:
            return nil
        case .search(let query):
            return ["s": query]
        }
    }

    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        if let parameters = parameters {
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        return components?.url
    }
}