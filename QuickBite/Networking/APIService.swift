import Foundation
import Alamofire
import Combine

protocol APIServiceProtocol {
    func fetchCategories(completion: @escaping (Result<[MealCategory], NetworkError>) -> Void)
    func searchMeals(query: String, completion: @escaping (Result<[Meal], NetworkError>) -> Void)
}

final class APIService: APIServiceProtocol {

    static let shared = APIService()

    private let session: Session

    init(session: Session = Session.default) {
        self.session = session
    }

    func fetchCategories(completion: @escaping (Result<[MealCategory], NetworkError>) -> Void) {
        guard let url = APIEndpoint.categories.url else {
            completion(.failure(.invalidURL))
            return
        }

        session.request(url, method: APIEndpoint.categories.method)
            .validate()
            .responseDecodable(of: MealCategoriesResponse.self) { response in
                switch response.result {
                case .success(let categoriesResponse):
                    completion(.success(categoriesResponse.categories))
                case .failure(let error):
                    if let decodingError = error.asAFError?.underlyingError as? DecodingError {
                        completion(.failure(.decodingFailed(decodingError)))
                    } else {
                        completion(.failure(.requestFailed(error)))
                    }
                }
            }
    }

    func searchMeals(query: String, completion: @escaping (Result<[Meal], NetworkError>) -> Void) {
        guard let url = APIEndpoint.search(query: query).url else {
            completion(.failure(.invalidURL))
            return
        }

        session.request(url, method: APIEndpoint.search(query: query).method)
            .validate()
            .responseDecodable(of: MealSearchResponse.self) { response in
                switch response.result {
                case .success(let searchResponse):
                    let meals = searchResponse.meals ?? []
                    completion(.success(meals))
                case .failure(let error):
                    if let decodingError = error.asAFError?.underlyingError as? DecodingError {
                        completion(.failure(.decodingFailed(decodingError)))
                    } else {
                        completion(.failure(.requestFailed(error)))
                    }
                }
            }
    }
}
