import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
    case noData
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please try again."
        case .requestFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to process data: \(error.localizedDescription)"
        case .noData:
            return "No data received. Please try again."
        case .invalidResponse:
            return "Invalid response from server. Please try again."
        }
    }
}